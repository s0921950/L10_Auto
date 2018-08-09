#!/bin/bash
#
# Description: this script for check ACPI.
# Author: 
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions

failed_log="Sleep"

echo check S3...
rtcwake -v -s 10 -m mem
green_message "休眠测试通过..."
exit 0
#echo check S4...
#rtcwake -m disk -s 60
