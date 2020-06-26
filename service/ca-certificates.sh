#!/usr/bin/env bash
#=================================================
# https://github.com/P3TERX/ca-certificates.crt
# Description: Update ca-certificates.crt
# Version: 1.1
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

set -e
[ $(uname) != Linux ] && {
    echo "This operating system is not supported."
    exit 1
}

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
INFO="[${Green_font_prefix}INFO${Font_color_suffix}]"
ERROR="[${Red_font_prefix}ERROR${Font_color_suffix}]"

echo && echo -e "$INFO Check downloader ..."
if [ $(command -v wget) ]; then
    DOWNLOADER='wget -nv -N'
elif [ $(command -v curl) ]; then
    DOWNLOADER='curl -fsSLO'
else
    echo -e "$ERROR curl or wget is not installed."
fi

echo -e "${INFO} Doanload ca-certificates.crt ..."
${DOWNLOADER} https://raw.githubusercontent.com/P3TERX/ca-certificates.crt/download/ca-certificates.crt ||
    ${DOWNLOADER} https://cdn.jsdelivr.net/gh/P3TERX/ca-certificates.crt@download/ca-certificates.crt ||
    ${DOWNLOADER} https://gh.p3terx.workers.dev/ca-certificates.crt/download/ca-certificates.crt

[ -s ca-certificates.crt ] && echo -e "${INFO} ca-certificates.crt Download completed !" || {
    echo -e "${ERROR} Unable to download ca-certificates.crt, network failure or API error."
    rm -f ca-certificates.crt
    exit 1
}

echo -e "${INFO} Updating ca-certificates.crt ..."
mkdir -vp /data/data/com.termux/files/usr/etc/ssl/certs
mv -vf ca-certificates.crt /data/data/com.termux/files/usr/etc/ssl/certs/ca-certificates.crt &&
    echo -e "${INFO} ca-certificates.crt update completed !" ||
    {
        echo -e "${ERROR} ca-certificates.crt update failed !"
        exit 1
    }
exit 0
