#!/bin/bash
#
# Description: this script for check bios.
# Author: 
# Date: 30/10/2017
#
############# Version ###############

. ${FOX}/rc.d/functions

readonly HIGH_TEMPER=80
readonly LOW_TEMPER=15

failed_log="CPU temperature"

echo Testing CPU temper ...
cpu_temper=`sensors | awk -F'+' '/Core 0/ {print $2}' | awk -F'°C' '{print $1}'`
echo $cpu_temper $LOW_TEMPER
if [ `echo "$cpu_temper > $LOW_TEMPER" | bc` -eq 1 ] && [ `echo "$cpu_temper < $HIGH_TEMPER" | bc` -eq 1 ]; then
    green_message "CPU温度测试通过..."
    exit 0
else
	red_message "CPU温度测试失败..."
	. ${RCD}/failed.sh
    exit 1
fi
