#!/data/data/com.termux/files/usr/bin/bash

# Colors
G='\e[01;32m'      # GREEN TEXT
R='\e[01;31m'      # RED TEXT
Y='\e[01;33m'      # YELLOW TEXT
B='\e[01;34m'      # BLUE TEXT
V='\e[01;35m'      # VIOLET TEXT
Bl='\e[01;30m'     # BLACK TEXT
C='\e[01;36m'      # CYAN TEXT
W='\e[01;37m'      # WHITE TEXT
L='\e[1;96m'       # LIGHT TEXT
BGBL='\e[1;30;47m' # Background W Text Bl
N='\e[0m'          # How to use (example): echo "${G}example${N}"
loadBar=' '        # Load UI

red() {
    echo -e "${R}$1${N}"
}

green() {
    echo -e "${G}$1${N}"
}

yellow() {
    echo -e "${Y}$1${N}"
}

blue() {
    echo -e "${B}$1${N}"
}

light() {
    echo -e "${L}$1${N}"
}

ask() {
    # http://djm.me/ask
    LIGHT=$(printf '\033[1;96m')
    RESET=$(printf '\033[0m')
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

# No. of characters in $VER, and $REL
character_no=$(echo "Aria2-Termux $VER $REL" | wc -c)

div="${Bl}$(printf '%*s' "${character_no}" '' | tr " " "=")${N}"

# Mktouch
mktouch() {
    mkdir -p ${1%/*} 2>/dev/null
    [ -z $2 ] && touch $1 || echo $2 >$1
    chmod 644 $1
}

# Abort
abort() {
    red "$1"
    exit 1
}

# title_div [-c] <title>
# based on $div with <title>
title_div() {
    [ "$1" == "-c" ] && local character_no=$2 && shift 2
    [ -z "$1" ] && {
        local message=
        no=0
    } || {
        local message="$@ "
        local no="$(echo "$@" | wc -c)"
    }
    [ "$character_no" -gt "$no" ] && local extdiv=$((character_no - no)) || {
        echo "Invalid!"
        return
    }
    echo "${W}$message${N}${Bl}$(printf '%*s' "$extdiv" '' | tr " " "=")${N}"
}

# set_file_prop <property> <value> <prop.file>
set_file_prop() {
    if [ -f "$3" ]; then
        if grep -q "$1=" "$3"; then
            sed -i "s/${1}=.*/${1}=${2}/g" "$3"
        else
            echo "$1=$2" >>"$3"
        fi
    else
        echo "$3 不存在！"
    fi
}

# https://github.com/fearside/ProgressBar
# ProgressBar <progress> <total>
ProgressBar() {
    # Determine Screen Size
    if [[ "$COLUMNS" -le "57" ]]; then
        local var1=2
        local var2=20
    else
        local var1=4
        local var2=40
    fi
    # Process data
    local _progress=$(((${1} * 100 / ${2} * 100) / 100))
    local _done=$(((${_progress} * ${var1}) / 10))
    local _left=$((${var2} - $_done))
    # Build progressbar string lengths
    local _done=$(printf "%${_done}s")
    local _left=$(printf "%${_left}s")

    # Build progressbar strings and print the ProgressBar line
    printf "\rProgress : ${BGBL}|${N}${_done// /${BGBL}$loadBar${N}}${_left// / }${BGBL}|${N} ${_progress}%%"
}

#https://github.com/fearside/SimpleProgressSpinner
# Spinner <message>
Spinner() {
    # Choose which character to show.
    case ${_indicator} in
    "|") _indicator="/" ;;
    "/") _indicator="-" ;;
    "-") _indicator="\\" ;;
    "\\") _indicator="|" ;;
    # Initiate spinner character
    *) _indicator="\\" ;;
    esac

    # Print simple progress spinner
    printf "\r${@} [${_indicator}]"
}

# cmd & spinner <message>
e_spinner() {
    _PID=$!
    h=0
    anim='-\|/'
    while true; do
        h=$(((h + 1) % 4))
        sleep 0.02
        printf "\r${@} [${anim:$h:1}]"
        grep_PID=$(ps aux | awk '{print $2}' | grep -q ${_PID})
        if [ -n "$grep_PID" ]; then
            :
        else
            return 0
        fi
    done
    echo ""
}

check_storage() {
    [[ ! -d "$HOME/storage/shared/Android/" ]] && red "[!] Termux 未获取存储权限，请回车确认后按指示授权存储权限！" && echo -en "\n请回车以确认" && read -r -n 1 line && termux-setup-storage
    [[ ! -d "$HOME/storage/shared/Android/" ]] && red "[!] Termux 存储权限未获取！请在确保 Termux 已获取存储权限的情况重新启动脚本！" && exit 1
}

test_connection() {
    (
        if /system/bin/ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
            true
        elif /system/bin/ping -q -c 1 -W 1 bing.com >/dev/null 2>&1; then
            true
        elif /system/bin/ping -q -c 1 -W 1 baidu.com >/dev/null 2>&1; then
            true
        else
            false
        fi #&
        #e_spinner "${B}[*]${N} 检查网络连接"
    ) && echo -e " - ${G}网络正常${N}" || {
        echo -e " - ${R}网络异常${N}"
        false
    }
    sleep 1
}

# Log files will be uploaded to termbin.com
# 日志将会被上传至 termbin.com
# Logs included: VERLOG LOG oldVERLOG oldLOG
upload_logs() {
    (
        test_connection || exit
        [ -s $VERLOG ] && verUp=$(cat $VERLOG | nc termbin.com 9999) || verUp=none
        [ -s $oldVERLOG ] && oldverUp=$(cat $oldVERLOG | nc termbin.com 9999) || oldverUp=none
        [ -s $ARIA2LOG ] && logUp=$(cat $ARIA2LOG | nc termbin.com 9999) || logUp=none
        [ -s $_ATMLOG ] && ATMlogUp=$(cat $_ATMLOG | nc termbin.com 9999) || logUp=none

        echo -n "Link: "
        echo "Aria2-Termux 
    Version: $VER $REL
    Termux Version: 
    Android Version: 
    Model: 

    atm_old_Verbose: $oldverUp
    atm_Verbose: $verUp
    atm_log: $ATMlogUp

    allvar
==============
$(export)
==============

    Aria2:   $logUp" | nc termbin.com 9999 &
        e_spinner "测试网络连接"
    ) && echo " - OK" || {
        echo " - 出错"
        false
    }
    e_spinner "上传日志"
    exit
}

# Print Random
# Prints a message at random
# CHANCES - no. of chances <integer>
# TARGET - target value out of CHANCES <integer>
prandom() {
    local CHANCES=2
    local TARGET=2
    [ "$1" == "-c" ] && {
        local CHANCES=$2
        local TARGET=$3
        shift 3
    }
    [ "$((RANDOM % CHANCES + 1))" -eq "$TARGET" ] && echo "$@"
}

# Print Center
# Prints text in the center of terminal
pcenter() {
    local CHAR=$(printf "$@" | sed 's|\\e[[0-9;]*m||g' | wc -m)
    local hfCOLUMN=$((COLUMNS / 2))
    local hfCHAR=$((CHAR / 2))
    local indent=$((hfCOLUMN - hfCHAR))
    echo "$(printf '%*s' "${indent}" '') $@"
}

fancy_opening() {
    header
    echo -e "\n"
    NUM=1
    while [ $NUM -le 50 ]; do
        ProgressBar $NUM 50
        NUM=$((NUM + 5))
        sleep 0.001
    done
}

# Display on Header
header() {
    clear
    midALG=${#1}
    midALG=$((MDLVAL - midALG))
    [ $((midALG % 2)) -eq 0 ] || midALG=$((midALG - 1))
    midALG=$((midALG / 2))
    SP=$(printf %-${midALG}s " ")
    [ "$DEVMODE" ] || clear
    light " Aria2 一键管理脚本"
    echo ""
    echo -e " Version: ${Y}${VER}${N}"
    echo -e " by ${Y}Qingxu($AUTHOR)${N}"
    echo ""
    printf "${C}=%.0s${N}" $(seq "$MDLVAL")
    echo -e "\n${SP// / }$1"
    printf "${C}=%.0s${N}" $(seq "$MDLVAL")
    unset midALG
}

# Display on Footer
footer() {
    var=$((MDLVAL / 2))
    var=$((MDLVAL / 2 + 1))
    printf "${C}- %.0s${N}" $(seq $var)
    echo ""
    if [[ -e ${aria2c} ]]; then
        check_pid
        if [[ -n "${PID}" ]]; then
            echo -e " Aria2 状态: ${G}已安装${N} | ${G}已启动${N}"
        else
            echo -e " Aria2 状态: ${G}已安装${N} | ${R}未启动${N}"
        fi
    else
        echo -e " Aria2 状态: ${R}未安装${N}"
    fi
    if [[ -f "$HOME/.termux/boot/auto-start-aria2" ]]; then
        echo -e " Aria2 开机自启动: ${G}已开启${N}"
    else
        echo -e " Aria2 开机自启动: ${R}未开启${N}"
    fi
    printf "${C}- %.0s${N}" $(seq $var)
    echo ""
}

# invalid_input <type>
invalid_input() {
    echo ""
    case $1 in
    yn)
        invMSG="只有输入 [${G}y${N}] 代表 yes（肯定）或者 [${G}n${N}] 代表 no （否定）!"
        ;;
    t)
        invMSG="只能输入上面的 ${G}数字${N} 或选项！"
        ;;
    esac
    echo -e " ${R}无效输入${N}. $invMSG"
    unset invMSG
    sleep 2
}

# Print to log
log_handler() {
    echo "" >>"$_ATMLOG" 2>&1
    echo -e "$1" >>"$_ATMLOG" 2>&1
}

# Print to log and screen
log_print() {
    echo -e "$1"
    log_handler "$1"
}

# Check whether an update is available
sh_update() {
    header "准备中"
    echo ""
    echo ""
    test_connection || return 1
    mkdir -p ${ATMDIR}/tmp
    echo " - 检查更新..."
    wget -q -T 10 -O "$ATMDIR/tmp/atmrc" "$GITRAW/.atmrc" >>"$_ATMLOG" 2>&1
    echo ""
    sh_new_ver=$(grep 'REL="' "$ATMDIR/tmp/atmrc" | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    if [ -s "$ATMDIR/tmp/atmrc" ]; then
        if [[ "$REL" -lt "$sh_new_ver" ]]; then
            log_print " - ${Y}发现新版本！${N}"
            _PWD=$(pwd)
            cd "$PREFIX/etc/atm/main" || {
                red "目录跳转失败！" >&2
                exit 1
            }
            git pull -p
            cp "$PREFIX/etc/atm/main/bin/atm" "$PREFIX/bin/atm"
            cd "$_PWD" || {
                red "目录跳转失败！" >&2
                exit 1
            }
        else
            log_print " - ${G}您使用的是最新版本。${N}"
        fi
    elif [ -f "$ATMDIR/tmp/atmrc" ]; then
        rm -f "$ATMDIR/tmp/atmrc"
        log_print " - ${R}错误${N}。无法获取更新。"
        log_print " - 文件为空。"
    else
        log_print " - ${R}错误${N}。 未获取更新。"
    fi
    sleep 1
}

cleanup() {
    rm -rf ${ATMDIR}/tmp
}

# Save logs locally
save_logs() {
    for i in $LOGTOSAVE; do
        eval j="\$${i}"
        if [ "$j" ]; then
            log_handler "${i}=${j}"
        fi
    done
    cp -af "$_ATMLOG" "$EXTRALOG"
    cp -af "$VERLOG" "$EXTRALOG"
    cd "$EXTRALOG" || exit 1
    zip -Aq atm-full.logs atm.log atm-verbose.log
    rm -rf atm.log atm-verbose.log
}

# Saving logs and exit
exit_sh() {
    header "祝您有美好的一天 :)"
    echo ""
    echo ""
    cleanup
    # save_logs
    # echo " 日志将被保存至:"
    # echo -e " ${Y}${EXTRALOG}${N}"
    # echo ""
    exit 0
}

exit_error() {
    header "脚本出现错误"
    echo ""
    echo ""
    echo -e " ${C}U${N}${R}h${N} ${G}o${N}${Y}h${N}."
    log_handler "Something wrong"
    echo ""
    cleanup
    save_logs
    echo " 日志将被保存至:"
    echo -e " ${Y}${LOCALLOG}${N}"
    echo ""
    exit 0
}

check_pid() {
    PID=$(pgrep "aria2c" | grep -v grep | grep -v "service" | awk '{print $1}')
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
    echo -e "${R}[!]${N} Termux 镜像源不可用!"
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
    echo -e "${B}[*]${N} 检查网络环境及镜像源..."
    local current_mirror
    current_mirror=$(grep -P "^\s*deb\s+" /data/data/com.termux/files/usr/etc/apt/sources.list | grep -oP 'https?://[a-z0-9/._-]+')

    if timeout_test "google.com"; then
        if timeout_test "${current_mirror%/}/dists/stable/Release"; then
            echo -e "${G}[√]${N} 当前镜像源可用"
        else
            replace_mirrors
        fi
    elif [[ "$(hostname "$current_mirror")" == *".cn" ]]; then
        if timeout_test "${current_mirror%/}/dists/stable/Release"; then
            echo -e "${G}[√]${N} 当前镜像源可用"
        else
            replace_mirrors

        fi
    else
        replace_mirrors
    fi
}

Step() {
    echo -en "\n请回车以确认"
    read -r -n 1 INPUT
}

Configure_ARIA2CONF() {
    rm -rf ${WORKDIR}
    cp -r "${ATMGIT}/conf" "${WORKDIR}"
    set_file_prop dir "${DOWNLOADPATH}" "${ARIA2CONF}"
    set_file_prop input-file ${WORKDIR} "${ARIA2CONF}"
    set_file_prop save-session "${WORKDIR}/aria2.session" "${ARIA2CONF}"
    sed -i "s@/data/data/com.termux/files/home/.aria2/@${WORKDIR}/@" "${ARIA2CONF}"
    set_file_prop rpc-secret "$(date +%s%N | md5sum | head -c 20)" "${ARIA2CONF}"
    sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${DOWNLOADPATH}'@" "${WORKDIR}/*.sh"
    set_file_prop log "${ARIA2LOG}" "${ARIA2CONF}"
    mktouch ${WORKDIR}/aria2.session
    echo -e "${G}[√]${N} Aria2 配置文件处理完成！"
}

Installation_dependency() {
    echo -e "${B}[*]${N} 开始安装并配置依赖..."
    apt-get update -y &>/dev/null
    for i in nano ca-certificates findutils jq tar gzip dpkg curl aria2; do
        if apt list --installed 2>/dev/null | grep "$i"; then
            echo "  $i 已安装！"
        elif [ -e "$PREFIX"/bin/$i ]; then
            echo "  $i 已安装！"
        else
            echo "${G}[*]${N} Installing $i..."
            apt-get install -y $i || {
                echo -e "
${R}[!]${N} 依赖安装失败!
${B}[*]${N} 退出中……
									"
                exit 1
            }
        fi
    done
    apt-get upgrade -y
}

check_installed_status() {
    [[ ! -e ${aria2c} ]] && red "[!] Aria2 未安装!" && return 0
    [[ ! -e ${ARIA2CONF} ]] && red "
[!] Aria2 配置文件不存在！
[*] 如果你不是通过本脚本安装 Aria2，请先在本脚本卸载 Aria2！
	" && [[ $1 != "un" ]] && return 0
}

Install_aria2() {
    [[ -e ${aria2c} ]] && echo -e "${R}[!]${N} Aria2 已安装，如需重新安装请在脚本中卸载 Aria2！" && return 1
    check_mirrors
    Installation_dependency
    pkg i aria2 -y
    Configure_ARIA2CONF 2>${_ATMLOG} &
    e_spinner "${B}[*]${N} 开始检查配置文件..."
    aria2_RPC_port=${aria2_port}
    echo ""
    blue "[*] 开始创建下载目录..."
    check_storage
    mkdir -p "${DOWNLOADPATH}"
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
    $PREFIX/bin/aria2c --conf-path="${ARIA2CONF}" -D
    check_pid
    [[ -z ${PID} ]] && red "[!] Aria2 启动失败，请检查日志！" && return 1
}

Stop_aria2() {
    check_installed_status
    check_pid
    [[ -z ${PID} ]] && red "[!] Aria2 未启动，请检查日志 !" && return 0
    kill -9 "${PID}"
    blue "[*] 尝试关闭唤醒锁…"
    termux-wake-unlock
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
 ${G}[*]${N} Aria2 RPC 密钥不要包含等号(=)和井号(#)，留空则随机生成。

 当前 RPC 密钥为: ${G}${aria2_passwd_1}${N}
"
    echo -en " 请输入新的 RPC 密钥: "
    read -r aria2_RPC_passwd
    echo
    [[ -z "${aria2_RPC_passwd}" ]] && aria2_RPC_passwd=$(date +%s%N | md5sum | head -c 20)
    if [[ "${aria2_passwd}" != "${aria2_RPC_passwd}" ]]; then
        if [[ -z "${aria2_passwd}" ]]; then
            if echo -e "\nrpc-secret=${aria2_RPC_passwd}" >>"${ARIA2CONF}"; then
                echo -e "
${G}[√]${N} RPC 密钥修改成功！
新密钥为：${G}${aria2_RPC_passwd}${N}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} RPC 密钥修改失败！
旧密钥为：${R}${aria2_passwd}${N}
				"
            fi
        else
            if sed -i 's/^rpc-secret='"${aria2_passwd}"'/rpc-secret='"${aria2_RPC_passwd}"'/g' "${ARIA2CONF}"; then
                echo -e "
${G}[√]${N} RPC 密钥修改成功！
新密钥为：${G}${aria2_RPC_passwd}${N}"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} RPC 密钥修改失败！
旧密钥为：${G}${aria2_passwd}${N}
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
 当前 RPC 端口为: ${G}${aria2_port_1}${N}
"
    echo -en " 请输入新的 RPC 端口(默认: 6800): "
    read -r aria2_RPC_port
    echo
    [[ -z "${aria2_RPC_port}" ]] && aria2_RPC_port="6800"
    if [[ "${aria2_port}" != "${aria2_RPC_port}" ]]; then
        if [[ -z "${aria2_port}" ]]; then
            if echo -e "\nrpc-listen-port=${aria2_RPC_port}" >>"${ARIA2CONF}"; then
                echo -e "
${G}[*]${N} RPC 端口修改成功！
新端口为：${G}${aria2_RPC_port}${N}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} RPC 端口修改失败！
旧端口为：${G}${aria2_port}${N}"
            fi
        else
            if sed -i 's/^rpc-listen-port='"${aria2_port}"'/rpc-listen-port='"${aria2_RPC_port}"'/g' "${ARIA2CONF}"; then
                echo -e "
${G}[√]${N} RPC 端口修改成功！
新端口为：${G}${aria2_RPC_port}${N}
"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} RPC 端口修改失败！
旧端口为：${G}${aria2_port}${N}
				"
            fi
        fi
    else
        echo -e "${Y}[!]${N} 与旧配置一致，无需修改..."
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
 当前下载目录为: ${G}${aria2_dir_1}${N}
"
    echo -en " 请输入新的下载目录(默认: ${DOWNLOADPATH}): "
    read -r aria2_RPC_dir
    [[ -z "${aria2_RPC_dir}" ]] && aria2_RPC_dir="${DOWNLOADPATH}"
    mkdir -p "${aria2_RPC_dir}"
    echo
    if [[ "${aria2_dir}" != "${aria2_RPC_dir}" ]]; then
        if [[ -z "${aria2_dir}" ]]; then
            if echo -e "\ndir=${aria2_RPC_dir}" >>"${ARIA2CONF}"; then
                echo -e "
${G}[√]${N} 下载目录修改成功！
新位置为：${G}${aria2_RPC_dir}${N}(配置文件中缺少相关选项参数，已自动加入配置文件底部)
				"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} 下载目录修改失败！
旧位置为：${G}${aria2_dir}${N}
"
            fi
        else
            aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
            aria2_RPC_dir_2=$(echo "${aria2_RPC_dir}" | sed 's/\//\\\//g')
            if sed -i "s@^\(dir=\).*@\1${aria2_RPC_dir_2}@" "${ARIA2CONF}" && sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_RPC_dir_2}'@" "${WORKDIR}/*.sh"; then
                echo -e "
${G}[√]${N} 下载目录修改成功！
新位置为：${G}${aria2_RPC_dir}${N}
"
                if [[ ${read_123} != "1" ]]; then
                    source "$ATMGIT/core/restart-aria2.sh"
                fi
            else
                echo -e "
${R}[!]${N} 下载目录修改失败！
旧位置为：${G}${aria2_dir}${N}"
            fi
        fi
    else
        echo -e "${Y}[!]${N} 与旧配置一致，无需修改..."
    fi
}

Set_aria2_RPC_passwd_port_dir() {
    Read_config
    Set_aria2_RPC_passwd "1"
    Set_aria2_RPC_port "1"
    Set_aria2_RPC_dir "1"
    source "$ATMGIT/core/restart-aria2.sh"
}

Reset_ARIA2CONF() {
    Read_config
    aria2_port_old=${aria2_port}
    echo -e "
${R}[!]${N} 此操作将重置 Aria2 配置文件，所有已设定的配置将丢失。

按任意键继续，按 Ctrl+C 组合键取消"
    read -r -n 1 line
    Configure_ARIA2CONF 2>${_ATMLOG} &
    e_spinner "${B}[*]${N} 开始检查配置文件..."
    Read_config
    if [[ ${aria2_port_old} != "${aria2_port}" ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    source "${ATMGIT}/core/restart-aria2.sh"
}

Read_config() {
    status_type=$1
    if [[ ! -e ${ARIA2CONF} ]]; then
        if [[ ${status_type} != "un" ]]; then
            echo -e "${R}[!]${N} Aria2 配置文件不存在 !" && return 0
        fi
    else
        aria2_dir=$(grep "^dir=" "${ARIA2CONF}" | grep -v '#' | awk -F "=" '{print $NF}')
        aria2_port=$(grep "^rpc-listen-port=" "${ARIA2CONF}" | grep -v '#' | awk -F "=" '{print $NF}')
        aria2_passwd=$(grep "^rpc-secret=" "${ARIA2CONF}" | grep -v '#' | awk -F "=" '{print $NF}')
    fi
}

View_Log() {
    [[ ! -e ${ARIA2LOG} ]] && echo -e "${R}[!]${N} Aria2 日志文件不存在 !" && return 0
    echo && echo -e "

${G}[!]${N} 按 ${G}Ctrl+C${N} 终止查看日志
如果需要查看完整日志内容，请用 ${G}cat ${ARIA2LOG}${N} 命令。

"
    tail -f "${ARIA2LOG}"
}

Clean_Log() {
    [[ ! -e ${ARIA2LOG} ]] && echo -e "${R}[!]${N} Aria2 日志文件不存在 !" && echo -en "\n\n请回车以继续" && read -r -n 1 line && return 0
    echo >"${ARIA2LOG}"
    echo -e "${G}[√]${N} Aria2 日志已清空 !"
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}

Update_bt_tracker() {
    check_installed_status
    check_pid
    if [ -z "$PID" ]; then
        bash "${ATMGIT}/script/tracker.sh" "${ARIA2CONF}" 2>${_ATMLOG}
    else
        bash "${ATMGIT}/script/tracker.sh" "${ARIA2CONF}" RPC 2>${_ATMLOG}
    fi
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}

Uninstall_aria2() {
    check_installed_status "un"
    if ask "确定要卸载 Aria2 ? " "N"; then
        check_pid
        [[ -n $PID ]] && kill -9 "${PID}" && termux-wake-unlock
        apt purge -y aria2 2>"${_ATMLOG}"
        Read_config "un"
        rm -rf "${aria2c}"
        rm -rf "${WORKDIR}"
        rm -f "$HOME/.termux/boot/auto-start-aria2"
        echo -e "\n${G}[√]${N} Aria2 卸载完成！\n"
    else
        echo && echo "${Y}[*]${N} 卸载已取消..." && echo
    fi
    echo -en "\n\n请回车以继续"
    read -r -n 1 line
}
