#!/usr/bin/env sh
#
# 基于 Ubuntu18 64位
# 检查是否安装iptables
pkgName="iptables"
checkRes=`dpkg --get-selections | grep iptables | awk -F : "END{print NR}"`
if [ ${checkRes} -lt 1 ]
then
    echo "没有安装${pkgName}\n"
    sudo apt -y install iptables
    mkdir -p /etc/iptables
    touch /etc/iptables/rules.conf
    cat rules.conf > /etc/iptables/rules.conf
else
    echo "已经安装${pkgName}\n iptables规则如下："
    echo "=============================："
    cat /etc/iptables/rules.conf
fi
