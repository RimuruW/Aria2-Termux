#!/bin/bash
#=============================================================
# https://github.com/huanruomengyun/Aria2-Termux
# Description: Aria2 One-click installation management script for Termux
# System Required: Android
# Version: 1.6.27
# Author: huanruomengyun
# Blog: https://qingxu.ga
#=============================================================

sh_ver="1.6.27"
PATH=/data/data/com.termux/files/usr/bin
export PATH
aria2_conf_dir="$HOME/.aria2"
download_path="/sdcard/Download"
aria2_conf="${aria2_conf_dir}/aria2.conf"
aria2_log="${aria2_conf_dir}/aria2.log"
aria2c="/data/data/com.termux/files/usr/bin/aria2c"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

check_root() {
    [[ $EUID = 0 ]] && echo -e "${Error} 检测到您正在尝试用 ROOT 权限运行脚本\n这是不建议也不被允许的\n请勿在任何情况下以 ROOT 权限运行该脚本,以避免造成无法预料的损失" && return 0
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
check_installed_status() {
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 没有安装，请检查 !" && return 0
    [[ ! -e ${aria2_conf} ]] && echo -e "${Error} Aria2 配置文件不存在，请检查 !" && [[ $1 != "un" ]] && return 0
}
check_pid() {
    PID=$(ps -ef | grep "aria2c" | grep -v grep | grep -v "aria2.sh" | grep -v "service" | awk '{print $2}')
}
check_ver_comparison() {
    aria2_now_ver=$(${aria2c} -v | head -n 1 | awk '{print $3}')
    [[ -z ${aria2_now_ver} ]] && echo -e "${Error} Aria2 当前版本获取失败 !" && return 0
    if [[ "${aria2_now_ver}" != "${aria2_new_ver}" ]]; then
        echo -e "${Info} 发现 Aria2 已有新版本 [ ${aria2_new_ver} ](当前版本：${aria2_now_ver})"
        read -e -p "是否更新(会中断当前下载任务，请注意) ? [Y/n] :" yn
        [[ -z "${yn}" ]] && yn="y"
        if [[ $yn == [Yy] ]]; then
            check_pid
            [[ ! -z $PID ]] && kill -9 ${PID}
            check_sys
            pkg in aria2 -y
            Start_aria2
        fi
    else
        echo -e "${Info} 当前 Aria2 已是最新版本 [ ${aria2_new_ver} ]" && return 0
    fi
}
Download_aria2_conf() {
    mkdir -p "${aria2_conf_dir}" && cd "${aria2_conf_dir}"
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/aria2.conf" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/aria2.conf" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/aria2.conf"
    [[ ! -s "aria2.conf" ]] && echo -e "${Error} Aria2 配置文件下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/upload.sh" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/upload.sh" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/upload.sh"
    [[ ! -s "upload.sh" ]] && echo -e "${Error} 附加功能脚本[upload.sh]下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/clean.sh" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/clean.sh" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/clean.sh"
    [[ ! -s "clean.sh" ]] && echo -e "${Error} 附加功能脚本[clean.sh]下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/delete.sh" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/delete.sh" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/delete.sh"
    [[ ! -s "delete.sh" ]] && echo -e "${Error} 附加功能脚本[delete.sh]下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/move.sh" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/move.sh" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/move.sh"
    [[ ! -s "move.sh" ]] && echo -e "${Error} 附加功能脚本[move.sh]下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/dht.dat" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/dht.dat" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/dht.dat"
    [[ ! -s "dht.dat" ]] && echo -e "${Error} Aria2 DHT（IPv4）文件下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    wget -N -t2 -T3 "https://p3terx.github.io/aria2.conf/dht6.dat" ||
        wget -N -t2 -T3 "https://aria2c.now.sh/dht6.dat" ||
        wget -N -t2 -T3 "https://gh.p3terx.workers.dev/aria2.conf/master/dht6.dat"
    [[ ! -s "dht6.dat" ]] && echo -e "${Error} Aria2 DHT（IPv6）文件下载失败 !" && rm -rf "${aria2_conf_dir}" && exit 1
    touch aria2.session
    chmod +x *.sh
    sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${download_path}'@" ${aria2_conf_dir}/*.sh
    sed -i "s@^\(dir=\).*@\1${download_path}@" ${aria2_conf}
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" ${aria2_conf_dir}/{*.sh,aria2.conf}
    sed -i "s@^\(rpc-secret=\).*@\1$(date +%s%N | md5sum | head -c 20)@" ${aria2_conf}
    echo -e "${Info} Aria2 完美配置下载完成！"
}
Installation_dependency() {
        apt-get update
        apt-get install nano ca-certificates findutils jq tar gzip dpkg screen -y
    if [[ ! -s /data/data/com.termux/files/etc/ssl/certs/ca-certificates.crt ]]; then
        wget -qO- git.io/Jfj2u | bash
    fi
}
Install_aria2() {
    [[ -e ${aria2c} ]] && echo -e "${Error} Aria2 已安装，请检查 !" && return 0
    check_sys
    echo -e "${Info} 开始安装/配置 依赖..."
    Installation_dependency
    echo -e "${Info} 开始下载/安装 主程序..."
    pkg in aria2 -y
    echo -e "${Info} 开始下载/安装 Aria2 完美配置..."
    Download_aria2_conf
    echo -e "${Info} 开始下载/安装 服务脚本(init)..."
    Read_config
    aria2_RPC_port=${aria2_port}
    echo -e "${Info} 开始创建 下载目录..."
    mkdir -p ${download_path}
    echo -e "${Info} 所有步骤 安装完毕，开始启动..."
    Start_aria2
}
Start_aria2() {
    check_installed_status
    check_pid
    [[ ! -z ${PID} ]] && echo -e "${Error} Aria2 正在运行，请检查 !" && return 0
    aria2c --conf-path=${aria2_conf} -D
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
    aria2c --conf-path=${aria2_conf} -D
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
 ${Green_font_prefix}0.${Font_color_suffix} 重置/更新 Aria2 完美配置
"
    echo " 请输入数字 [0-5]:"
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
 ${Tip} Aria2 RPC 密钥不要包含等号(=)和井号(#)，留空为随机生成。

 当前 RPC 密钥为: ${Green_font_prefix}${aria2_passwd_1}${Font_color_suffix}
"
    echo " 请输入新的 RPC 密钥: "
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
    read -e -p " 请输入新的 RPC 端口(默认: 6800): " aria2_RPC_port
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
 ${Green_font_prefix}5.${Font_color_suffix} 配置文件有中文注释，若语言设置有问题会导致中文乱码
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
    echo -e "${Tip} 此操作将重新下载 Aria2 完美配置方案，所有已设定的配置将丢失。"
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
        wget -qO- -t1 -T2 -4 ip.sb ||
            wget -qO- -t1 -T2 -4 ifconfig.io ||
            wget -qO- -t1 -T2 -4 www.trackip.net/ip
    )
    [[ -z "${IPV4}" ]] && IPV4="IPv4 地址检测失败"
    IPV6=$(
        wget -qO- -t1 -T2 -6 ip.sb ||
            wget -qO- -t1 -T2 -6 ifconfig.io ||
            wget -qO- -t1 -T2 -6 www.trackip.net/ip
    )
    [[ -z "${IPV6}" ]] && IPV6="IPv6 地址检测失败"
    [[ -z "${aria2_dir}" ]] && aria2_dir="找不到配置参数"
    [[ -z "${aria2_port}" ]] && aria2_port="找不到配置参数"
    [[ -z "${aria2_passwd}" ]] && aria2_passwd="找不到配置参数(或无密钥)"
    clear
    echo -e "\nAria2 简单配置信息：\n
 IPv4 地址\t: ${Green_font_prefix}${IPV4}${Font_color_suffix}
 IPv6 地址\t: ${Green_font_prefix}${IPV6}${Font_color_suffix}
 RPC 端口\t: ${Green_font_prefix}${aria2_port}${Font_color_suffix}
 RPC 密钥\t: ${Green_font_prefix}${aria2_passwd}${Font_color_suffix}
 下载目录\t: ${Green_font_prefix}${aria2_dir}${Font_color_suffix}\n"
 echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
}
View_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && return 0
    echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo -e "如果需要查看完整日志内容，请用 ${Red_font_prefix}cat ${aria2_log}${Font_color_suffix} 命令。" && echo
    tail -f ${aria2_log}
}
Clean_Log() {
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && echo -en "\n\n\t\t\t点击任意键以继续" && read -n 1 line && return 0
    echo >${aria2_log}
    echo -e "${Info} Aria2 日志已清空 !"
    echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
}

bt_auto_status() {
	if [ -f "$PREFIX/etc/tconfig/aria2btauto" ];then
		bt_update_status=y
	else
		unset bt_update_status
	fi
}

Update_bt_tracker_cron() {
    check_installed_status
    bt_auto_status
    if [[ -z $bt_update_status ]]; then
        echo
        echo -e " 是否开启 ${Green_font_prefix}自动更新 BT-Tracker${Font_color_suffix} 功能？(可能会增强 BT 下载速率)[Y/n] \c"
        read bt_auto_update_status
        [[ -z "${bt_update_status}" ]] && bt_auto_update_status="y"
        if [[ ${bt_auto_update_status} == [Yy] ]]; then
            bt_auto_update_start
        else
            echo && echo " 已取消..."
        fi
    else
        echo
        echo -e " 是否关闭 ${Red_font_prefix}自动更新 BT-Tracker${Font_color_suffix} 功能？[y/N] \c"
        read bt_auto_update_status
        [[ -z "${bt_update_status}" ]] && bt_update_status="n"
        if [[ ${bt_auto_update_status} == [Yy] ]]; then
            bt_update_stop
        else
            echo && echo " 已取消..."
        fi
    fi
    echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
}
bt_auto_update_start() {
    touch $PREFIX/etc/tconfig/aria2btauto
    bt_auto_status
    if [[ -z $bt_update_status ]]; then
        echo && echo -e "${Error} 自动更新 BT-Tracker 开启失败 !" && return 0
    else
        Update_bt_tracker
        echo && echo -e "${Info} 自动更新 BT-Tracker 开启成功 !"
    fi
}
bt_update_stop() {
     rm -f $PREFIX/etc/tconfig/aria2btauto
     bt_auto_status
    if [[ -n $bt_update_status ]]; then
        echo && echo -e "${Error} 自动更新 BT-Tracker 关闭失败 !" && return 0
    else
        echo && echo -e "${Info} 自动更新 BT-Tracker 关闭成功 !"
    fi
}
Update_bt_tracker() {
    check_installed_status
    check_pid
    [[ -z $PID ]] && {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}
    } || {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf} RPC
    }
    echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
}
Update_aria2() {
    check_installed_status
    check_ver_comparison
}
Uninstall_aria2() {
    check_installed_status "un"
    echo "确定要卸载 Aria2 ? (y/N)"
    echo -en "(默认: n):"
    read unyn
    [[ -z ${unyn} ]] && unyn="n"
    if [[ ${unyn} == [Yy] ]]; then
       yes | apt remove aria2
        rm -f $PREFIX/etc/tconfig/aria2btauto
        check_pid
        [[ ! -z $PID ]] && kill -9 ${PID}
        Read_config "un"
        rm -rf "${aria2c}"
        rm -rf "${aria2_conf_dir}"
        echo && echo "Aria2 卸载完成 !" && echo
    else
        echo && echo "卸载已取消..." && echo
    fi
    echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
}

Update_Shell() {
    sh_new_ver=$(wget -qO- -t1 -T3 "https://raw.githubusercontent.com/huanruomengyun/Aria2-Termux/master/aria2.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1) && sh_new_type="github"
    [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
    if [ -f "$PREFIX/etc/tconfig/aria2.sh.bak2" ]; then
	    rm -f $PREFIX/etc/tconfig/aria2.sh.bak2
    fi
    if [ -f "$PREFIX/etc/tconfig/aria2.sh.bak" ]; then
	    mv $PREFIX/etc/tconfig/aria2.sh.bak $PREFIX/etc/tconfig/aria2.sh.bak2
    fi
    if [[ -d $PREFIX/etc/tconfig ]]; then
	    echo "检测到 Termux Tools! 启用 Termux Tools 更新方案!"
	    mv $PREFIX/etc/tconfig/aria2.sh $PREFIX/etc/tconfig/aria2.sh.bak
	    wget -P $PREFIX/etc/tconfig https://raw.githubusercontent.com/huanruomengyun/Aria2-Termux/master/aria2.sh && chmod +x $PREFIX/etc/tconfig/aria2.sh
	    return 0
    fi
    wget -N "https://raw.githubusercontent.com/huanruomengyun/Aria2-Termux/master/aria2.sh" && chmod +x aria2.sh
    echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}
while [ 1 ]
do
	mkdir -p $PREFIX/etc/tconfig
echo && echo -e " Aria2 一键安装管理脚本 (Termux 移植版) ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix} 
                    by \033[1;35mQingxu(huanruomengyun)\033[0m
 ${Green_font_prefix} 0.${Font_color_suffix} 退出
 ———————————————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Aria2
 ${Green_font_prefix} 2.${Font_color_suffix} 更新 Aria2
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载 Aria2
 ———————————————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 启动 Aria2
 ${Green_font_prefix} 5.${Font_color_suffix} 停止 Aria2
 ${Green_font_prefix} 6.${Font_color_suffix} 重启 Aria2
 ———————————————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 修改 配置
 ${Green_font_prefix} 8.${Font_color_suffix} 查看 配置
 ${Green_font_prefix} 9.${Font_color_suffix} 查看 日志
 ${Green_font_prefix}10.${Font_color_suffix} 清空 日志
 ———————————————————————
 ${Green_font_prefix}11.${Font_color_suffix} 手动更新 BT-Tracker
 ${Green_font_prefix}12.${Font_color_suffix} 自动更新 BT-Tracker
 ${Green_font_prefix}13.${Font_color_suffix} 更新脚本
 ———————————————————————" && echo
if [[ -e ${aria2c} ]]; then
    check_pid
    bt_auto_status
    if [[ ! -z "${PID}" ]]; then
        echo -e " Aria2 状态: ${Green_font_prefix}已安装${Font_color_suffix} | ${Green_font_prefix}已启动${Font_color_suffix}"
    else
        echo -e " Aria2 状态: ${Green_font_prefix}已安装${Font_color_suffix} | ${Red_font_prefix}未启动${Font_color_suffix}"
    fi
    if [[ -n $bt_update_status ]]; then
        echo
        echo -e " 自动更新 BT-Tracker: ${Green_font_prefix}已开启${Font_color_suffix}"
    else
        echo
        echo -e " 自动更新 BT-Tracker: ${Red_font_prefix}未开启${Font_color_suffix}"
    fi
else
    echo -e " Aria2 状态: ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo -en " 请输入数字 [0-13]:"
read num
case "$num" in
0)
    exit 0
    ;;
1)
    Install_aria2
    ;;
2)
    Update_aria2
    ;;
3)
    Uninstall_aria2
    ;;
4)
    Start_aria2
    ;;
5)
    Stop_aria2
    ;;
6)
    Restart_aria2
    ;;
7)
    Set_aria2
    ;;
8)
    View_Aria2
    ;;
9)
    View_Log
    ;;
10)
    Clean_Log
    ;;
11)
    Update_bt_tracker
    ;;
12)
    Update_bt_tracker_cron
    ;;
13)
    Update_Shell
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
done
clear
