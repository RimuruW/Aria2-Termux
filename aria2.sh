#!/data/data/com.termux/files/usr/bin/bash
#=============================================================
# https://github.com/RimuruW/Aria2-Termux
# Doc: https://github.com/RimuruW/Aria2-Termux/blob/master/README.md
# More detail: https://qingxu.live/index.php/archives/aria2-for-termux/
# Description: Aria2 One-click installation management script for Termux
# Environment Required: Android with the latest Termux. (The latest Android version is recommended)
# Author: RimuruW
# Blog: https://qingxu.live
#=============================================================
if [ "$(uname -o)" != "Android" ]; then
	PREFIX=/data/data/com.termux/files/usr
fi

sh_ver="1.0.6"
ver_code="20210726"
export ver_code
#PATH=/data/data/com.termux/files/usr/bin
#export PATH
aria2_conf_dir="$HOME/.aria2"
download_path="/sdcard/Download"
aria2_conf="${aria2_conf_dir}/aria2.conf"
aria2_log="${aria2_conf_dir}/aria2.log"
aria2c="$PREFIX/bin/aria2c"
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

check_script_download() {
	if [ ! -d $PREFIX/etc/tiviw ]; then
		[[ ! -f "./aria2.sh" ]] && pkg in wget -y && wget -N https://cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/aria2.sh && chmod +x aria2.sh
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

Download_aria2_conf() {
    PROFILE_URL1="https://cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/conf"
    PROFILE_URL2="https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/conf/"
    PROFILE_LIST="
aria2.conf
clean.sh
core
script.conf
rclone.env
upload.sh
delete.sh
dht.dat
dht6.dat
move.sh
auto-start-aria2
"
    mkdir -p "${aria2_conf_dir}"
	cd "${aria2_conf_dir}"  || { red "[!] 目录跳转失败！" >&2;  exit 1; }
    for PROFILE in ${PROFILE_LIST}; do
        [[ ! -f ${PROFILE} ]] && rm -rf "${PROFILE}"
        wget -N -t2 -T3 "${PROFILE_URL1}"/"${PROFILE}" ||
            wget -N -t2 -T3 "${PROFILE_URL2}"/"${PROFILE}"
        [[ ! -s ${PROFILE} ]] && {
            red "[!] '${PROFILE}' 下载失败！清理残留文件..."
            rm -vrf "${aria2_conf_dir}"
            exit 1
        }
    done
    sed -i "s@^\(dir=\).*@\1${download_path}@" "${aria2_conf}"
	sed -i "s@^\(input-file=\).*@\1${aria2_conf_dir}/aria2.session@" "${aria2_conf}"
	sed -i "s@^\(save-session=\).*@\1${aria2_conf_dir}/aria2.session@" "${aria2_conf}"
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" "${aria2_conf}"
    sed -i "s@^\(rpc-secret=\).*@\1$(date +%s%N | md5sum | head -c 20)@" "${aria2_conf}"
    sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${download_path}'@" "${aria2_conf_dir}/*.sh"
    sed -i "s@#log=@log=${aria2_log}@" "${aria2_conf}"
    touch aria2.session
    chmod +x ./*.sh
    green "[√] Aria2 配置文件下载完成！"
}

Installation_dependency() {
        blue "[*] 检查依赖中…"
		apt-get update -y &> /dev/null
		for i in nano ca-certificates findutils jq tar gzip dpkg curl; do
			if apt list --installed 2>/dev/null | grep "$i"; then
				echo "  $i 已安装！"
			elif [ -e $PREFIX/bin/$i ]; then
				echo "  $i 已安装！"
			else
				echo  "${BLUE}[*]${RESET} Installing $i..."
				apt-get install -y $i || {
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

Install_aria2() {
	check_root
	[[ -e ${aria2c} ]] && red "[!] Aria2 已安装，如需重新安装请在脚本中卸载 Aria2！" && return 0
	check_sys
	check_mirrors
	blue "[*] 开始安装并配置依赖..."
	Installation_dependency
	blue "[*] 开始下载并安装主程序..."
	pkg in aria2 -y 2>/dev/null
	blue "[*] 开始下载 Aria2 配置文件..."
	Download_aria2_conf
	aria2_RPC_port=${aria2_port}
	blue "[*] 开始创建下载目录..."
	check_storage
	mkdir -p ${download_path}
    [[ -n "$USE_MIRROR" ]] && blue "[*] 正在还原镜像配置..." && mv "${PREFIX}"/etc/apt/sources.list.bak "${PREFIX}"/etc/apt/sources.list
	green "[√] 所有步骤执行完毕，开始启动..."
	Start_aria2
}

Start_aria2() {
	check_installed_status
	check_pid
	[[ -n ${PID} ]] && red "[!] Aria2 正在运行!" && return 1
	check_storage
	blue "[*] 尝试开启唤醒锁…"
	termux-wake-lock
	green "[√] 所有步骤执行完毕，开始启动..."
	$PREFIX/bin/aria2c --conf-path="${aria2_conf}" -D
	check_pid
	[[ -z ${PID} ]] && red "[!] Aria2 启动失败，请检查日志！" && return 1
}
Stop_aria2() {
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && red "[!] Aria2 未启动，请检查日志 !" && return 0
	kill -9 "${PID}"
    blue "[*] 正在关闭唤醒锁…"
    termux-wake-unlock
}
Restart_aria2() {
	check_installed_status
	check_pid
	[[ -n ${PID} ]] && kill -9 "${PID}"
	check_storage
	blue "[*] 尝试开启唤醒锁……"
	termux-wake-lock
	green "[√] 所有步骤执行完毕，开始启动..."
	$PREFIX/bin/aria2c --conf-path="${aria2_conf}" -D
	[[ -z ${PID} ]] && red "[!] Aria2 启动失败，请检查日志！" && return 1
}
Set_aria2() {
	check_installed_status
	aria2_modify=null
	echo -e "
 ${GREEN}1.${RESET} 修改 Aria2 RPC 密钥
 ${GREEN}2.${RESET} 修改 Aria2 RPC 端口
 ${GREEN}3.${RESET} 修改 Aria2 下载目录
 ${GREEN}4.${RESET} 修改 Aria2 密钥 + 端口 + 下载目录
 ${GREEN}5.${RESET} 手动 打开配置文件修改
 ${GREEN}6.${RESET} 重置/更新 Aria2 配置文件
 -------------------
 ${GREEN}0.${RESET}  退出脚本
"
	echo -en " 请输入数字 [0-5]: "
	read -r aria2_modify
	if [[ ${aria2_modify} == "1" ]]; then
		Set_aria2_RPC_passwd
	elif [[ ${aria2_modify} == "2" ]]; then
		Set_aria2_RPC_port
	elif [[ ${aria2_modify} == "3" ]]; then
		Set_aria2_RPC_dir
	elif [[ ${aria2_modify} == "4" ]]; then
		Set_aria2_RPC_passwd_port_dir
	elif [[ ${aria2_modify} == "5" ]]; then
		Set_aria2_vim_conf
	elif [[ ${aria2_modify} == "6" ]]; then
		Reset_aria2_conf
	elif [[ ${aria2_modify} == "0" ]]; then
		return 0
	else
		echo
		echo "${RED}[!]${RESET} 请输入正确的数字"
		return 1
	fi
}
Set_aria2_RPC_passwd() {
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_passwd}" ]]; then
        aria2_passwd_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_passwd_1=${aria2_passwd}
    fi
    echo -e "
 ${BLUE}[*]${RESET} Aria2 RPC 密钥不要包含等号(=)和井号(#)，留空则随机生成。

 当前 RPC 密钥为: ${GREEN}${aria2_passwd_1}${RESET}
"
    echo -en " 请输入新的 RPC 密钥: "
    read -r aria2_RPC_passwd
    echo
    [[ -z "${aria2_RPC_passwd}" ]] && aria2_RPC_passwd=$(date +%s%N | md5sum | head -c 20)
    if [[ "${aria2_passwd}" != "${aria2_RPC_passwd}" ]]; then
        if [[ -z "${aria2_passwd}" ]]; then
			if echo -e "\nrpc-secret=${aria2_RPC_passwd}" >> "${aria2_conf}"; then
				echo -e "
${BLUE}[√]${RESET} RPC 密钥修改成功！
新密钥为：${GREEN}${aria2_RPC_passwd}${RESET}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "
${RED}[!]${RESET} RPC 密钥修改失败！
旧密钥为：${RED}${aria2_passwd}${RESET}
				"
            fi
        else
            if sed -i 's/^rpc-secret='"${aria2_passwd}"'/rpc-secret='"${aria2_RPC_passwd}"'/g' "${aria2_conf}"; then
                echo -e "
${GREEN}[√]${RESET} RPC 密钥修改成功！
新密钥为：${GREEN}${aria2_RPC_passwd}${RESET}"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
				echo -e  "
${RED}[!]${RESET} RPC 密钥修改失败！
旧密钥为：${GREEN}${aria2_passwd}${RESET}
				"
            fi
        fi
    else
        red "[!] 与旧配置一致，无需修改..."
    fi
}

Set_aria2_RPC_port() {
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_port}" ]]; then
        aria2_port_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_port_1=${aria2_port}
    fi
    echo -e "
 当前 RPC 端口为: ${GREEN}${aria2_port_1}${RESET}
"
	echo -en " 请输入新的 RPC 端口(默认: 6800): "
    read -r aria2_RPC_port
    echo
    [[ -z "${aria2_RPC_port}" ]] && aria2_RPC_port="6800"
    if [[ "${aria2_port}" != "${aria2_RPC_port}" ]]; then
        if [[ -z "${aria2_port}" ]]; then
            if echo -e "\nrpc-listen-port=${aria2_RPC_port}" >> "${aria2_conf}"; then
                echo -e "
${GREEN}[*]${RESET} RPC 端口修改成功！
新端口为：${GREEN}${aria2_RPC_port}${RESET}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"   
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
				echo -e "
${RED}[!]${RESET} RPC 端口修改失败！
旧端口为：${GREEN}${aria2_port}${RESET}"
            fi
        else
            if sed -i 's/^rpc-listen-port='"${aria2_port}"'/rpc-listen-port='"${aria2_RPC_port}"'/g' "${aria2_conf}"; then
                echo -e "
${GREEN}[√]${RESET} RPC 端口修改成功！
新端口为：${GREEN}${aria2_RPC_port}${RESET}
"                               
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "
${RED}[!]${RESET} RPC 端口修改失败！
旧端口为：${GREEN}${aria2_port}${RESET}
				"
            fi
        fi
    else
        echo -e "${YELLOW}[!]${RESET} 与旧配置一致，无需修改..."
    fi
}
Set_aria2_RPC_dir() {
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_dir}" ]]; then
        aria2_dir_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_dir_1=${aria2_dir}
    fi
    echo -e "
 当前下载目录为: ${GREEN}${aria2_dir_1}${RESET}
"
    echo -en " 请输入新的下载目录(默认: ${download_path}): "
	read -r aria2_RPC_dir
    [[ -z "${aria2_RPC_dir}" ]] && aria2_RPC_dir="${download_path}"
    mkdir -p ${aria2_RPC_dir}
    echo
    if [[ "${aria2_dir}" != "${aria2_RPC_dir}" ]]; then
        if [[ -z "${aria2_dir}" ]]; then
            if echo -e "\ndir=${aria2_RPC_dir}" >> "${aria2_conf}"; then
                echo -e "
${GREEN}[√]${RESET} 下载目录修改成功！
新位置为：${GREEN}${aria2_RPC_dir}${RESET}(配置文件中缺少相关选项参数，已自动加入配置文件底部)
				"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
				echo -e "
${RED}[!]${RESET} 下载目录修改失败！
旧位置为：${GREEN}${aria2_dir}${RESET}
"
            fi
        else
            aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
            aria2_RPC_dir_2=$(echo "${aria2_RPC_dir}" | sed 's/\//\\\//g')
            if sed -i "s@^\(dir=\).*@\1${aria2_RPC_dir_2}@" "${aria2_conf}" && sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_RPC_dir_2}'@" "${aria2_conf_dir}/*.sh"; then
                echo -e "
${GREEN}[√]${RESET} 下载目录修改成功！
新位置为：${GREEN}${aria2_RPC_dir}${RESET}
"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "
${RED}[!]${RESET} 下载目录修改失败！
旧位置为：${GREEN}${aria2_dir}${RESET}"
            fi
        fi
    else
		echo "${YELLOW}[!]${RESET} 与旧配置一致，无需修改..."
    fi
}
Set_aria2_RPC_passwd_port_dir() {
    Read_config
    Set_aria2_RPC_passwd "1"
    Set_aria2_RPC_port "1"
    Set_aria2_RPC_dir "1"
    Restart_aria2
}
Set_aria2_vim_conf() {
    Read_config
    aria2_port_old=${aria2_port}
    aria2_dir_old=${aria2_dir}
    echo -e "
 配置文件位置：${GREEN}${aria2_conf}${RESET}

 ${GREEN}[*]${RESET} 手动修改配置文件须知：
 
 ${GREEN}1.${RESET} 默认使用 nano 文本编辑器打开
 ${GREEN}2.${RESET} 退出并保存文件：按 ${GREEN}Ctrl+X${RESET} 组合键，输入 ${GREEN}y${RESET} ，然后按 ${GREEN}Enter${RESET} 键
 ${GREEN}3.${RESET} 退出不保存文件：按 ${GREEN}Ctrl+X${RESET} 组合键，输入 ${GREEN}n${RESET}
 ${GREEN}4.${RESET} nano 详细使用教程: \033[4;34mhttps://wiki.archlinux.org/index.php/Nano_(简体中文)${RESET}
 "
    echo -en "按任意键继续，按 Ctrl+C 组合键取消"
    read -r -n 1 line
    nano "${aria2_conf}"
    Read_config
    if [[ ${aria2_port_old} != "${aria2_port}" ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    if [[ ${aria2_dir_old} != "${aria2_dir}" ]]; then
        mkdir -p "${aria2_dir}"
        aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
        sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_dir_2}'@" "${aria2_conf_dir}/*.sh"
    fi
    Restart_aria2
}
Reset_aria2_conf() {
    Read_config
    aria2_port_old=${aria2_port}
    echo -e "
${RED}[!]${RESET} 此操作将重新下载 Aria2 配置文件，所有已设定的配置将丢失。

按任意键继续，按 Ctrl+C 组合键取消"
	read -r -n 1 line
    Download_aria2_conf
    Read_config
    if [[ ${aria2_port_old} != "${aria2_port}" ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    Restart_aria2
}

Read_config() {
	status_type=$1
	if [[ ! -e ${aria2_conf} ]]; then
		if [[ ${status_type} != "un" ]]; then
			echo -e "${RED}[!]${RESET} Aria2 配置文件不存在 !" && return 0
		fi
	else
		aria2_dir=$(grep "^dir=" "${aria2_conf}" | grep -v '#'| awk -F "=" '{print $NF}')
		aria2_port=$(grep "^rpc-listen-port=" "${aria2_conf}" | grep -v '#' | awk -F "=" '{print $NF}')
		aria2_passwd=$(grep "^rpc-secret=" "${aria2_conf}" | grep -v '#' | awk -F "=" '{print $NF}')
	fi
}

View_Aria2() {
    check_installed_status
    Read_config
    IPV4=$(
        wget -qO- -t1 -T2 -4 api.ip.sb/ip ||
            wget -qO- -t1 -T2 -4 ifconfig.io/ip ||
            wget -qO- -t1 -T2 -4 www.trackip.net/ip
    )
    IPV6=$(
        wget -qO- -t1 -T2 -6 api.ip.sb/ip ||
            wget -qO- -t1 -T2 -6 ifconfig.io/ip ||
            wget -qO- -t1 -T2 -6 www.trackip.net/ip
    )
    LocalIP=$(
    for LOCALIP in $(ip a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | cut -d "/" -f1)
    do
        unset "$TMPLOCALIP"
	    TMPLOCALIP=$LOCALIP
    done
    echo "$TMPLOCALIP"
)
    [[ -z "${IPV4}" ]] && IPV4="IPv4 地址检测失败"
    [[ -z "${IPV6}" ]] && IPV6="IPv6 地址检测失败"
    [[ -z "${LocalIP}" ]] && LocalIP="本地 IP 获取失败"
    [[ -z "${aria2_dir}" ]] && aria2_dir="找不到配置参数"
    [[ -z "${aria2_port}" ]] && aria2_port="找不到配置参数"
    [[ -z "${aria2_passwd}" ]] && aria2_passwd="找不到配置参数(或无密钥)"
    if [[ -z "${IPV4}" || -z "${aria2_port}" ]]; then
        AriaNg_URL="null"
    else
        AriaNg_API="/#!/settings/rpc/set/ws/${LocalIP}/${aria2_port}/jsonrpc/$(echo -n ${aria2_passwd} | base64)"
        AriaNg_URL="http://mirror-aria2.qingxu.live${AriaNg_API}"
    fi
    clear
    echo -e "\nAria2 简单配置信息：\n
 IPv4 地址\t: ${GREEN}${IPV4}${RESET}
 IPv6 地址\t: ${GREEN}${IPV6}${RESET}
 内网 IP 地址\t: ${GREEN}${LocalIP}${RESET} 
 RPC 端口\t: ${GREEN}${aria2_port}${RESET}
 RPC 密钥\t: ${GREEN}${aria2_passwd}${RESET}
 下载目录\t: ${GREEN}${aria2_dir}${RESET}
 AriaNg 链接\t: ${GREEN}${AriaNg_URL}${RESET}\n"
 echo -en "\n\n请回车以继续" && read -r -n 1 line
}

View_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${RED}[!]${RESET} Aria2 日志文件不存在 !" && return 0
    echo && echo -e "

${GREEN}[!]${RESET} 按 ${GREEN}Ctrl+C${RESET} 终止查看日志
如果需要查看完整日志内容，请用 ${GREEN}cat ${aria2_log}${RESET} 命令。

"
    tail -f "${aria2_log}"
}

Clean_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${RED}[!]${RESET} Aria2 日志文件不存在 !" && echo -en "\n\n请回车以继续" && read -r -n 1 line && return 0
    echo > "${aria2_log}"
    echo -e "${GREEN}[√]${RESET} Aria2 日志已清空 !"
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}

Update_bt_tracker() {
    check_installed_status
    check_pid
    if [ -z "$PID" ]; then
        bash <(wget -qO- cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/tracker.sh) "${aria2_conf}"
	else
		bash <(wget -qO- cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/tracker.sh) "${aria2_conf}" RPC
	fi
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}

Uninstall_aria2() {
    check_installed_status "un"
    if ask "确定要卸载 Aria2 ? " "N"; then
        apt purge -y aria2
        check_pid
        [[ -n $PID ]] && kill -9 "${PID}"
        Read_config "un"
        rm -rf "${aria2c}"
        rm -rf "${aria2_conf_dir}"
		rm -f "$HOME/.termux/boot/auto-start-aria2"
        echo -e "\n${GREEN}[√]${RESET} Aria2 卸载完成！\n"
    else
        echo && echo "${YELLOW}[*]${RESET} 卸载已取消..." && echo
    fi
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}

Update_Shell() {
    sh_new_ver=$(wget -qO- -t1 -T3 "https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh" | grep 'ver_code="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    [[ -z ${sh_new_ver} ]] && echo -e "${RED}[!]${RESET} 无法链接到 GitHub !" && exit 1
    if [ -f "$PREFIX/etc/tiviw/aria2.sh.bak2" ]; then
	    rm -f $PREFIX/etc/tiviw/aria2.sh.bak2
    fi
    if [ -f "$PREFIX/etc/tiviw/aria2.sh.bak" ]; then
	    mv $PREFIX/etc/tiviw/aria2.sh.bak $PREFIX/etc/tiviw/aria2.sh.bak2
    fi
    if [[ -d $PREFIX/etc/tiviw ]]; then
	    echo "${BLUE}[!]${RESET} 检测到 Tiviw! 启用 Tiviw 更新方案!"
	    mkdir -p $PREFIX/etc/tiviw/aria2
	    mv $PREFIX/etc/tiviw/aria2/aria2.sh $PREFIX/etc/tiviw/aria2/aria2.sh.bak
	    wget -P $PREFIX/etc/tiviw/aria2 https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh && chmod +x $PREFIX/etc/tiviw/aria2/aria2.sh
	    return 0
    else
	    wget -N "https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh" && chmod +x aria2.sh
    fi
    echo -e "
${GREEN}[√]${RESET} 脚本已更新为最新版本[${GREEN} ${sh_new_ver} ${RESET}]
${GREEN}[!]${RESET} 注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可
	" 
	exit 0
}

Auto_start() {
	echo -e "\n\n"
	echo -e "
${YELLOW}[!]${RESET} 受限于 Termux，Aria2 开机自启动需要 Termux 提供相应支持。
${YELLOW}[!]${RESET} 你需要先安装 ${GREEN}Termux:Boot${RESET} 才可以实现 Termux
Termux:Boot 下载链接: ${GREEN}https://play.google.com/store/apps/details?id=com.termux.boot${RESET}

${RED}[!]${RESET} 注意，如果你未安装 ${GREEN}Termux:Boot${RESET}，脚本中任何关于 Aria2 自启动的配置${RED}没有任何意义${RESET}
"
	if [ -f "$HOME/.termux/boot/auto-start-aria2" ]; then
		if ask "你已开启 Aria2 自启动，是否关闭？" "N"; then
			if rm -f "$HOME/.termux/boot/auto-start-aria2"; then
				echo -e "${GREEN}[√]${RESET} 已关闭 Aria2 自启动"
			else
				echo -e "${RED}[!] ${RESET} Aria2 自启动关闭失败！"
			fi
		else
			echo "${BLUE}[*]${RESET} 已跳过…"
		fi
	else
		if ask "是否开启 Aria2 开机自启动？" "N"; then
			mkdir -p "$HOME/.termux/boot"
			if [ -f "$aria2_conf_dir/auto-start-aria2" ]; then
				if cp "$aria2_conf_dir/auto-start-aria2" "$HOME/.termux/boot/auto-start-aria2"; then
					echo -e "${GREEN}[√]${RESET} Aria2 开机自启动已开启！"
				else
					echo -e "${RED}[!]${RESET} Aria2 启动开启失败！"
				fi
			else	
				echo -e "
${RED}[!]${RESET} 未找到自启动配置文件！
${RED}[!]${RESET} 这可能是因为你未通过本脚本完成 Aria2 安装或手动修改了相关目录。
${RED}[!]${RESET} 请通过脚本重新安装 Aria2 以避免绝大多数可避免的问题！"
			fi
		else
			echo -e "${BLUE}[*]${RESET} 不开启 Aria2 开机自启动…"
		fi
	fi
}
while true
do
	check_script_download
echo && echo -e "
Aria2 一键管理脚本 ${YELLOW}[v${sh_ver}]${RESET}
            by ${LIGHT}Qingxu(RimuruW)${RESET}

 ${GREEN} 0.${RESET} 退出
 ———————————————————————
 ${GREEN} 1.${RESET} 安装 Aria2
 ${GREEN} 2.${RESET} 卸载 Aria2
 ———————————————————————
 ${GREEN} 3.${RESET} 启动 Aria2
 ${GREEN} 4.${RESET} 停止 Aria2
 ${GREEN} 5.${RESET} 重启 Aria2
 ———————————————————————
 ${GREEN} 6.${RESET} 修改 配置
 ${GREEN} 7.${RESET} 查看 配置
 ${GREEN} 8.${RESET} 查看 日志
 ${GREEN} 9.${RESET} 清空 日志
 ———————————————————————
 ${GREEN} 10.${RESET} 一键更新 BT-Tracker
 ${GREEN} 11.${RESET} 一键更新脚本
 ${GREEN} 12.${RESET} Aria2 开机自启动
 ———————————————————————" && echo
if [[ -e ${aria2c} ]]; then
    check_pid
    if [[ -n "${PID}" ]]; then
        echo -e " Aria2 状态: ${GREEN}已安装${RESET} | ${GREEN}已启动${RESET}"
    else
        echo -e " Aria2 状态: ${GREEN}已安装${RESET} | ${RED}未启动${RESET}"
    fi
else
    echo -e " Aria2 状态: ${RED}未安装${RESET}"
fi
if [[ -f "$HOME/.termux/boot/auto-start-aria2" ]]; then
	echo -e " Aria2 开机自启动: ${GREEN}已开启${RESET}"
else
	echo -e " Aria2 开机自启动: ${RED}未开启${RESET}"
fi
num=null
printf "\n 请输入数字 [0-12]: "
read -r num
case "$num" in
0)
    exit 0
    ;;
1)
    Install_aria2
    ;;
2)
    Uninstall_aria2
    ;;
3)
    Start_aria2
    ;;
4)
    Stop_aria2
    ;;
5)
    Restart_aria2
    ;;
6)
    Set_aria2
    ;;
7)
    View_Aria2
    ;;
8)
    View_Log
    ;;
9)
    Clean_Log
    ;;
10)
    Update_bt_tracker
    ;;
11)
    Update_Shell
    ;;
12)
	Auto_start
	;;
*)
    echo
    echo -e "${RED}[!]${RESET} 请输入正确的数字"
    ;;
esac
done
export line
clear
