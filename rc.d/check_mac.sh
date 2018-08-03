#!/bin/bash
#
# Description: this script for check mac address
# Author:
# Date: 21/02/2018
#
############# Version ###############

. ${RCD}/functions

failed_log="MAC address"
ssn=`cat ${FOX}/ssn`
mac=`ifconfig -a | awk '/^[a-z]/ { iface=$1; mac=$NF; next } /inet addr:/ { print iface, mac }' | awk -F' ' '/eth0/ {print $2}' | sed -e "s/://g"`

if [ "$mac" = "" ]; then
    mac=`ifconfig -a | awk '/^[a-z]/ { iface=$1; mac=$NF; next } /inet addr:/ { print iface, mac }' | awk -F' ' '/enp1s0/ {print $2}' | sed -e "s/://g"`
fi

if [ "$mac" = "" ]; then
    mac=`ifconfig -a | awk '/^[a-z]/ { iface=$1; mac=$NF; next } /inet addr:/ { print iface, mac }' | awk -F' ' '/enp2s0/ {print $2}' | sed -e "s/://g"`
fi

if [ "$mac" = "" ]; then
    red_message "请将网线接上後重新执行测试"
    # . ${RCD}/failed.sh
    exit 1

fi

echo ${mac^^}

if [ "$ssn" = "${mac^^}" ]; then
    green_message "Mac address验证通过..."
    exit 0
else
    red_message "Mac address验证失败..."
    # . ${RCD}/failed.sh
    exit 1
fi


