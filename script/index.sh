#!/data/data/com.termux/files/usr/bin/bash

. "$ATMGIT/script/strings.sh"

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
