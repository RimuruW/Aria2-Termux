#!/data/data/com.termux/files/usr/bin/bash

. "$ATMGIT/script/strings.sh"

trap exit_sh EXIT
trap exit_error 2

while true; do
    main_menu
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
        Step
        ;;
    6)
        Set_aria2
        Step
        ;;
    7)
        View_Aria2
        ;;
    8)
        View_Log
        Step
        ;;
    9)
        Clean_Log
        ;;
    10)
        Update_bt_tracker
        ;;
    11)
        sh_update
        Step
        ;;
    12)
        Auto_start
        Step
        ;;
    *)
        echo
        echo -e "${R}[!]${N} 请输入正确的数字"
        sleep 3
        ;;
    esac
done
