#!/data/data/com.termux/files/usr/bin/bash

while true; do
    clear
    fancy_opening
    sh_update
    main_menu
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
