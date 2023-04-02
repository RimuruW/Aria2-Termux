# Aria2-Termux
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/install.sh)"
```
> Simplify the complexity and put the fun of Aria2 at your fingertips.

## Introduction
This project is based on [aria2.sh](https://github.com/P3TERX/aria2.sh), which is modified twice on the basis of the original project, combined with the actual situation on Android devices, and removes some of the original scripts that cannot be used on Android. Realize functions that are of little significance, and use the advantages of Termux to achieve a better Aria2 experience on Android as much as possible.

The project has integrated Aria2 configuration files, additional function scripts and other files.
Please click [here](https://github.com/RimuruW/Aria2-Termux/tree/master/conf) for details about configuration files.

## Features

- One-click installation management script, even a novice terminal can easily get started
- Concise and easy-to-use management interface, all management operations can be completed in one step in the script
- Perfect multi-function support, support one-click update BT Trackers, Aria2 boot self-start
- Abundant additional extension functions, see [Configuration File Description](https://github.com/RimuruW/Aria2-Termux/tree/master/conf)

## System Requirements

- Android 7.0 - 9.0 (Android 10 and above may have some issues)
- CPU architecture: AArch64, ARM, i686, x86_64.
- At least 200MB of free storage space

 **Note: Termux does not support ARM devices without NEON SIMD, such as Nvidia Tegra 2 CPUs.**

*Aria2-Termux itself does not have any special system requirements, it only needs a working Termux environment, and the above requirements are the normal working requirements of Termux. *

## Known Issues

It is currently [known](https://github.com/RimuruW/Aria2-Termux/issues/4) that in some cases Aria2 command line downloads do not work properly after starting Aria2 RPC with the Aria2 configuration file. For details, please see [Aria2 command line download problem](https://github.com/RimuruW/Aria2-Termux/wiki/Aira2-%E5%91%BD%E4%BB%A4%E8%A1%8C%E4% B8%8B%E8%BD%BD%E9%97%AE%E9%A2%98).

## ToDo
- [x] Adapt to Termux
- [x] Beautiful and easy-to-use UI
- [x] Perfect self-test system
- [ ] Remote control configuration
- [ ] Complete README and Wiki

## Instructions for use

### Detailed documentation
Please refer to [Android one-click installation and configuration of Aria2](https://blog.linioi.com/posts/aria2-for-termux/)

### Quick Start

1. Install Termux

~~Please download and install Termux from [Google Play Store](https://play.google.com/store/apps/details?id=com.termux). ~~

For [these reasons](https://github.com/termux/termux-app/issues/1072), the Google Play Store is no longer the recommended download location, please find it at [F-Droid](https://f- droid.org/packages/com.termux/) Download Termux.

2. Install Aria2-Termux

Starting from version 2.0.0 of Aria2-Termux, Aria2-Termux provides a one-click installation script to install Aria2-Termux. You can enter the following command in Termux to install Aria2-Termux with one click.

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/install.sh)"
```

For regions that cannot normally access the GitHub direct link, you can also enter the following command in Termux to execute the installation script.

```bash
bash -c "$(curl -L  https://cdn.jsdelivr.net/gh/RimuruW/Aria2-Termux@master/install.sh)"
```


3. Run the script

Starting from Aria2-Termux 2.0.0, Aria2-Termux provides a global launcher `atm` to start Aria2-Termux. You can directly enter the following command in Termux to start Aria2-Termux.

```bash
atm
```

## Old version compatibility issues

Aria2-Termux 2.0+ cannot guarantee compatibility with Aria2-Termux 1.0+, you may need to manually migrate to version 2.0+.

You can still download, install and run legacy management scripts with the following commands.

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/RimuruW/Aria2-Termux/master/aria2.sh)"
```

## other

Default configuration file path: `$HOME/.aria2/aria2.conf`

Default download directory: `/sdcard/Download`

RPC key: Randomly generated, customizable in script

Please click `star` to support the project, so that more people can discover, use and benefit. Your support is my driving force for continuous development and maintenance.

## Update log

> Due to academic reasons, the development progress of this project will slow down, sorry.

### 2022-07-12 v2.0.1 Beta 2

- Fix the bug that the local IP cannot be obtained
- Add "About" interface
- Improve the script update mechanism
- Adapt to the latest version of Termux for mirror source changes
- Added usage tips or function descriptions to some interfaces

### 2021-08-16 v2.0.0 Beta 1

- UI style modification
- Optimize the installation method
- Simplify some unnecessary output
- Optimize the configuration management of Aria2

### 2021-07-26 v1.0.6

- Perfect image source detection
- Improve the startup management of Aria2
- Fixed some bugs in Aria2 config file

### 2020-11-23 v1.0.5

- Integrate configuration files into repository
- More complete self-test system

### 2020-11-15 v1.0.4

- Minor modification of UI style
- Code structure optimization
- Add Aria2 boot self-starting[#2](https://github.com/RimuruW/Aria2-Termux/issues/2)

### 2020-10-23 v1.0.3

- Details optimization
- Support curl to automatically download scripts when executing scripts directly
- Optimize storage permission detection

### 2020-10-13 v1.0.2

- Fixed some bugs that affect the experience
- Optimize the code structure to make it more in line with the actual Android experience
- Remove some meaningless or ineffective functions
- Add automatic acquisition of AriaNg address (merge original warehouse submission)
- Solve the problem that Aria2 logs cannot be obtained

### 2020-06-27 v1.0.1

- Porting and adapting to Termux
- Fixed some bugs
- Improve the backup mechanism when updating scripts


## License
The project uses the [MIT](https://github.com/RimuruW/Aria2-Termux/blob/master/LICENSE) open source agreement, and the user's use of this project means that the user has read and agreed to the open source agreement.
