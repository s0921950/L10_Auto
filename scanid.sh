#!/bin/bash
# This script will accept follow things:
#     Operator ID
#     Product Name
#     Product Number
#     Serial Number
#     Asset Tag
#

#readonly VERSION="0.0.0.1"
#readonly RELEASEDATE="10/23/2017"

declare cfm=""    # confirm information
declare label=""
declare product_name=""
declare part_number=""
declare BCENV="${SIGNBOARD}.barcode.env"

ssn="THF11U0C0573300104"
#station_id="A01P112"
station_id="A05P101"
#op_id="F9206062"
op_id="G0700067"

# 1 - iBMC
# 2 - I350 Ethernet Adapter
declare -i lan_count=2

# it has to record everything key type into test log
# so scan() has job to handle of this
function scan()
{
    local id=
    declare -i len=0
    local title=`echo ${1} | sed 's/_/ /g'`

    label=""
    while [ -z "$label" ]; do
        [ "${runenv}" = "lab" ] && id="`grep "${1#Confirm_*}" ${CFGFILE} | awk -F'"' '{print $2}'`"
#        [ -z "$label" ] && id="`grep "${1#Confirm_*}" ${CFGFILE} | awk -F'"' '{print $2}'`"

        # We do this just for make sure the input can be recorded into log file
        # Or you can try like this example:
        # read -p "Type your need: " var
        # But it has to improve
        tput bold
        if [ `echo $1 | grep -c "Confirm_"` -eq 0 ]; then
            echo -n "${title#Confirm*}[$id]: "
        else
            echo -ne "\033[32mConfirm\033[0m${title#Confirm*}[$id]: "
        fi
        tput sgr0
        while ((1)); do
           read -s -n 1 ch
           dec=`printf "%d" "'$ch"`
           [ $dec -eq 0 ] && break
           if [ $dec -eq 8 -o $dec -eq 127 ] && [ $len -gt 0 ]; then
               echo -ne '\b \b'
               let len-=1
               [ $len -gt 0 ] && label=`echo $label | cut -c -$len`
               [ $len -eq 0 ] && label=""
           fi
           [ $dec -lt 33 ] || [ $dec -gt 126 ] && continue
           echo -n $ch
           [ -z "$ch" ] && echo && break
           label="${label}""$ch"
           let len+=1
        done
        [ -z "$label" ] && [ ! -z $id ] && label=$id
    done
    label=`echo $label | awk '{print toupper($0)}'`
    echo
}

#No old value
function scan_no_old()
{
    local id=
    declare -i len=0
    local title=`echo ${1} | sed 's/_/ /g'`

    label=""
    while [ -z "$label" ]; do
        #[ -z "$label" ] && id="`grep "${1#Confirm_*}" ${CFGFILE} | awk -F'"' '{print $2}'`"

        # We do this just for make sure the input can be recorded into log file
        # Or you can try like this example:
        # read -p "Type your need: " var
        # But it has to improve
        tput bold
        if [ `echo $1 | grep -c "Confirm_"` -eq 0 ]; then
            echo -n "${title#Confirm*}: "
        else
            echo -ne "\033[32mConfirm\033[0m${title#Confirm*}: "
        fi
        tput sgr0
        while ((1)); do
           read -s -n 1 ch
           dec=`printf "%d" "'$ch"`
           [ $dec -eq 0 ] && break
           if [ $dec -eq 8 -o $dec -eq 127 ] && [ $len -gt 0 ]; then
               echo -ne '\b \b'
               let len-=1
               [ $len -gt 0 ] && label=`echo $label | cut -c -$len`
               [ $len -eq 0 ] && label=""
           fi
           [ $dec -lt 33 ] || [ $dec -gt 126 ] && continue
           echo -n $ch
           [ -z "$ch" ] && echo && break
           label="${label}""$ch"
           let len+=1
        done
        echo
        #[ -z "$label" ] && [ ! -z $id ] && label=$id
    done
    label=`echo $label | awk '{print toupper($0)}'`
    echo
}

#Get Op ID and station ID
function scan_opid_sid()
{
    #if [ "$whereiam" != "GDL" ]; then
    while (( 1 )); do
        scan_no_old "Operator_ID"
        op_id=$label
        scan_no_old "Confirm_Operator_ID"
        [ "$op_id" != "$label" ] && continue

        break
    done

    while (( 1 )); do
        # Get station id
        scan_no_old "Station_ID"
        station_id=$label
        scan_no_old "Confirm_Station_ID"
        [ "$station_id" != "$label" ] && continue
    
        break
    done
}

##### start from here ##########################################
echo "请扫描:"
#scan_opid_sid
while (( 1 )); do
    scan_no_old "请扫描工号"
    op_id=$label
#    scan_no_old "请确认工号"
#    [ "$op_id" != "$label" ] && continue
    if [ `expr length ${label}` != 8 ];then
      label=""
      echo "请扫描八位数工号"
      continue
    fi
    echo -e "${op_id}" > op_id
    break
done

echo "请扫描条码:"
#scan Product SN
while ((1)); do
    scan_no_old "请扫描产品序号"
    ssn=$label
    scan_no_old "请确认产品序号"
    [ "$ssn" != "$label" ] && continue
    echo -e "${ssn}" > ssn
    break
done

