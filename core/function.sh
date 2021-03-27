#!/data/data/com.termux/files/usr/bin/bash

RED=$(printf	'\033[31m')
GREEN=$(printf	'\033[32m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf	'\033[34m')
LIGHT=$(printf	'\033[1;96m')
RESET=$(printf	'\033[0m')

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
        echo -en "[?] $1 [$prompt] "

		read -r REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

		printf '%s\n' "${RESET}"

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
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
