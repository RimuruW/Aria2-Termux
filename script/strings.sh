#!/data/data/com.termux/files/usr/bin/bash

main_menu() {
    header "主菜单"
    echo ""
    echo -e "
${G} 0.${N} 退出
——————————————————————
${G} 1.${N} 安装 Aria2
${G} 2.${N} 卸载 Aria2
———————————————————————
${G} 3.${N} 启动 Aria2
${G} 4.${N} 停止 Aria2
${G} 5.${N} 重启 Aria2
———————————————————————
${G} 6.${N} 修改 配置
${G} 7.${N} 查看 配置
${G} 8.${N} 查看 日志
${G} 9.${N} 清空 日志
———————————————————————
${G} 10.${N} 一键更新 BT-Tracker
${G} 11.${N} 一键更新脚本
${G} 12.${N} Aria2 开机自启动
———————————————————————
${G} 13.${N} 关于脚本
    "
    footer
    printf "\n 请输入数字 [0-13]: "
}

Set_aria2() {
    echo ""
    header "修改 配置"
    echo ""
    check_installed_status
    aria2_modify=null
    echo -e "
 ${G}1.${N} 修改 Aria2 RPC 密钥
 ${G}2.${N} 修改 Aria2 RPC 端口
 ${G}3.${N} 修改 Aria2 下载目录
 ${G}4.${N} 修改 Aria2 密钥 + 端口 + 下载目录
 ${G}5.${N} 手动 打开配置文件修改
 ${G}6.${N} 重置/更新 Aria2 配置文件
 -------------------
 ${G}0.${N}  退出脚本
"
    footer
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
        Reset_ARIA2CONF
    elif [[ ${aria2_modify} == "0" ]]; then
        return 0
    else
        echo
        echo "${R}[!]${N} 请输入正确的数字"
        return 1
    fi
}

Set_aria2_vim_conf() {
    echo ""
    header "手动修改配置文件"
    echo ""
    Read_config
    aria2_port_old=${aria2_port}
    aria2_dir_old=${aria2_dir}
    echo -e "
 配置文件位置：${G}${ARIA2CONF}${N}

 ${G}[*]${N} 手动修改配置文件须知：
 
 ${G}1.${N} 默认使用 nano 文本编辑器打开
 ${G}2.${N} 退出并保存文件：按 ${G}Ctrl+X${N} 组合键，输入 ${G}y${N} ，然后按 ${G}Enter${N} 键
 ${G}3.${N} 退出不保存文件：按 ${G}Ctrl+X${N} 组合键，输入 ${G}n${N}
 ${G}4.${N} nano 详细使用教程: \033[4;34mhttps://wiki.archlinux.org/index.php/Nano_(简体中文)${N}
 "
    footer
    echo -en "按任意键继续，按 Ctrl+C 组合键取消"
    read -r -n 1 line
    nano "${ARIA2CONF}"
    Read_config
    if [[ ${aria2_port_old} != "${aria2_port}" ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
    fi
    if [[ ${aria2_dir_old} != "${aria2_dir}" ]]; then
        mkdir -p "${aria2_dir}"
        aria2_dir_2=$(echo "${aria2_dir}" | sed 's/\//\\\//g')
        sed -i "s@^\(DOWNLOAD_PATH='\).*@\1${aria2_dir_2}'@" "${WORKDIR}/*.sh"
    fi
    source "$ATMGIT/core/restart-aria2.sh"
}

View_Aria2() {
    echo ""
    header "正在获取 Aria2 配置信息..."
    echo ""
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
        for LOCALIP in $(ip a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | cut -d "/" -f1); do
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
        AriaNg_API_1="/#!/settings/rpc/set/ws/${LocalIP}/${aria2_port}/jsonrpc/$(echo -n ${aria2_passwd} | base64)"
	AriaNg_API_2="/#!/settings/rpc/set/ws/127.0.0.1/${aria2_port}/jsonrpc/$(echo -n ${aria2_passwd} | base64)"
        AriaNg_URL_1="http://mirror-aria2.qingxu.live${AriaNg_API_1}"
	AriaNg_URL_2="http://mirror-aria2.qingxu.live${AriaNg_API_2}"
    fi
    clear
    echo ""
    header "Aria2 简单配置信息"
    echo ""
    echo -e "
 IPv4 地址: ${G}${IPV4}${N}
 IPv6 地址: ${G}${IPV6}${N}
 内网 IP 地址: ${G}${LocalIP}${N} 
 RPC 端口: ${G}${aria2_port}${N}
 RPC 密钥: ${G}${aria2_passwd}${N}
 下载目录: ${G}${aria2_dir}${N}

 AriaNg 链接
 - 本机连接 AriaNg：${G}${AriaNg_URL_2}${N}
 - 区域网内其他设备连接 AriaNg: ${G}${AriaNg_URL_1}${N}
 
 说明:
 1、内网 IP 地址指设备所处区域网的 IP 地址，可以在手机设置中查看该 IP 地址，通常格式为 192.168.x.x
 2、AriaNg 为其他开发者为 Aria2 制作的图形化操作界面，你也可以使用其他可视化工具，并使用 Aria2。
 3、AriaNg 中对 Aria2 配置的修改${R}只能在该次对话中生效${N}。如果你希望修改持续生效请在脚本中修改配置或者直接修改配置文件。
 4、如无其他需求，一般使用第一个 AriaNg 链接即可。\n"
    footer
    echo -en "\n\n请回车以继续" && read -r -n 1 line
}

Auto_start() {
    echo ""
    header "Aria2 开机自启"
    echo ""
    echo -e "
${Y}[!]${N} 受限于 Termux，Aria2 开机自启动需要 Termux 提供相应支持。
${Y}[!]${N} 你需要先安装 ${G}Termux:Boot${N} 才可以实现 Termux
Termux:Boot 下载链接: ${G}https://f-droid.org/zh_Hans/packages/com.termux.boot/${N}

${R}[!]${N} 注意，如果你未安装 ${G}Termux:Boot${N}，脚本中任何关于 Aria2 自启动的配置${R}没有任何意义${N}
"
    footer
    if [ -f "$HOME/.termux/boot/auto-start-aria2" ]; then
        if ask "你已开启 Aria2 自启动，是否关闭？" "N"; then
            if rm -f "$HOME/.termux/boot/auto-start-aria2"; then
                echo -e "${G}[√]${N} 已关闭 Aria2 自启动"
            else
                echo -e "${R}[!] ${N} Aria2 自启动关闭失败！"
            fi
        else
            echo "${G}[*]${N} 已跳过…"
        fi
    else
        if ask "是否开启 Aria2 开机自启动？" "N"; then
            mkdir -p "$HOME/.termux/boot"
            if [ -f "$ATMGIT/core/auto-start-aria2" ]; then
                if cp "$ATMGIT/core/auto-start-aria2" "$HOME/.termux/boot/auto-start-aria2"; then
                    echo -e "${G}[√]${N} Aria2 开机自启动已开启！"
                else
                    echo -e "${R}[!]${N} Aria2 启动开启失败！"
                fi
            else
                echo -e "
${R}[!]${N} 未找到自启动配置文件！
${R}[!]${N} 这可能是因为你未通过本脚本完成 Aria2 安装或手动修改了相关目录。
${R}[!]${N} 请通过脚本重新安装 Aria2 以避免绝大多数可避免的问题！"
            fi
        else
            echo -e "${G}[*]${N} 不开启 Aria2 开机自启动…"
        fi
    fi
}
show_about(){
	header "Aria2-Termux"
	echo -e "

GitHub Repository:
${B}https://github.com/RimuruW/Aria2-Termux${N}

Author: ${B}RimuruW${N}

License: ${B}MIT${N}

Tutorial:
- Recommend: ${B}https://github.com/RimuruW/Aria2-Termux/blob/master/README.md${N}

- For getting started: ${B}https://blog.linioi.com/posts/aria2-for-termux/${N}


Aria2-Termux Version: ${B}$VER $REL${N}

Termux Version: ${B}$TERMUX_VERSION${N}

Android Version: 
$(getprop | grep ro.build.version.release)
$(getprop | grep ro.build.version.sdk)

Model:
$(getprop | grep ro.product.model)
       
$(getprop | grep ro.product.name)

如果您在使用中出现问题请提交 issues 并在 issue 中描述你的问题，或者提交 pull request 修复这个问题。

你可以先更新脚本再尝试问题是否会复现。

Issues link:
${B}https://github.com/RimuruW/Aria2-Termux/issues${N}

Pull Requests link:
${B}https://github.com/RimuruW/Aria2-Termux/pulls${N}

"
}
