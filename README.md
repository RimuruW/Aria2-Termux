 # Aria2-Termux
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh)"
```
> 化繁为简，让 Aria2 的乐趣触手可及。

## 简介
本项目基于 [aria2.sh](https://github.com/P3TERX/aria2.sh)，在原项目的基础上二次修改，结合了 Android 设备上的实际情况，去除原脚本某些在 Android 无法实现或意义不大的功能，并借助 Termux 的优势，尽可能在 Android 实现更好的 Aria2 体验。

项目整合了 Aria2 配置文件、附加功能脚本等文件。
关于配置文件的详细信息请点击[这里](https://github.com/RimuruW/Aria2-Termux/tree/master/conf)。

## 功能特性

- 简明易用的管理界面，所有管理操作可以在脚本一步完成
- 完善的多功能支持，支持一键更新 BT Trackers、Aria2 开机自启动
- 丰富的附加扩展功能，详见[配置文件说明](https://github.com/RimuruW/Aria2-Termux/tree/master/conf)

## 系统要求

- Android 7.0 - 9.0 (Android 10 以上可能会有一些问题)
- CPU 架构: AArch64, ARM, i686, x86_64.
- 至少 200MB 的空闲存储空间


 **注意：Termux 不支持没有 NEON SIMD 的 ARM 设备，例如 Nvidia Tegra 2 CPUs.**

*Aria2-Termux 本身无任何特殊系统要求，仅需要一个可正常工作的 Termux 环境，以上要求均为 Termux 正常工作要求。*

## 已知问题

目前[已知](https://github.com/RimuruW/Aria2-Termux/issues/4)，某些情况下使用 Aria2 配置文件启动 Aria2 RPC 后，Aria2 命令行下载不能正常工作。详情请看 [Aria2 命令行下载问题](https://github.com/RimuruW/Aria2-Termux/wiki/Aira2-%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8B%E8%BD%BD%E9%97%AE%E9%A2%98)。

## ToDo
- [x] 适配 Termux
- [x] 美观易用的 UI
- [x] 完善的自检测系统
- [ ] 远程控制配置
- [ ] 完善的 README 和 Wiki

## 使用说明

### 详细使用文档
请参阅 [Android 一键安装配置 Aria2](https://qingxu.live/index.php/archives/aria2-for-termux/)

### 快速开始
~~请在 [Google Play Store](https://play.google.com/store/apps/details?id=com.termux) 下载并安装 Termux。~~

由于[这些原因](https://github.com/termux/termux-app/issues/1072)，Google Play Store 不再是推荐的下载地址，请在 [F-Droid](https://f-droid.org/packages/com.termux/) 下载 Termux。

1. 为了确保能正常使用，请先安装必需软件包

```bash
pkg i wget -y
```

2. 下载脚本

```bash
wget -N https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh && chmod +x aria2.sh
```

> 对于国内用户，可以尝试输入下面命令下载脚本
```bash
wget -N https://cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/aria2.sh && chmod +x aria2.sh
```

3. 运行脚本

```bash
bash aria2.sh
```

4. 选择你要执行的选项

```
Aria2 一键管理脚本 [v1.0.6]
            by Qingxu(RimuruW)

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
  10. 一键更新 BT-Tracker
  11. 一键更新脚本
  12. Aria2 开机自启动
 ———————————————————————

 Aria2 状态: 已安装 | 已启动
 Aria2 开机自启动: 已开启

 请输入数字 [0-12]: 
```

## 其他

默认配置文件路径：`$HOME/.aria2/aria2.conf`

默认下载目录：`/sdcard/Download`

RPC 密钥：随机生成，可使用选项`6. 修改 配置文件`自定义

支持项目请随手点个`star`，可以让更多的人发现、使用并受益。您的支持是我持续开发维护的动力。

## 更新日志

> 因学业原因，本项目开发进度将放缓，见谅。
>
> 新版 Aria2-Termux 正在连夜制作中，我争取八月上旬完成...

### 2021-07-26 v1.0.6
- 完善镜像源检测
- 完善 Aria2 的启动管理
- 修复 Aria2 配置文件的某些错误

### 2020-11-23 v1.0.5
- 整合配置文件至仓库
- 更完善的自检测系统

### 2020-11-15 v1.0.4
- UI 风格微修改
- 代码结构优化
- 添加 Aria2 开机自启动 [#2](https://github.com/RimuruW/Aria2-Termux/issues/2)

### 2020-10-23 v1.0.3

- 细节优化
- 支持 curl 直接执行脚本时自动下载脚本
- 优化存储权限检测

### 2020-10-13 v1.0.2

- 修复了一些影响体验的 bug
- 优化代码结构，使之更符合 Android 实际体验
- 去除某些无意义或作用不大的功能
- 添加 AriaNg 地址自动获取（合并原仓库提交）
- 解决 Aria2 日志无法获取问题

### 2020-06-27 v1.0.1

- 移植适配 Termux
- 解决了某些报错
- 完善更新脚本时的备份机制


## License
项目使用 [MIT](https://github.com/RimuruW/Aria2-Termux/blob/master/LICENSE) 开源协议，用户使用本项目即代表用户已阅读并同意该开源协议。
