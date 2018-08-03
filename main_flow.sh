#!/bin/bash
#
# Description: this script for FFT, a control script
# Author: 
# Date: //2018
#
############# Version ###############
readonly PROGRAM="`basename $0`"
readonly VERSION=""
readonly RELEASEDATE="//2013"
readonly AUTHOR="Aaron Luo"
readonly COPYRIGHT="Copyright(c)2013 Foxconn IND., Group."
export FOX="/home/foxconn/workspace/L10_Auto"

. ${FOX}/rc.d/functions

# show script's information
function version_show()
{
    echo
    echo "$PROGRAM version: $VERSION"
    echo "Release date: $RELEASEDATE"
    echo "Author: $AUTHOR"
    echo "$COPYRIGHT"
    echo
    exit 0
}



function skip_index()
{
    local -i line=`sed -n '/code="'${code}'"/=' ${SEQ}`
    local index=`sed -n "$line,$ p" ${SEQ} | awk '/<unit\./ {gsub("<",""); print $1}' | sed -n '1p'`
    expr ${index#*.} - 1 > ${mboard}
}

# if reboot in middle running, make a sign board
# $1 - test unit's index
# $2 - test command string
function set_sign_board()
{
    strstr "$2" "reboot"
    [ $? -ne 0 ] && return 1
    echo $1 > $mboard

    if [ $err -eq 0 ]; then
        ${RCD}/pfshow -pH
    else
        ${RCD}/pfshow -fH
    fi
    
    # backup log file, before power cycle
    backup_log
    sleep 2
    #read -p "+++++++++++++++++++++++++"

    #$command

    return 0
}

# Get command from .xml file, and execute it
# $1 - first unit's index
# $2 - the last unit's index
function run_scripts()
{
    local unit=$1
    local end=$2
    [ -f $mboard ] && unit=`cat $mboard` && let unit+=1
    while (( $unit <= $end )); do
        eval `xml_parse "unit.$unit" "$SEQ"`
        if [ $err -eq 0 ]; then
            # check current command runs on right level
            boolean ${!Level_Number}
            if [ $? -eq 0 ]; then
                # check keyword - 'reboot', in command
                set_sign_board "$unit" "$command"
                
                run_command "$item" "$command"
                if [ $err -eq 0 ]; then
                    [ -n "${delay}" ] && sleep ${delay}
                    expectancy "$item" "$expected"
                    err=$?
                fi
                [ -z "`pwd | grep -i cli`" ] && showfp "$item" $err
                [ $err -ne 0 -a "$halt" = "0" ] && break
            fi
        else
            err=0
        fi
        
        let unit+=1
    done

    return $err
}

function module_list()
{
    local i=0
    local code2="" module2=""
    local max=`grep -c '<module module=' $SEQ`
    
    green_message "\tCode    Module              Code    Module"
    while [ $i -lt $max ]; do
        let i+=1
        local line=`awk '/<module module/ {gsub(">",""); print $3,$2}' $SEQ | sed -n "$i p"`
        eval $(tr -d '\r' <<< "${line}")
        
        #eval `awk '/<module module/ {gsub(">",""); print $3,$2}' $SEQ | sed -n "$i p"`

        if [ $i -gt 0 -a $(expr $i % 2) -eq 0 ]; then
            printf "\t %-7s%-21s%-7s%-s\n" ${code2} ${module2} ${code} ${module}
        else
            code2=$code
            module2=$module
        fi
    done
}

function usage()
{
    cat << HELP
    
Usage: $0 [OPTION]
    -t [L6 | L10 | L12] [LVI | LX]: execute FFT testing.
    -c [MODULE_NAME]: create config file for test modules
    --mode <mfg | lab>: specified the running envirenment
    --skip <unit.index>: skip the first <unit.index> 
    follow list is the modules' name and the corresponding code:
    `module_list`

    -v, --version: show this script's version info

e.g:
    $0 -c           <- create cfg files for all test modules
    $0 -c memory    <- create cfg files for memory modules

    $0 -t L6        <- FFT runs in L6
    $0 -t L10       <- FFT runs in L10
    $0 -t --skip 40 <- skip first 31 units to do default testing
   
    Below contenct from the config file(/home/station.cfg) for FT Level:
        # L6 / L10 / L12
        Level=${Level_Number}
        # MFG name
        MFG=${whereiam}

    if the current Level does not have this config file(/home/station.cfg),
    please make one for it.
    

HELP
    exit -1
}

# We can not allow a variable be set couple times
function warning()
{
    if [ "$1" = "1" ]; then
        echo "You can double specify running level or factory"
        exit -1
    fi
}

# set running envirnment variables: 
#    Level_Number - specify running level: L6, L10 or L12
#    MFG - specify factory's location: LVI, EPD6 or GDL ...
function initial_level_mfg()
{
    local o=""

    for o in $@ ; do
        o=`echo "$o" | awk '{print toupper($0)}'`
        case $o in
            L6 | L10 | L12)
            warning "${flag[0]}"
            flag[0]=1
            export Level_Number=${o}
            sed -i "/^export Level_Number/c\export Level_Number=\"${o}\"" \
                    ${CFG}/public.env
            ;;

            LVI | LX )
            warning "${flag[1]}"
            flag[1]=1
            export whereiam=${o}
            sed -i "/^export whereiam/c\export whereiam=\"${o}\"" \
                    ${CFG}/public.env
            ;;

            *)
            ;;
            
        esac
    done
}


#############################################################
################ Pre-Test Prepare ###########################
declare -a flag=(0 0 0)
declare -i code=1
declare envi=""

while [ -n "$1" ]; do
    case "$1" in
        -t)
#       if [ $# -gt 1 ]; then
#       var="$@"
#       elif [ -f /home/station.cfg ]; then
#           . /home/station.cfg
#           [ -z "${Level}" -o -z "${MFG}" ] && usage
#           
#           var="${Level} ${MFG}"
#           unset Level
#           unset MFG
#       elif [ `grep -c 'MFG=' /proc/cmdline` -ne 0 ]; then
#           var=`awk '{for (i=1;i<=NF;i++) if ($i ~ /MFG=/) print $i}' /proc/cmdline`
#           var=${var#MFG=}
#           var="${var/,/ }"
#       fi

        var="-t L10"
        [ -n "$var" ] && initial_level_mfg "$var"

        # export running variables again ...
        . ${CFG}/public.env

        # flag of doing test
        flag[2]=1
        ;;

        --skip)
        [ -z "$2" ] || [ `echo "$2 + 0"| bc` -eq 0 ] && usage
        code=$2
        ;;

        --mode)
        [ -z "$2" ] && usage
        envi=`echo $2 | awk '{print tolower($0)}'`
        [ "$envi" != "lab" -a "$envi" != "mfg" ] && usage
        ;;

        -v | --version)
        version_show
        ;;

#Add below to main_flow.sh script:
        -p)
        [ -z "$2" ] || [ "$2" != "INIT" -a "$2" != "FT" ] && usage
        export phase="$2"
        ;;

        *)
        ;;
    esac
    shift
done

[ ${flag[2]} -eq 0 ] && usage

if [ ${flag[0]} -eq 0 ];then
    red_message "Must indicate run level[L6/L10]" 
    red_message "ex. ./main_flow.sh -t L6  or ./main_flow.sh -t L10" 
    exit 1
fi

#############################################################
############# Test Start from here ##########################
[ -d "/log/diag" -a -d "/log/tmp" ] || mkdir -p /log/{diag,tmp} > /dev/null 2>&1

env_clean > /dev/null 2>&1              #close by andy 2014-08-25

# Get the start time
if [ ! -f ${startime} ]; then
    touch ${startime}
    $LS ${startime} | awk '{print $6, substr($7,1,8)}' > ${startime}
    rm -fr ${REPORT}
fi > /dev/null 2>&1

#restore_log

{

    # It needs to scan barcode if FFT runs in L10
    if [ ${Level_Number} = "L6" ] || [ ${Level_Number} = "L10" ] ; then
        # ${RCD}/Version.sh
        . scanid.sh
        [ $? -ne 0 ] && exit 250
    fi
    #Add for control INIT or FT by Madison
    #. ${RCD}/Phase_check.sh
    . env_init.sh
    [ $code -gt 1 ] && skip_index
    
    eval `awk '/^<sequence/ {gsub(">",""); for(c=2;c<=NF;c++) print $c}' ${SEQ}`
    [ -n "$envi" ] && runenv=$envi
    export runenv

    # Run test scripts
    run_scripts 1 ${quanta}
    # if [ -s "$REPORT" ]; then
    #     ${RCD}/pfshow -fH
    #     err=`awk '{if(/@ERRORCODE/) err=$NF} END{print err}' $REPORT`
    # else
    #     ${RCD}/pfshow -phase
    #     cd ${RCD}
    #     ./wflag.sh ft
    # fi
} 2>&1 
. ${CFGFILE}
#. ${RCD}/phase.flag
# summary the test log
# summary_log_file ${LOGFILE}

# upload the final test log file to sfc
#cd ${RCD}
#./wflag.sh init
#./sfc.sh -l $FINALLOG   

# remove the temp files
env_clean > /dev/null 2>&1              #close by andy 2014-08-25

cd ${RCD}
if [ $err -ne 0 ]; then
    # ./id_led.sh fail &
    echo
    while ((1)); do
        read -p "Do you want to shutdown the system?[Y|N]: " ans
        boolean ${ans}
        ans=$?
        [ $ans -eq 0 ] && poweroff
        [ $ans -eq 1 ] && exit $err
    done
fi

#cd ${RCD}
#./wflag.sh init
  
# ./id_led.sh pass &
# [ ${Level_Number} = "L12" ] && sleep 10 && poweroff

# For L6 and L10
    # cd ${RCD}
    # ./send_ccc.sh -t
read -p "FT PASS!!! Please Press Enter key to shutdown..."
#read -p "Please Press Enter key to reboot..."
# poweroff -f
#reboot

