#!/bin/bash
#
# Description: this script for check SD and MD card.
# Author: Andrew chuang
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions

home_diss=`ls /media/ | grep 'foxconn'`
#readonly MD5_SOURCE=b32dbc02be1788b19c98af3b9aff4f17
readonly SD_PATH=/media/$home_diss/SD
readonly MD_PATH=/media/$home_diss/MS


while [ 1 ]; do

    echo "请插入SD卡:"
    sleep 2
    check_sd=`fdisk -l | grep "/dev/mmcblk0"`
    if [ -n "$check_sd" ]; then
	# mount -o remount,rw /media/$home_diss/SD
        # cp sd.img $SD_PATH
        # sdMd5Value=`md5sum $SD_PATH/sd.img | awk -F ' '  '{print $1}'`
        # rm $SD_PATH/sd.img
        # if [ "$MD5_SOURCE" != "$sdMd5Value" ]; then
        #    fail_message "SD card test Fail..."
        #   exit 1;
        # fi
        green_message "SD卡测试通过..."
        break
    else
        continue
    fi
done

# confirm "Please insert SD card ?[Y|N]: "
# ans=$?
# while [ $ans -ne 0 ]; do
#     confirm "Please insert SD card ?[Y|N]: "
#     ans=$?
# done

# check_sd=`fdisk -l | grep "/dev/mmcblk0"`
# if [ -n "$check_sd" ]; then
#     green_message "SD card check Pass..."
# else
#     red_message "SD card check Fail ..."
#     exit 1
# fi

#cp sd.img $SD_PATH
#sdMd5Value=`md5sum $SD_PATH/sd.img | awk -F ' '  '{print $1}'`
#rm $SD_PATH/sd.img
#if [ "$MD5_SOURCE" != "$sdMd5Value" ]; then
#    fail_message "SD card test Fail..."
#    exit 1;
#fi

#pass_message "SD card test Pass..."

while [ 1 ]; do

    echo "请插入MS卡:"
    sleep 2
    check_md=`fdisk -l | grep "/dev/mspblk0"`
    if [ -n "$check_md" ]; then
    	green_message "MS卡测试通过..."
        exit 0
        break
    else
        continue
    fi
done

# confirm "Please insert MD card ?[Y|N]: "
# ans=$?
# while [ $ans -ne 0 ]; do
#     confirm "Please insert MD card ?[Y|N]: "
#     ans=$?
# done

# check_md=`fdisk -l | grep "/dev/mspblk0"`
# if [ -n "$check_md" ]; then
#     green_message "MD card check Pass..."
# else
#     red_message "MD card 请插入SD卡?[Y|N]:check Fail ..."
#     exit 1
# fi

#cp sd.img $MD_PATH
#sdMd5Value=`md5sum $MD_PATH/sd.img | awk -F ' '  '{print $1}'`
#rm $MD_PATH/sd.img
#if [ "$MD5_SOURCE" != "$sdMd5Value" ]; then
#    fail_message "MD card test Fail..."
#    exit 1;
#fi

#pass_message "MD card test Pass..."

#sudo mount -o remount,rw /media/foxconn/SD
