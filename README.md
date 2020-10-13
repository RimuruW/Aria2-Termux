# Aria2 一键安装管理脚本 (Termux 移植版)

本项目基于 [aria2.sh](https://github.com/P3TERX/aria2.sh)，在原项目的基础上二次修改，结合了 Android 设备上的实际情况，去除原脚本某些在 Android 无法实现或意义不大的功能，并借助 Termux 的优势，尽可能在 Android 实现更好的 Aria2 体验。

项目脚本整合了 [aria2.conf](https://github.com/P3TERX/aria2.conf)，包含了配置文件、附加功能脚本等文件，用于实现 Aria2 功能的增强和扩展，提升 Aria2 的使用体验。

## 功能特性

- 使用 [aria2.conf](https://github.com/P3TERX/aria2.conf) 作为配置文件
    - 重启后不丢失任务进度、不重复下载
    - 下载错误或取消下载自动删除未完成的文件减少存储空间占用
    - 下载完成自动清除`.aria2`后缀名文件
    - 更好的 PT 下载支持

- 简洁易用，功能齐全，手机也能变成一个强大的多功能下载器
    - 全功能：`Async DNS`, `BitTorrent`, `Firefox3 Cookie`, `GZip`, `Message Digest`, `Metalink`, `XML-RPC`, `SFTP`
    - 一键更新脚本
    - 一键更新 BT tracker 列表
    
- 支持与 [RCLONE](https://rclone.org/) 联动，更多扩展功能与玩法：
    - [OneDrive、Google Drive 等网盘离线下载](https://p3terx.com/archives/offline-download-of-onedrive-gdrive.html)
    - [百度网盘转存到 OneDrive 、Google Drive 等其他网盘](https://p3terx.com/archives/baidunetdisk-transfer-to-onedrive-and-google-drive.html)

## 项目地址

原项目地址: https://github.com/P3TERX/aria2.sh

本项目地址: https://github.com/QingxuMo/Aria2-Termux

支持项目请随手点个`star`，可以让更多的人发现、使用并受益。您的支持是我持续开发维护的动力。

## 系统要求

Android 5.0+

Termux 版本越高越好

## 架构支持

任何支持安装 Termux 的架构

## 使用说明

请在 [Google Play Store](https://play.google.com/store/apps/details?id=com.termux) 下载并安装 Termux。

*你当然可以选择其他渠道下载，但请尽可能保证你使用的 Termux 为最新版*

* 为了确保能正常使用，请先安装必需软件包
```
pkg in wget bash
```

* 下载脚本
```
wget -N https://raw.githubusercontent.com/QingxuMo/Aria2-Termux/master/aria2.sh && chmod +x aria2.sh
```

> 对于国内用户，可以尝试输入下面命令下载脚本
```
wget -N https://cdn.jsdelivr.net/gh/QingxuMo/Aria2-Termux@master/aria2.sh && chmod +x aria2.sh
```

* 运行脚本
```
bash aria2.sh
```

* 选择你要执行的选项
```
 Aria2 一键安装管理脚本 (Termux 移植版) [v1.0.2] by Qingxu(QingxuMo)
 
  0. 退出
 ———————————————————————
  1. 安装 Aria2
  2. 卸载 Aria2
 ———————————————————————
  3. 启动 Aria2
  4. 停止 Aria2
  5. 重启 Aria2
 ———————————————————————
  6. 修改 配置
  7. 查看 配置
  8. 查看 日志
  9. 清空 日志
 ———————————————————————
  10. 更新 BT-Tracker
  11. 升级脚本
 ———————————————————————

 Aria2 状态: 已安装 | 已启动

 请输入数字 [0-11]:
```

## 其他

默认配置文件路径：`$HOME/.aria2/aria2.conf`

默认下载目录：`/sdcard/Download`

RPC 密钥：随机生成，可使用选项`6. 修改 配置文件`自定义

## 更新日志

### 2020-10-13 v1.0.2

- 修复了一些影响体验的 bug
- 优化代码结构，使之更符合 Android 实际体验
- 去除某些无意义或作用不大的功能
- 添加 AriaNg 地址自动获取（合并原仓库提交）
- 解决 Aria2 日志无法获取问题
- 修改了版本号格式，新自动版本更新功能 coming soon…
- Update README

### 2020-06-27 v1.0.1

- 移植适配 Termux
- 解决了某些报错
- 完善更新脚本时的备份机制


## Lisence
[MIT](https://github.com/QingxuMo/Aria2-Termux/blob/master/LICENSE) © Toyo x P3TERX x Qingxu
