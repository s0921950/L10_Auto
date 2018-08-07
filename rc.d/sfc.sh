celerpath_L10_FT=/mnt/celer_l10_ft

function red_message()
{
    tput bold
    echo -ne "\033[31m$@\033[0m"
    tput sgr0
    echo
}

ssn=`cat ${FOX}/ssn`
op_id=`cat ${FOX}/op_id`
station_id="A05P101"
#op_id="F9206062"
echo $ssn    $station_id   $op_id

    sudo mkdir -p $celerpath_L10_FT

    sudo mount -t cifs -o username='administrator',password='PCE$HZ&ABD$2016' //10.1.1.1/celer/L10_TEST /mnt/celer_l10_ft

	rm -rf $celerpath_L10_FT/$ssn.PTER
	echo -e "${ssn} \r\n${station_id} \r\n${op_id} \r\nPASS \r\n" >> $celerpath_L10_FT/$ssn.ppp

    i=0
    while (($i<30))
    do
        if [ -f $celerpath_L10_FT/$ssn.PTOK ]; then
            up_result="OK"
            break
        else
            if [ -f $celerpath_L10_FT/$ssn.PTER ]; then
                up_result="ERROR"
                error_msg=`cat $celerpath_L10_FT/$ssn.PTER`
                break
            else
                echo -ne "wait for celer \n"
                echo -ne "${ssn} \n"
                sleep 1
            fi
        fi
        i=$(($i+1))
    done

    if [ "$up_result" = "OK" ];then
 		echo         "*********** FFT TEST OK ***************"
		echo         ""
		echo         "XXXXXXX     XXXX     XXXXXX    XXXXXX"
		echo         "XXXXXXXX   XXXXXX   XXXXXXXX  XXXXXXXX"
		echo         "XX    XX  XX    XX  XX     X  XX     X"
		echo         "XX    XX  XX    XX   XXX       XXX"
		echo         "XXXXXXXX  XXXXXXXX    XXXX      XXXX"
		echo         "XXXXXXX   XXXXXXXX      XXX       XXX"
		echo         "XX        XX    XX  X     XX  X     XX"
		echo         "XX        XX    XX  XXXXXXXX  XXXXXXXX"
		echo         "XX        XX    XX   XXXXXX    XXXXXX"
		echo         ""
		echo         "**************************************"
        exit 0
    else
    	red_message  $error_msg
		echo         "*********** FFT TEST error *************"
		echo         ""
        echo         "   XXXXXXX    XXXXXX   XXXXXXXX  XXX"
		echo         "   XX        XX    XX     XX     XXX"
		echo         "   XX        XX    XX     XX     XXX"
		echo         "   XXXXXXX   XXXXXXXX     XX     XXX"
		echo         "   XXXXXXX   XXXXXXXX     XX     XXX"
		echo         "   XX        XX    XX     XX     XXX"
		echo         "   XX        XX    XX  XXXXXXXX  XXXXXXXX"
		echo         "   XX        XX    XX  XXXXXXXX  XXXXXXXX"
		echo         ""
		echo         "*******************************************"

		exit 0
    fi
