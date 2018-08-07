#!/bin/bash
#
# Description: this script for check SD and MD card.
# Author: 
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions


#readonly home_dis=`echo $OLDPWD | awk -F '/' '{print $3}'`
readonly home_dis=`ls /media/`
readonly MD5_SOURCE=b32dbc02be1788b19c98af3b9aff4f17
readonly USB1_PATH=/media/$home_dis/USB1
readonly USB2_PATH=/media/$home_dis/USB2
readonly USB3_PATH=/media/$home_dis/USB3
readonly USB4_PATH=/media/$home_dis/USB4
readonly USB5_PATH=/media/$home_dis/USB5

failed_log="USB"

while [ 1 ]; do
    check_usb1=`ls /media/$home_dis/ | grep "USB1"`
    check_usb2=`ls /media/$home_dis/ | grep "USB2"`
    check_usb3=`ls /media/$home_dis/ | grep "USB3"`
    check_usb4=`ls /media/$home_dis/ | grep "USB4"`
    check_usb5=`ls /media/$home_dis/ | grep "USB5"`
    echo "请插入所有U盘: ${check_usb1} ${check_usb2} ${check_usb3} ${check_usb4} ${check_usb5}"
    sleep 1
    if [ -n "$check_usb1" ] && [ -n "$check_usb2" ] && [ -n "$check_usb3" ] && [ -n "$check_usb4" ] && [ -n "$check_usb5" ]; then
        cp sd.img $USB1_PATH
        usb1Md5Value=`md5sum $USB1_PATH/sd.img | awk -F ' '  '{print $1}'`
        rm $USB1_PATH/sd.img
        if [ "$MD5_SOURCE" != "$usb1Md5Value" ]; then
            red_message "USB1测试失败..."
            . ${RCD}/failed.sh
            exit 1;
        fi
        green_message "USB1测试通过..."

        cp sd.img $USB2_PATH
        usb2Md5Value=`md5sum $USB2_PATH/sd.img | awk -F ' '  '{print $1}'`
        rm $USB2_PATH/sd.img
        if [ "$MD5_SOURCE" != "$usb2Md5Value" ]; then
            red_message "USB2测试失败..."
            . ${RCD}/failed.sh
            exit 1;
        fi
        green_message "USB2测试通过..."

        cp sd.img $USB3_PATH
        usb3Md5Value=`md5sum $USB3_PATH/sd.img | awk -F ' '  '{print $1}'`
        rm $USB3_PATH/sd.img
        if [ "$MD5_SOURCE" != "$usb3Md5Value" ]; then
            red_message "USB3测试失败..."
            . ${RCD}/failed.sh
            exit 1;
        fi
        green_message "USB3测试通过..."
        
        cp sd.img $USB4_PATH
        usb4Md5Value=`md5sum $USB4_PATH/sd.img | awk -F ' '  '{print $1}'`
        rm $USB4_PATH/sd.img
        if [ "$MD5_SOURCE" != "$usb4Md5Value" ]; then
            red_message "USB4测试失败..."
            . ${RCD}/failed.sh
            exit 1;
        fi
        green_message "USB4测试通过..."

        cp sd.img $USB5_PATH
        usb5Md5Value=`md5sum $USB5_PATH/sd.img | awk -F ' '  '{print $1}'`
        rm $USB5_PATH/sd.img
        if [ "$MD5_SOURCE" != "$usb5Md5Value" ]; then
            red_message "USB5测试失败..."
            . ${RCD}/failed.sh
            exit 1;
        fi
        green_message "USB5测试通过..."
        exit 0
        break
    else
        continue
    fi
done

# cp sd.img $USB4_PATH
# usb4Md5Value=`md5sum $USB4_PATH/sd.img | awk -F ' '  '{print $1}'`
# rm $USB4_PATH/sd.img
# if [ "$MD5_SOURCE" != "$usb4Md5Value" ]; then
#     red_message "USB4 test Fail..."
#     exit 1;
# fi

# green_message "USB4 test Pass..."

#cp sd.img $USB5_PATH
#usb5Md5Value=`md5sum $USB5_PATH/sd.img | awk -F ' '  '{print $1}'`
#rm $USB5_PATH/sd.img
#if [ "$MD5_SOURCE" != "$usb5Md5Value" ]; then
#    red_message "USB5 test Fail..."
#    exit 1;
#fi

#green_message "USB5 test Pass..."

