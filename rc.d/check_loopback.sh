#!/bin/bash
#
# Description: this script for check SD and MD card.
# Author: 
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions

readonly MUSIC_SOURCE=thund.wav
readonly RECORD_PATH=/tmp/
readonly RECORD_FILE=thund_test.wav
readonly MIN_VOLUME=5

failed_log="Loopback"

echo start loopback test ...

amixer sset Master unmute
#amixer -D pulse sset Master unmute
amixer sset Master 100%
#amixer -D pulse sset Master 100%

arecord -d 5 $RECORD_PATH$RECORD_FILE & aplay $MUSIC_SOURCE
#arecord -d 5 $RECORD_PATH$RECORD_FILE 

if [ ! -f $RECORD_PATH$RECORD_FILE ]; then
    red_message "音源回路测试失败..."
    # . ${RCD}/failed.sh
    exit 1 
fi

#volume_adjustment=`sox $RECORD_PATH$RECORD_FILE -n stat -v | awk '{printf ("%.2f\n", $1)}'`
volume_adjustment=`sox $RECORD_PATH$RECORD_FILE -n stat -v 2>&1 | tail -1`
#volume_adjustment=1.000

echo $volume_adjustment

echo $volume_adjustment | grep "[^0-9,\.]" && {
    red_message "音源回路测试失败..."
    # . ${RCD}/failed.sh
    exit 1
}
    if [ `echo "$MIN_VOLUME < $volume_adjustment" | bc` -eq 1 ]; then
        red_message "音源回路测试失败..."
        # . ${RCD}/failed.sh
        exit 1
    fi

failed_log=Speaker

green_message "音源回路测试通过..."
exit 0

#confirm "请移除音源回路线?[Y|N]: "
#ans=$?
#if [ $ans -ne 0 ]; then
#    while [ $ans -ne 0 ]; do
#        confirm "请移除音源回路线?[Y|N]: "
#        ans=$?
#    done
#fi

#aplay $RECORD_PATH$RECORD_FILE & confirm "喇叭声音是否正常?[Y|N]: "
#ans=$?
#if [ $ans -ne 0 ]; then
#    fail_message "喇叭测试失败..."
#    . ${RCD}/failed.sh
#    exit 1
#fi
#pass_message "喇叭测试通过..."

