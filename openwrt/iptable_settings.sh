#!/bin/bash

echo ""
echo "                            __ _   "
echo "__ _ _ __  _   _ ___  ___  / _| |_ "
echo "/ _\` | '_ \| | | / __|/ _ \| |_| __|"
echo "| (_| | | | | |_| \__ \ (_) |  _| |_ "
echo " \__,_|_| |_|\__, |___/\___/|_|  \__|"
echo "             |___/   "
echo "====================================="
echo "====================================="
echo "=== auto config Optical modem ======="
echo "= 1. link e8clib to saves space     ="
echo "= 2. copy and setting iptables      ="
echo "====================================="
echo "====================================="
echo "====================================="

# check current system is openwrt ?
if [[ -e "/etc/openwrt_version" ]]; then
    echo "check e8clib links"
    if [ -d "/e8clib" ]; then
        echo "find /e8clib start to link libs"
        for file in /e8clib/*; do
            # 如果文件或链接已经存在于 /lib 目录，则跳过
            if [[ -e "/lib/$(basename "$file")" ]]; then
                echo "Skipping $(basename "$file") as it already exists in /lib"
                continue
            fi
            
            # 创建链接到 /lib 目录
            ln -s "$file" "/lib/$(basename "$file")"
            echo "Linked $(basename "$file") to /lib"
        done
    else
        echo ""
    fi
    echo "========================================================================"
    echo "========================================================================"
    echo "= current terminal is openwrt. please run this script in route system. ="
    echo "========================================================================"
    exit
fi


# check saf
if [ -d "/opt/upt/framework/" ]; then
    echo "current terminal is route's basic system. we will try to copy iptables"
    if [[ -e "/opt/upt/apps/apps/sbin/xtables-multi" ]]; then
        echo "========================================================================"
        echo "=      It seems that iptables are ready!                               ="
        echo "========================================================================"
    else
        echo "start to copy iptables into openwrt."
        if [[ -e "/sbin/xtables-multi" ]]; then
            cp -a /sbin/xtables-multi /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/ip6tables" ]]; then
            cp -a /sbin/ip6tables /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/ip6tables-restore" ]]; then
            cp -a /sbin/ip6tables-restore /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/ip6tables-save" ]]; then
            cp -a /sbin/ip6tables-save /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/iptables" ]]; then
            cp -a /sbin/iptables /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/iptables-restore" ]]; then
            cp -a /sbin/iptables-restore /opt/upt/apps/apps/sbin/
        fi
        if [[ -e "/sbin/iptables-save" ]]; then
            cp -a /sbin/iptables-save /opt/upt/apps/apps/sbin/
        fi
        echo "========================================================================"
        echo "=   Copy successful, you can go to OpenWrt to create a soft link,  ====="
        echo "= if you haven't done it yet                                       ====="
        echo "========================================================================"
    fi
fi
