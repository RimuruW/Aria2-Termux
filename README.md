# Aria2 一键安装管理脚本 (Termux 移植版)

Aria2 是目前最强大的全能型下载工具，它支持 BT、磁力、HTTP、FTP 等下载协议，常用做离线下载的服务端。

> Aria2 一键安装管理脚本是 Toyo (逗比) 大佬最为知名的脚本作品之一，2018年11月14日逗比大佬因未知原因突然失联。由于[P3TERX(即该项目原作者)](https://github.com/P3TERX)非常喜欢 Aria2, 所以自2018年12月7日起开始接手这个项目并进行了大量的功能与细节优化，一直持续维护至今[项目原作者 README 自述].

增强版脚本整合了 [Aria2 完美配置](https://github.com/P3TERX/aria2.conf)，在安装 Aria2 的过程中会下载这套配置方案，这套方案包含了配置文件、附加功能脚本等文件，用于实现 Aria2 功能的增强和扩展，提升 Aria2 的使用体验，解决 Aria2 在使用中遇到的 BT 下载无速度、文件残留占用磁盘空间、任务丢失、重复下载等问题。

移植版基于原项目,结合了 Android 设备上的实际情况,借助 Termux 的优势,尽可能在 Android 实现更好的 Aria2 体验。

**注意！该脚本部分功能可能需要搭配 [Termux Tools](https://github.com/huanruomengyun/Termux-Tools) 才能正常使用！**

## 功能特性

- 使用 [Aria2 完美配置](https://github.com/P3TERX/aria2.conf)方案
    - 提升 BT 下载率和下载速度
    - 重启后不丢失任务进度、不重复下载
    - 下载错误或取消下载自动删除未完成的文件防止磁盘空间占用
    - 下载完成自动清除`.aria2`后缀名文件
    - 更好的 PT 下载支持
    - 防版权投诉、防迅雷吸血优化

- 功能齐全,手机也能变成一个强大的多功能下载器
    - 全功能：`Async DNS`, `BitTorrent`, `Firefox3 Cookie`, `GZip`, `HTTPS`, `Message Digest`, `Metalink`, `XML-RPC`, `SFTP`
    - 通过 CI 服务持续更新最新版本

- 支持与 [RCLONE](https://rclone.org/) 联动，更多扩展功能与玩法：
    - [OneDrive、Google Drive 等网盘离线下载](https://p3terx.com/archives/offline-download-of-onedrive-gdrive.html)
    - [百度网盘转存到 OneDrive 、Google Drive 等其他网盘](https://p3terx.com/archives/baidunetdisk-transfer-to-onedrive-and-google-drive.html)

- 支持新一代互联网协议 IPv6
- 定时自动更新 BT tracker 列表（需要 [Termux Tools](https://github.com/huanruomengyun/Termux-Tools) 支持）

## 项目地址
原项目地址: https://github.com/P3TERX/aria2.sh

本项目地址: https://github.com/huanruomengyun/Aria2-Termux

支持项目请随手点个`star`，可以让更多的人发现、使用并受益。您的支持是我持续开发维护的动力。

## 系统要求

Android 5.0+

Termux 版本越高越好

## 架构支持

x86_64 / i386 / ARM64 / ARM32v7 / ARM32v6

## 使用说明

* 为了确保能正常使用，请先安装必需软件包
```
pkg in wget
```

* 下载脚本
```
wget -N https://git.io/Jfjb5 && chmod +x aria2.sh
```

* 运行脚本
```
./aria2.sh
```

* 选择你要执行的选项
```
 Aria2 一键安装管理脚本 (Termux 移植版 [v1.6.26] by Qingxu(huanruomengyun)
 
  0. 升级脚本
 ———————————————————————
  1. 安装 Aria2
  2. 更新 Aria2
  3. 卸载 Aria2
 ———————————————————————
  4. 启动 Aria2
  5. 停止 Aria2
  6. 重启 Aria2
 ———————————————————————
  7. 修改 配置
  8. 查看 配置
  9. 查看 日志
 10. 清空 日志
 ———————————————————————
 11. 手动更新 BT-Tracker
 12. 自动更新 BT-Tracker
 13. 退出
 ———————————————————————

 Aria2 状态: 已安装 | 已启动

 自动更新 BT-Tracker: 已开启

 请输入数字 [0-13]:
```

## 其他

配置文件路径：`$HOME/.aria2/aria2.conf` （配置文件有中文注释，若语言设置有问题会导致中文乱码）

默认下载目录：`/sdcard/Download`

RPC 密钥：随机生成，可使用选项`7. 修改 配置文件`自定义

## 更新日志

### 2020-06-27 v1.6.26.2

- 修复因[原项目](https://github.com/P3TERX/aria2.sh)的某个不明所以的提交造成的下载失败

### 2020-06-27 v1.6.26.1

- 合并[原项目](https://github.com/P3TERX/aria2.sh)的提交

### 2020-06-26 v1.6.26

- Init
- Fork 自 https://github.com/P3TERX/aria2.sh
- 移植适配 Termux

## Lisence
[MIT](https://github.com/huanruomengyun/Aria2-Termux/blob/master/LICENSE) © Toyo x P3TERX x Qingxu
