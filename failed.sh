#!/bin/bash
#
# Description: 
# Author: 
# Date: 
#
############# Version ###############

. ${RCD}/functions

#confirm "确认重新开始测试(Y)或上传失败日誌(N):  "
confirm "确认重新测试(Y)或关机(N):  "
ans=$?
#echo $failed_log

while [[ $ans -ne 0 && $ans -ne 1 ]]; do
#    confirm "确认重新开始测试(Y)或上传失败日誌(N):  "
    confirm "确认重新测试(Y)或关机(N):  "
    ans=$?
done
if [ "$ans" -ne 0 ]; then
	shutdown -h now
elif [ "$ans" -eq 0 ]; then
	# . ${RCD}/main_flow_failed.sh -t
	if [ "$failed_log" = "TIME" ]; then
		. ${RCD}/main_flow.sh -t --skip 2
	elif [ "$failed_log" = "BIOS" ]; then
		. ${RCD}/main_flow.sh -t --skip 3
	elif [ "$failed_log" = "CPU temperature" ]; then
		. ${RCD}/main_flow.sh -t --skip 4
	elif [ "$failed_log" = "USB" ]; then
		. ${RCD}/main_flow.sh -t --skip 5
	elif [ "$failed_log" = "LED" ]; then
		. ${RCD}/main_flow.sh -t --skip 6
	elif [ "$failed_log" = "Loopback" ]; then
		. ${RCD}/main_flow.sh -t --skip 9
	else
		. ${RCD}/main_flow.sh -t
	fi
fi
