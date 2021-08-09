#!/data/data/com.termux/files/usr/bin/bash

trap cleanup EXIT 2

_nowpath=$(pwd)

RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf '\033[34m')
LIGHT=$(printf '\033[1;96m')
RESET=$(printf '\033[0m')

red() {
	echo -e "${RED}$1${RESET}"
}

green() {
	echo -e "${GREEN}$1${RESET}"
}

yellow() {
	echo -e "${YELLOW}$1${RESET}"
}

blue() {
	echo -e "${BLUE}$1${RESET}"
}

light() {
	echo -e "${LIGHT}$1${RESET}"
}

ask() {
	# http://djm.me/ask
	while true; do

		if [ "${2:-}" = "Y" ]; then
			prompt="Y/n"
			default=Y
		elif [ "${2:-}" = "N" ]; then
			prompt="y/N"
			default=N
		else
			prompt="y/n"
			default=
		fi

		# Ask the question
		printf '%s\n' "${LIGHT}"
		printf "[?] "
		read -r -p "$1 [$prompt] " REPLY

		# Default?
		if [ -z "$REPLY" ]; then
			REPLY=$default
		fi

		printf '%s\n' "${RESET}"

		# Check if the reply is valid
		case "$REPLY" in
		Y* | y*) return 0 ;;
		N* | n*) return 1 ;;
		esac
	done
}

cleanup() {
	[[ -n ${USE_MIRROR} ]] && blue "\n[*] 正在恢复镜像源..." && mv -f "${PREFIX}"/etc/apt/sources.list.bak "${PREFIX}"/etc/apt/sources.list
	rm -rf "$HOME/atm"
	if [ -f "$PREFIX/bin/atm" ]; then
		green "\n[√]  安装成功！请输入 atm 启动脚本！"
		exit 0
	else
		red "
[!] 安装失败！
	"
		exit 1
	fi
}

# Check
if [[ $EUID -eq 0 ]]; then
	yellow "
[!] 检测到您正在尝试使用 ROOT 权限运行安装脚本
[!] 这是不建议且不被允许的
[!] 安装全过程不需要 ROOT 权限,且以 ROOT 权限运行可能会带来一些无法预料的问题
[!] 为了您的设备安全，请避免在任何情况下以 ROOT 用户运行安装脚本
	"
	exit 1
fi
if [[ -d /system/app && -d /system/priv-app ]]; then
	systeminfo="Android $(getprop ro.build.version.release)"
	export systeminfo
else
	red "[!] This operating system is not supported."
	exit 1
fi

if [ -d "$PREFIX/etc/atm" ]; then
	yellow "
[!] 您已安装 Aria2-Termux ，无需重复安装
如果您需要移除 Aria2-Termux，请输入 rm -rf $PREFIX/etc/atm
	"
	exit 1
fi

hostname() {
	echo "$1" | awk -F'[/:]' '{print $4}'
}

timeout_test() {
	local URL="${1%/}"
	local timeout="${2-5}"

	timeout "$((timeout + 1))" curl \
		--head \
		--fail \
		--connect-timeout "$timeout" \
		--location \
		--user-agent "Termux-PKG/1.0 mirror-checker (termux-tools 0.112) Termux (com.termux; install-prefix:/data/data/com.termux/files/usr)'" \
		"$URL" >/dev/null 2>&1
}

replace_mirrors() {
	red "[!] Termux 镜像源不可用!"
	blue "对于国内用户，临时添加清华源作为镜像源可以有效增强 Termux 软件包下载速度"
	if ask "是否临时添加清华源用以下载脚本依赖?" "Y"; then
		cp "${PREFIX}"/etc/apt/sources.list "${PREFIX}"/etc/apt/sources.list.bak
		sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' "$PREFIX/etc/apt/sources.list"
		sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' "$PREFIX/etc/apt/sources.list.d/game.list"
		sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' "$PREFIX/etc/apt/sources.list.d/science.list"
		apt update && apt upgrade -y
		USE_MIRROR=1
	else
		blue "使用默认源进行安装"
	fi
}

check_mirrors() {
	blue "[*] 检查网络环境及镜像源..."
	local current_mirror
	current_mirror=$(grep -P "^\s*deb\s+" /data/data/com.termux/files/usr/etc/apt/sources.list | grep -oP 'https?://[a-z0-9/._-]+')

	if timeout_test "google.com"; then
		if timeout_test "${current_mirror%/}/dists/stable/Release"; then
			green "[√] 当前镜像源可用"
		else
			replace_mirrors
		fi
	elif [[ "$(hostname "$current_mirror")" == *".cn" ]]; then
		if timeout_test "${current_mirror%/}/dists/stable/Release"; then
			green "[√] 当前镜像源可用"
		else
			replace_mirrors
		fi
	else
		replace_mirrors
	fi
}

check_mirrors

blue "[*] 检查依赖中..."
apt-get update -y &>/dev/null
for i in git wget nmap-ncat; do
	if [ -e "$PREFIX/bin/$i" ]; then
		echo "  $i 已安装！"
	else
		echo "Installing $i..."
		apt-get install -y $i || {
			red "
[!] 依赖安装失败!
[*] 退出中...
			"
			exit 1
		}
	fi
done
apt-get upgrade -y

# Clone files
blue "\n[*] 正在拉取远程仓库..."
rm -rf "$HOME/atm/tmp"
git clone https://github.com/RimuruW/Aria2-Termux "$HOME/atm/tmp"
cd "$HOME/atm/tmp" || {
	red "目录跳转失败！" >&2
	exit 1
}
git checkout master

cd "$_nowpath" || {
	red "[!] 目录跳转失败!" >&2
	exit 1
}

rm -rf "$PREFIX/bin/atm"

if [ -d "$HOME/atm/tmp" ]; then
	blue "\n[*] 正在处理文件..."
	mkdir -p "$PREFIX/etc/atm"
	mv -f "$HOME/atm/tmp" "$PREFIX/etc/atm/main"
	blue "\n[*] 正在创建启动器..."
	cp "$PREFIX/etc/atm/main/bin/atm" "$PREFIX/bin/atm"
	chmod +x "$PREFIX/bin/atm"
fi
