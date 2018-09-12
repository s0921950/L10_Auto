#!/bin/bash
#
# Description: this script for check ACPI.
# Author: Andrew chuang
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions

failed_log="LED"

confirm "电源与休眠LED是否皆有亮?[Y|N]: "
ans=$?
if [ $ans -ne 0 ]; then
	red_message "电源与休眠LED测试失败..."
	. ${RCD}/failed.sh
	exit 1
fi
green_message "电源与休眠LED测试通过..."
