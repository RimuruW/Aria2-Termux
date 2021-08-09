#!/data/data/com.termux/files/usr/bin/bash

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
		echo -en "[?] $1 [$prompt] "

		read -r REPLY </dev/tty

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

check_root() {
	[[ $EUID = 0 ]] && red "
[!] 检测到您正在尝试用 ROOT 权限运行脚本
[!] 这是不建议也不被允许的
[!] 请勿在任何情况下以 ROOT 权限运行该脚本,以避免造成无法预料的损失
	" && exit 1
}

#检查系统
check_sys() {
	if [[ ! -d /system/app/ && ! -d /system/priv-app ]]; then
		red "[!] Unsupported system!"
		return 0
	fi
}

check_installed_status() {
	[[ ! -e ${aria2c} ]] && red "[!] Aria2 未安装!" && return 0
	[[ ! -e ${aria2_conf} ]] && red "
[!] Aria2 配置文件不存在！
[*] 如果你不是通过本脚本安装 Aria2，请先在本脚本卸载 Aria2！
	" && [[ $1 != "un" ]] && return 0
}

check_pid() {
	PID=$(pgrep "aria2c" | grep -v grep | grep -v "aria2.sh" | grep -v "service" | awk '{print $1}')
}

check_storage() {
	[[ ! -d "$HOME/storage/shared/Android/" ]] && red "[!] Termux 未获取存储权限，请回车确认后按指示授权存储权限！" && echo -en "\n请回车以确认" && read -r -n 1 line && termux-setup-storage
	[[ ! -d "$HOME/storage/shared/Android/" ]] && red "[!] Termux 存储权限未获取！请在确保 Termux 已获取存储权限的情况重新启动脚本！" && exit 1
}

network_check() {
	echo "正在检查网络连接…"
	if ping -q -c 1 -W 1 baidu.com >/dev/null; then
		return 0
	else
		exit 1
	fi
}

network_check_sea() {
	network_check
	green "[*] 尝试检查网络可用性…"
	if ping -q -c 1 -W 1 google.com >/dev/null; then
		return 0
	else
		return 1
	fi
}

remote_status() {
	if git remote -v | grep "https://github.com/RimuruW/Aria2-Termux"; then
		green "[√] 远程仓库地址为源地址!"
		return 0
	else
		red "[!] 远程仓库地址异常！"
		return 1
	fi
}

update_atm() {
	if network_check_sea; then
		cd $atm_git/main || {
			red "[!] 目录跳转失败！" >&2
			exit 1
		}
		git pull 2>/dev/null
		cp atm "$PREFIX"/bin/atm
		green "
[*] 已拉取最新版本！
[*] 请重启脚本以应用更新！
		"
	else
		cd "$ToolPATH/core" || {
			red "[!] 目录跳转失败！" >&2
			exit 1
		}
		git remote set-url origin https://gitee.com/RimuruW/tiviw
		if update_remote_status; then
			green "[*] 尝试拉取最新版本…"
			git checkout . && git clean -xd -f
			git pull 2>/dev/null
			cp tiviw $PREFIX/bin/tiviw
			green "[*] 拉取结束！"
			green "[*] 请重启脚本以应用更新！"
		else
			red "[*] 仍然尝试拉起最新版本…"
			red "	 拉取可能会失败！"
			git checkout . && git clean -xd -f
			git pull 2>/dev/null
			cp tiviw $PREFIX/bin/tiviw
			green "[*] 拉取结束！"
			green "[*] 请重启脚本以应用更新！"
		fi
		git remote set-url origin https://github.com/RimuruW/Tiviw
		if remote_status; then
			green "[√] 远程仓库地址恢复成功！"
		else
			red "
[!] 远程仓库地址恢复失败！
请手动输入 cd $ToolPATH/main && git remote set-url origin https://github.com/RimuruW/Tiviw 恢复远程仓库地址
提交该界面截图至开发者以帮助开发者解决该问题！
"
			exit 1
		fi
	fi
	cd "$HOME" || {
		red "[!] 目录跳转失败!" >&2
		exit 1
	}
}

check_apt_ability() {
	if check_mirror; then
		green "Termux 镜像源已配置"
		return 0
	else
		if network_check_sea; then
			return 0
		else
			red "根据检测结果，脚本认定你当前网络环境无法完成安装！"
			red "对于国内用户，请配置镜像源以完成安装！"
			blue "是否跳转到 Termux 镜像源配置？[y/n]"
			Enter
			read -r MIRROR_CHOOSE
			case $MIRROR_CHOOSE in
			y)
				source "$ToolPATH/core/main/mirror.sh"
				return 0
				;;
			*)
				red "跳过镜像源配置！"
				red "警告，根据网络环境和镜像源配置检测结果，脚本认为你无法完成安装！"
				red "安装强制中止！"
				Step
				return 1
				;;
			esac
		fi
	fi
}

check_dependency() {
	blue "[*] 检查依赖中…"
	apt-get update -y &>/dev/null
	for i in $1; do
		if apt list --installed 2>/dev/null | grep "$i"; then
			echo "${GREEN}[√]${RESET}  $i 已安装！"
		else
			echo "Installing $i..."
			apt-get install -y "$i" || {
				red "
[!] 依赖安装失败!
[*] 退出中……
									"
				exit 1
			}
		fi
	done
	apt-get upgrade -y
}

Enter() {
	echo -en "\t\tEnter an option: "
}

Step() {
	echo -en "\n\n\t\t\t请回车以确认"
	read -r -n 1 line
}

sp() {
	echo -e "\n"
}

Abort() {
	abort_echo=$1
	red "$abort_echo"
	exit 0
}

check_mirrors() {
	mirrors_status=$(grep "mirror" "$PREFIX/etc/apt/sources.list" | grep -v '#')
	if [ -z "$mirrors_status" ]; then
		red "[!] Termux 镜像源未配置!"
		blue "对于国内用户，添加清华源作为镜像源可以有效增强 Termux 软件包下载速度"
		if ask "是否添加清华源?" "Y"; then
			sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' "$PREFIX/etc/apt/sources.list"
			sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@'"$PREFIX/etc/apt/sources.list.d/game.list"
			sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' "$PREFIX/etc/apt/sources.list.d/science.list"
			apt update && apt upgrade -y
		else
			blue "[√] 使用默认源进行安装"
		fi
	fi
}