#!$PREFIX/bin/bash
#=============================================================
# https://github.com/QingxuMo/Aria2-Termux
# Doc: https://github.com/QingxuMo/Aria2-Termux/blob/master/README.md
# More detail: https://qingxu.live/index.php/archives/aria2-for-termux/
# Description: Aria2 One-click installation management script for Termux
# Environment Required: Android with the latest Termux. (The latest Android version is recommended)
# Version: 1.0.3
# Author: QingxuMo
# Blog: https://qingxu.live
#=============================================================

sh_ver="1.0.3"
ver_code="20201023"
#PATH=/data/data/com.termux/files/usr/bin
#export PATH
aria2_conf_dir="$HOME/.aria2"
download_path="/sdcard/Download"
aria2_conf="${aria2_conf_dir}/aria2.conf"
aria2_log="${aria2_conf_dir}/aria2.log"
aria2c="$PREFIX/bin/aria2c"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

check_root() {
    [[ $EUID = 0 ]] && echo -e "${Error} 检测到您正在尝试用 ROOT 权限运行脚本\n这是不建议也不被允许的\n请勿在任何情况下以 ROOT 权限运行该脚本,以避免造成无法预料的损失" && exit 1
}

#检查系统
check_sys() {
	if [[ ! -d /system/app/ && ! -d /system/priv-app ]]; then
		echo -e "${Error} Unsupported system!"
		return 0
	fi
	ARCH=$(uname -m)
	[ $(command -v dpkg) ] && dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
}

check_script_download() {
	[[ ! -d $PREFIX/etc/tiviw ]] || [[ ! -f "./aria2.sh" ]] && pkg in wget -y && wget -N https://cdn.jsdelivr.net/gh/QingxuMo/Aria2-Termux@master/aria2.sh && chmod +x aria2.sh
}

check_installed_status() {
	[[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 没有安装，请检查 !" && return 0
	[[ ! -e ${aria2_conf} ]] && echo -e "${Error} Aria2 配置文件不存在，请检查 !" && [[ $1 != "un" ]] && return 0
}

check_pid() {
	PID=$(ps -ef | grep "aria2c" | grep -v grep | grep -v "aria2.sh" | grep -v "service" | awk '{print $2}')
}

check_storage() {
    [[ ! -d "$HOME/storage/shared/Android/" ]] && echo -e "${Info} Termux 未获取存储权限，请回车确认后按指示授权存储权限！" && echo -en "\n请回车以确认" && read -n 1 line && termux-setup-storage
    [[ ! -d "$HOME/storage/shared/Android/" ]] && echo -e "${Error} Termux 存储权限未获取！请在确保 Termux 已获取存储权限的情况重新启动脚本！" && exit 1
    echo -e "${Info} 检查下载目录中…" && mkdir -p $download_path
}
    
check_mirrors() {
	mirrors_status=$(cat $PREFIX/etc/apt/sources.list | grep "mirror" | grep -v '#')
	if [ -z "$mirrors_status" ]; then
		echo -e "${Info}  Termux 镜像源未配置！"
		echo -e "对于国内用户，添加清华源作为镜像源可以有效增强 Termux 软件包下载速度"
		echo -en "是否添加清华源？[y/n]"
		read mirror_choose
		case $mirror_choose in
			y)
				sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
				sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
				sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
				echo -e "${Info} 镜像源配置成功，即将进行软件包升级"
				echo -e "${Info} 如果你从未进行 apt upgrade 或 pkg up，下面可能需要你手动确认一些东西"
				echo -e "${Info} 如果看不懂选项请直接回车！"
				apt update && apt upgrade -y
				;;
			n)
				echo -e "${Info} 使用默认源进行安装"
				;;
			*)
				echo -e "${Info} 跳过，使用默认源进行安装"
				;;
		esac
	fi
}

Download_aria2_conf() {
    PROFILE_URL1="https://one.qingxu.ga/onedrive/aira2"
    PROFILE_URL2="https://share.qingxu.ga/onedrive/aria2"
    PROFILE_URL3="https://cdn.jsdelivr.net/gh/QingxuMo/aria2.conf@master"
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
"
    mkdir -p "${aria2_conf_dir}" && cd "${aria2_conf_dir}"
    for PROFILE in ${PROFILE_LIST}; do
        [[ ! -f ${PROFILE} ]] && rm -rf ${PROFILE}
        wget -N -t2 -T3 ${PROFILE_URL1}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL2}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL3}/${PROFILE}
        [[ ! -s ${PROFILE} ]] && {
            echo -e "${Error} '${PROFILE}' 下载失败！清理残留文件..."
            rm -vrf "${aria2_conf_dir}"
            exit 1
        }
    done
    sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${download_path}'@" ${aria2_conf_dir}/*.sh
    sed -i "s@^\(dir=\).*@\1${download_path}@" ${aria2_conf}
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" ${aria2_conf_dir}/{*.sh,aria2.conf}
    sed -i "s@^\(rpc-secret=\).*@\1$(date +%s%N | md5sum | head -c 20)@" ${aria2_conf}
    sed -i "s@#log=@log=${aria2_log}@" ${aria2_conf}
    touch aria2.session
    chmod +x *.sh
    echo -e "${Info} Aria2 配置文件下载完成！"
}

Installation_dependency() {
        apt-get update
        apt-get install nano ca-certificates findutils jq tar gzip dpkg -y
    if [[ ! -s /data/data/com.termux/files/etc/ssl/certs/ca-certificates.crt ]]; then
        wget -qO- git.io/Jfj2u | bash
    fi
}

Install_aria2() {
	check_root
	[[ -e ${aria2c} ]] && echo -e "${Error} Aria2 已安装，请检查 !" && return 0
	check_sys
	check_mirrors
	echo -e "${Info} 开始安装并配置依赖..."
	Installation_dependency
	echo -e "${Info} 开始下载并安装主程序..."
	pkg in aria2 -y
	echo -e "${Info} 开始下载 Aria2 配置文件..."
	Download_aria2_conf
	aria2_RPC_port=${aria2_port}
	echo -e "${Info} 开始创建下载目录..."
	check_storage
	mkdir -p ${download_path}
	echo -e "${Info} 所有步骤执行完毕，开始启动..."
	Start_aria2
}


check_start_debug() {
	start_time=$(date +"%Y-%m-%d %H:%M:%S" -d '-1 minutes')
	stop_time=$(date +"%Y-%m-%d %H:%M:%S")
	tac $aria2_log | awk -v st="$start_time" -v et="$stop_time" '{t=substr($2,RSTART+14,21);if(t>=st && t<=et) {print $0}}' | awk '{print $1}' | sort | uniq -c | sort -nr > $aria2_conf_dir/debug.log
	port_error=$(cat $aria2_conf_dir/debug.log | grep "cause: Address already in use")
	[[ ! -z "$port_error" ]] && echo -e "${Error} 错误自动检测结果：Aria2 端口被占用！\n请修改当前 Aria2 端口或杀死占用端口的进程！"
}

Start_aria2() {
	check_installed_status
	check_pid
	rm -f $aria2_conf_dir/debug.log
	[[ ! -z ${PID} ]] && echo -e "${Error} Aria2 正在运行，请检查 !" && return 1
	aria2c --conf-path=${aria2_conf} -D
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Aria2 启动失败，请检查日志！" && return 1
	check_storage
	echo -e "${Info} 尝试开启唤醒锁…"
	termux-wake-lock
}
Stop_aria2() {
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Aria2 没有运行，请检查 !" && return 0
	kill -9 ${PID}
}
Restart_aria2() {
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && kill -9 ${PID}
	check_storage
	aria2c --conf-path=${aria2_conf} -D
	echo -e "${Info} 尝试开启唤醒锁…"
	termux-wake-lock
}
Set_aria2() {
	check_installed_status
	echo -e "
 ${Green_font_prefix}1.${Font_color_suffix} 修改 Aria2 RPC 密钥
 ${Green_font_prefix}2.${Font_color_suffix} 修改 Aria2 RPC 端口
 ${Green_font_prefix}3.${Font_color_suffix} 修改 Aria2 下载目录
 ${Green_font_prefix}4.${Font_color_suffix} 修改 Aria2 密钥 + 端口 + 下载目录
 ${Green_font_prefix}5.${Font_color_suffix} 手动 打开配置文件修改
 ————————————
 ${Green_font_prefix}0.${Font_color_suffix} 重置/更新 Aria2 配置文件
"
	echo -en " 请输入数字 [0-5]: "
	read aria2_modify
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
	elif [[ ${aria2_modify} == "0" ]]; then
		Reset_aria2_conf
	else
		echo
		echo -e " ${Error} 请输入正确的数字"
		return 0
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
 ${Tip} Aria2 RPC 密钥不要包含等号(=)和井号(#)，留空则随机生成。

 当前 RPC 密钥为: ${Green_font_prefix}${aria2_passwd_1}${Font_color_suffix}
"
    echo -en " 请输入新的 RPC 密钥: "
    read aria2_RPC_passwd
    echo
    [[ -z "${aria2_RPC_passwd}" ]] && aria2_RPC_passwd=$(date +%s%N | md5sum | head -c 20)
    if [[ "${aria2_passwd}" != "${aria2_RPC_passwd}" ]]; then
        if [[ -z "${aria2_passwd}" ]]; then
            echo -e "\nrpc-secret=${aria2_RPC_passwd}" >>${aria2_conf}
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} RPC 密钥修改成功！新密钥为：${Green_font_prefix}${aria2_RPC_passwd}${Font_color_suffix}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} RPC 密钥修改失败！旧密钥为：${Green_font_prefix}${aria2_passwd}${Font_color_suffix}"
            fi
        else
            sed -i 's/^rpc-secret='${aria2_passwd}'/rpc-secret='${aria2_RPC_passwd}'/g' ${aria2_conf}
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} RPC 密钥修改成功！新密钥为：${Green_font_prefix}${aria2_RPC_passwd}${Font_color_suffix}"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} RPC 密钥修改失败！旧密钥为：${Green_font_prefix}${aria2_passwd}${Font_color_suffix}"
            fi
        fi
    else
        echo -e "${Error} 与旧配置一致，无需修改..."
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
 当前 RPC 端口为: ${Green_font_prefix}${aria2_port_1}${Font_color_suffix}
"
    read -en -p " 请输入新的 RPC 端口(默认: 6800): " aria2_RPC_port
    echo
    [[ -z "${aria2_RPC_port}" ]] && aria2_RPC_port="6800"
    if [[ "${aria2_port}" != "${aria2_RPC_port}" ]]; then
        if [[ -z "${aria2_port}" ]]; then
            echo -e "\nrpc-listen-port=${aria2_RPC_port}" >>${aria2_conf}
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} RPC 端口修改成功！新端口为：${Green_font_prefix}${aria2_RPC_port}${Font_color_suffix}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                
                
                
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} RPC 端口修改失败！旧端口为：${Green_font_prefix}${aria2_port}${Font_color_suffix}"
            fi
        else
            sed -i 's/^rpc-listen-port='${aria2_port}'/rpc-listen-port='${aria2_RPC_port}'/g' ${aria2_conf}
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} RPC 端口修改成功！新端口为：${Green_font_prefix}${aria2_RPC_port}${Font_color_suffix}"
                
                
                
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} RPC 端口修改失败！旧端口为：${Green_font_prefix}${aria2_port}${Font_color_suffix}"
            fi
        fi
    else
        echo -e "${Error} 与旧配置一致，无需修改..."
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
 当前下载目录为: ${Green_font_prefix}${aria2_dir_1}${Font_color_suffix}
"
    read -e -p " 请输入新的下载目录(默认: ${download_path}): " aria2_RPC_dir
    [[ -z "${aria2_RPC_dir}" ]] && aria2_RPC_dir="${download_path}"
    mkdir -p ${aria2_RPC_dir}
    echo
    if [[ "${aria2_dir}" != "${aria2_RPC_dir}" ]]; then
        if [[ -z "${aria2_dir}" ]]; then
            echo -e "\ndir=${aria2_RPC_dir}" >>${aria2_conf}
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} 下载目录修改成功！新位置为：${Green_font_prefix}${aria2_RPC_dir}${Font_color_suffix}(配置文件中缺少相关选项参数，已自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} 下载目录修改失败！旧位置为：${Green_font_prefix}${aria2_dir}${Font_color_suffix}"
            fi
        else
            aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
            aria2_RPC_dir_2=$(echo "${aria2_RPC_dir}" | sed 's/\//\\\//g')
            sed -i "s@^\(dir=\).*@\1${aria2_RPC_dir_2}@" ${aria2_conf}
            sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_RPC_dir_2}'@" ${aria2_conf_dir}/*.sh
            if [[ $? -eq 0 ]]; then
                echo -e "${Info} 下载目录修改成功！新位置为：${Green_font_prefix}${aria2_RPC_dir}${Font_color_suffix}"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else
                echo -e "${Error} 下载目录修改失败！旧位置为：${Green_font_prefix}${aria2_dir}${Font_color_suffix}"
            fi
        fi
    else
        echo -e "${Error} 与旧配置一致，无需修改..."
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
 配置文件位置：${Green_font_prefix}${aria2_conf}${Font_color_suffix}

 ${Tip} 手动修改配置文件须知：
 
 ${Green_font_prefix}1.${Font_color_suffix} 默认使用 nano 文本编辑器打开
 ${Green_font_prefix}2.${Font_color_suffix} 退出并保存文件：按 ${Green_font_prefix}Ctrl+X${Font_color_suffix} 组合键，输入 ${Green_font_prefix}y${Font_color_suffix} ，按 ${Green_font_prefix}Enter${Font_color_suffix} 键
 ${Green_font_prefix}3.${Font_color_suffix} 退出不保存文件：按 ${Green_font_prefix}Ctrl+X${Font_color_suffix} 组合键，输入 ${Green_font_prefix}n${Font_color_suffix}
 ${Green_font_prefix}4.${Font_color_suffix} nano 详细使用教程：${Green_font_prefix}https://p3terx.com/archives/linux-nano-tutorial.html${Font_color_suffix}
 "
    echo "按任意键继续，按 Ctrl+C 组合键取消"
    read var
    nano "${aria2_conf}"
    Read_config
    if [[ ${aria2_port_old} != ${aria2_port} ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    if [[ ${aria2_dir_old} != ${aria2_dir} ]]; then
        mkdir -p ${aria2_dir}
        aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
        aria2_dir_old_2=$(echo "${aria2_dir_old}" | sed 's/\//\\\//g')
        sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_dir_2}'@" ${aria2_conf_dir}/*.sh
    fi
    Restart_aria2
}
Reset_aria2_conf() {
    Read_config
    aria2_port_old=${aria2_port}
    echo
    echo -e "${Tip} 此操作将重新下载 Aria2 配置文件，所有已设定的配置将丢失。"
    echo
    read -e -p "按任意键继续，按 Ctrl+C 组合键取消" var
    Download_aria2_conf
    Read_config
    if [[ ${aria2_port_old} != ${aria2_port} ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    Restart_aria2
}

Read_config() {
	status_type=$1
	if [[ ! -e ${aria2_conf} ]]; then
		if [[ ${status_type} != "un" ]]; then
			echo -e "${Error} Aria2 配置文件不存在 !" && return 0
		fi
	else
		conf_text=$(cat ${aria2_conf} | grep -v '#')
		aria2_dir=$(echo -e "${conf_text}" | grep "^dir=" | awk -F "=" '{print $NF}')
		aria2_port=$(echo -e "${conf_text}" | grep "^rpc-listen-port=" | awk -F "=" '{print $NF}')
		aria2_passwd=$(echo -e "${conf_text}" | grep "^rpc-secret=" | awk -F "=" '{print $NF}')
		aria2_bt_port=$(echo -e "${conf_text}" | grep "^listen-port=" | awk -F "=" '{print $NF}')
		aria2_dht_port=$(echo -e "${conf_text}" | grep "^dht-listen-port=" | awk -F "=" '{print $NF}')
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
        unset $TMPLOCALIP
	    TMPLOCALIP=$LOCALIP
    done
    echo $TMPLOCALIP
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
        AriaNg_URL="http://mirror-aria2.qingxu.live/${AriaNg_API}"
    fi
    clear
    echo -e "\nAria2 简单配置信息：\n
 IPv4 地址\t: ${Green_font_prefix}${IPV4}${Font_color_suffix}
 IPv6 地址\t: ${Green_font_prefix}${IPV6}${Font_color_suffix}
 内网 IP 地址\t: ${Green_font_prefix}${LocalIP}${Font_color_suffix} 
 RPC 端口\t: ${Green_font_prefix}${aria2_port}${Font_color_suffix}
 RPC 密钥\t: ${Green_font_prefix}${aria2_passwd}${Font_color_suffix}
 下载目录\t: ${Green_font_prefix}${aria2_dir}${Font_color_suffix}
 AriaNg 链接\t: ${Green_font_prefix}${AriaNg_URL}${Font_color_suffix}\n"
 echo -en "\n\n请回车以继续" && read -n 1 line
}

View_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && return 0
    echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo -e "如果需要查看完整日志内容，请用 ${Red_font_prefix}cat ${aria2_log}${Font_color_suffix} 命令。" && echo
    tail -f ${aria2_log}
}

Clean_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && echo -en "\n\n请回车以继续" && read -n 1 line && return 0
    echo >${aria2_log}
    echo -e "${Info} Aria2 日志已清空 !"
    echo -en "\n\n请回车以继续"
    read -n 1 line
}

Update_bt_tracker() {
    check_installed_status
    check_pid
    [[ -z $PID ]] && {
        bash <(wget -qO- one.qingxu.ga/onedrive/aira2/tracker.sh) ${aria2_conf}
    } || {
        bash <(wget -qO- one.qingxu.ga/onedrive/aira2/tracker.sh) ${aria2_conf} RPC
    }
    echo -en "\n\n请回车以继续"
    read -n 1 line
}

Uninstall_aria2() {
    check_installed_status "un"
    echo "确定要卸载 Aria2 ? (y/N)"
    echo -en "(默认: n):"
    read unyn
    [[ -z ${unyn} ]] && unyn="n"
    if [[ ${unyn} == [Yy] ]]; then
        apt purge -y aria2
        check_pid
        [[ ! -z $PID ]] && kill -9 ${PID}
        Read_config "un"
        rm -rf "${aria2c}"
        rm -rf "${aria2_conf_dir}"
        echo && echo "Aria2 卸载完成 !" && echo
    else
        echo && echo "卸载已取消..." && echo
    fi
    echo -en "\n\n请回车以继续"
    read -n 1 line
}

Update_Shell() {
    sh_new_ver=$(wget -qO- -t1 -T3 "https://raw.githubusercontent.com/QingxuMo/Aria2-Termux/master/aria2.sh" | grep 'ver_code="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1) && sh_new_type="github"
    [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
    if [ -f "$PREFIX/etc/tiviw/aria2.sh.bak2" ]; then
	    rm -f $PREFIX/etc/tiviw/aria2.sh.bak2
    fi
    if [ -f "$PREFIX/etc/tiviw/aria2.sh.bak" ]; then
	    mv $PREFIX/etc/tiviw/aria2.sh.bak $PREFIX/etc/tiviw/aria2.sh.bak2
    fi
    if [[ -d $PREFIX/etc/tiviw ]]; then
	    echo "检测到 Tiviw! 启用 Tiviw 更新方案!"
	    mkdir -p $PREFIX/etc/tiviw/aria2
	    mv $PREFIX/etc/tiviw/aria2/aria2.sh $PREFIX/etc/tiviw/aria2/aria2.sh.bak
	    wget -P $PREFIX/etc/tiviw/aria2 https://raw.githubusercontent.com/QingxuMo/Aria2-Termux/master/aria2.sh && chmod +x $PREFIX/etc/tiviw/aria2/aria2.sh
	    return 0
    else
	    wget -N "https://raw.githubusercontent.com/QingxuMo/Aria2-Termux/master/aria2.sh" && chmod +x aria2.sh
    fi
    echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}


while [ 1 ]
do
	check_script_download
echo && echo -e " Aria2 一键安装管理脚本 (Termux 移植版) ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix} 
                    by \033[1;35mQingxu(QingxuMo)\033[0m
 ${Green_font_prefix} 0.${Font_color_suffix} 退出
 ———————————————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Aria2
 ${Green_font_prefix} 2.${Font_color_suffix} 卸载 Aria2
 ———————————————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 启动 Aria2
 ${Green_font_prefix} 4.${Font_color_suffix} 停止 Aria2
 ${Green_font_prefix} 5.${Font_color_suffix} 重启 Aria2
 ———————————————————————
 ${Green_font_prefix} 6.${Font_color_suffix} 修改 配置
 ${Green_font_prefix} 7.${Font_color_suffix} 查看 配置
 ${Green_font_prefix} 8.${Font_color_suffix} 查看 日志
 ${Green_font_prefix} 9.${Font_color_suffix} 清空 日志
 ———————————————————————
 ${Green_font_prefix} 10.${Font_color_suffix} 一键更新 BT-Tracker
 ${Green_font_prefix} 11.${Font_color_suffix} 一键更新脚本
 ———————————————————————" && echo
if [[ -e ${aria2c} ]]; then
    check_pid
    if [[ ! -z "${PID}" ]]; then
        echo -e " Aria2 状态: ${Green_font_prefix}已安装${Font_color_suffix} | ${Green_font_prefix}已启动${Font_color_suffix}"
    else
        echo -e " Aria2 状态: ${Green_font_prefix}已安装${Font_color_suffix} | ${Red_font_prefix}未启动${Font_color_suffix}"
    fi
else
    echo -e " Aria2 状态: ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo -en " 请输入数字 [0-11]:"
read num
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
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
done
clear
