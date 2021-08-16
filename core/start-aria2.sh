#!/data/data/com.termux/files/usr/bin/bash

check_installed_status
check_pid
[[ -n ${PID} ]] && red "[!] Aria2 正在运行!" && return 1
check_storage
blue "[*] 尝试开启唤醒锁…"
termux-wake-lock
green "[√] 所有步骤执行完毕，开始启动..."
$PREFIX/bin/aria2c "$(grep -v '#' "$HOME/.aria2/aria2.conf" | sed '/^$/d' | sed "s/^/--&/g" | sed ':label;N;s/\n/ /;b label')" -D
check_pid
[[ -z ${PID} ]] && red "[!] Aria2 启动失败，请检查日志！" && return 1
