#!/data/data/com.termux/files/usr/bin/bash

. "$ATMGIT/script/strings.sh"

trap exit_sh EXIT
trap exit_error 2

while true; do
    clear
    echo ""
    header "主菜单"
    echo ""
    main_menu
    footer
    printf "\n 请输入数字 [0-12]: "
	echo -en "${G}"
	read -r INPUT
	echo -en "${N}"
    case "$INPUT" in
    0)
        exit 0
        ;;
    1)
        Install_aria2
        Step
        ;;
    2)
        Uninstall_aria2
        Step
        ;;
    3)
        Start_aria2
        Step
        ;;
    4)
        Stop_aria2
        Step
        ;;
    5)
        source "${ATMGIT}/core/restart-aria2.sh"
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
        sh_update
        ;;
    12)
        Auto_start
        ;;
    *)
        echo
        echo -e "${R}[!]${N} 请输入正确的数字"
        sleep 3
        ;;
    esac
done
