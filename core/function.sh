#!/data/data/com.termux/files/usr/bin/bash
if [ "$(uname -o)" != "Android" ]; then
	PREFIX=/data/data/com.termux/files/usr
fi

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
