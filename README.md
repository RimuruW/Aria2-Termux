 # Aria2-Termux
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/install.sh)"
```
> 化繁为简，让 Aria2 的乐趣触手可及。

for an english version, see [the english readme](./README-EN.md)

## 简介
本项目基于 [aria2.sh](https://github.com/P3TERX/aria2.sh)，在原项目的基础上二次修改，结合了 Android 设备上的实际情况，去除原脚本某些在 Android 无法实现或意义不大的功能，并借助 Termux 的优势，尽可能在 Android 实现更好的 Aria2 体验。

项目已整合了 Aria2 配置文件、附加功能脚本等文件。
关于配置文件的详细信息请点击[这里](https://github.com/RimuruW/Aria2-Termux/tree/master/conf)。

## 功能特性

- 一键安装管理脚本，即使是终端新手也可以轻松上手
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
请参阅 [Android 一键安装配置 Aria2](https://blog.linioi.com/posts/aria2-for-termux/)

### 快速开始

1. 安装 Termux

~~请在 [Google Play Store](https://play.google.com/store/apps/details?id=com.termux) 下载并安装 Termux。~~

由于[这些原因](https://github.com/termux/termux-app/issues/1072)，Google Play Store 不再是推荐的下载地址，请在 [F-Droid](https://f-droid.org/packages/com.termux/) 下载 Termux。

2. 安装 Aria2-Termux

从 Aria2-Termux 2.0.0 版本开始，Aria2-Termux 提供一键安装脚本用以安装 Aria2-Termux，你可以在 Termux 中输入如下命令一键安装 Aria2-Termux。

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/install.sh)"
```

对于无法正常访问 GitHub 直链的地区，你也可以在 Termux 中输入如下命令执行安装脚本。

```bash
bash -c "$(curl -L  https://cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/install.sh)"
```


3. 运行脚本

从 Aria2-Termux 2.0.0 开始，Aria2-Termux 提供全局启动器 `atm` 用以启动 Aria2-Termux。你可以直接在 Termux 输入如下命令启动 Aria2-Termux。

```bash
atm
```

## 旧版兼容问题

Aria2-Termux 2.0+ 无法保证与 Aria2-Termux 1.0+ 的兼容性，你可能需要手动迁移至 2.0+ 版本。

你仍可以通过如下命令下载安装并运行旧版管理脚本。

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh)"
```

## 其他

默认配置文件路径：`$HOME/.aria2/aria2.conf`

默认下载目录：`/sdcard/Download`

RPC 密钥：随机生成，可在脚本中自定义

支持项目请随手点个`star`，可以让更多的人发现、使用并受益。您的支持是我持续开发维护的动力。

## 更新日志

> 因学业原因，本项目开发进度将放缓，见谅。

### 2022-07-12 v2.0.1 Beta 2

- 修复本地 IP 无法获取的 bug
- 增添「关于」界面
- 完善脚本更新机制
- 适配最新版本 Termux 对于镜像源的变更
- 部分界面增添使用提示或者功能说明

### 2021-08-16 v2.0.0 Beta 1

- UI 风格修改
- 优化安装方式
- 简化部分不必要的输出
- 优化 Aria2 的配置管理

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
