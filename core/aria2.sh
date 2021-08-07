#!/data/data/com.termux/files/usr/bin/bash
#=============================================================
# Doc: https://github.com/RimuruW/Aria2-Termux/blob/master/README.md
# Author: RimuruW
#=============================================================





while true; do
    check_script_download
    echo && echo -e "
${LIGHT}[*]${RESET} Aria2 一键管理脚本 ${YELLOW}[v${sh_ver}]${RESET}
            by ${LIGHT}Qingxu(RimuruW)${RESET}

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
        source "$ATMDIR/core/start-aria2.sh"
        ;;
    4)
        Stop_aria2
        ;;
    5)
        source "$ATMDIR/core/restart-aria2.sh"
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
