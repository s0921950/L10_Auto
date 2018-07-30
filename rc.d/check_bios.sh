#!/bin/bash
#
# Description: this script for check bios.
# Author: Andrew chuang
# Date: 30/10/2017
#
############# Version ###############

. ${RCD}/functions

failed_log="BIOS"

readonly BIOS_VENDOR="American Megatrends Inc."
#readonly BIOS_VENDOR="Parallels Software International Inc."
readonly BIOS_VERSION="D72F1S05_X64"
#readonly BIOS_VERSION="E61F1P01"
#readonly BIOS_VERSION="13.1.1 (43120)"
readonly BIOS_RELEASE_DATE="06/10/2015"
#readonly BIOS_RELEASE_DATE="12/23/2014"
#readonly BIOS_RELEASE_DATE="10/17/2017"


echo check bios vendor...
vendor=`dmidecode -t bios | awk -F': ' '/Vendor/ {print $2}'`
echo $vendor  $BIOS_VENDOR 
if [ "$vendor" = "$BIOS_VENDOR" ]; then
  pass_message "Bios供应商测试通过..."
else
  fail_message "Bios供应商测试失败..."
  . ${RCD}/failed.sh
  exit 1
fi


echo check bios version...
version=`dmidecode -t bios | awk -F': ' '/Version/ {print $2}' | awk '{print toupper($0)}'`
echo $version   $BIOS_VERSION
if [ "$version" = "$BIOS_VERSION" ]; then
  pass_message "Bios版本测试通过..."
else
  fail_message "Bios版本测试失败..."
  . ${RCD}/failed.sh
  exit 1
fi


echo check bios Release Date...
release_date=`dmidecode -t bios | awk -F': ' '/Release Date/ {print $2}'`
echo $release_date   $BIOS_RELEASE_DATE
if [ "$release_date" = "$BIOS_RELEASE_DATE" ]; then
  pass_message "Bios发布日期测试通过..."
  exit 0
else
  fail_message "Bios发布日期测试失败..."
  . ${RCD}/failed.sh
  exit 1
fi

echo check WtsBios SN...
WtsBios=`dmidecode -t system | awk -F': ' '/Serial Number:/ {print $2}'`
#scan_no_old "Please scan SN number "
#input_WtsBios=$label
echo $ssn  $WtsBios
#if [ "$ssn" = "$WtsBios" ]; then
#    pass_message "WtsBios SN check Pass..."
#    else
#        fail_message "WtsBios SN Fail ..."
#        exit 1
#fi


