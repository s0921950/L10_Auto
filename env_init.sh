#!/bin/bash
#
# Init test envirnment
#
. ${FOX}/rc.d/functions

# if [ -z "${VERSION}" ]; then
#     readonly VERSION="3.1.187.0"
#     readonly RELEASEDATE="//2018"
# fi

function show_platform_info()
{
    cd $FOX
    echo
    echo "Platform information: "
    echo "Kernel version: `uname -r`"
    echo "GNU C libary version: `ldd --version | awk '/libc/ {print $4}'`"
    echo "GCC version: `gcc --version|awk '/GCC/ {print $3}'`"
    # echo "Diagnostic version: `awk '/Version/ {print $2}' ChangeLog | sed -n '1p'`"
    # echo "Release date: `awk '/Release date/ {print $NF}' ChangeLog | sed -n '1p'`"
}

function shutdown_led()
{
    service ipmi start > /dev/null 2>&1
    wait && sleep 1

    # make sure the BMC led is off
    killall 'id_led.sh' > /dev/null 2>&1

    ipmitool raw 00 04 00 00
    sleep 1
}

function clean_env()
{
    # clear error report file
    [ -n "$REPORT" ] && rm -fr $REPORT
    rm -fr $FOX/tmp/*
    rm -fr $CLI/log/*
}

function load_test_driver()
{
    lsmod | grep "clidriver"
    if [ $? -ne 0 ];then
        insmod /usr/local/Foxconn/CLI/driver/clidriver.ko
    fi
    return 0
}

function bios_init()
{
    cd ${INIT}/bios

    rm -fr *.BIN
    ln -snf afulnx2.$(arch) afulnx2

    ln -snf ${FWHOME}/bios/${BIOS}.BIN ${BIOS}.BIN
    if [ ! -f ${BIOS}.BIN ]; then
        err=1
        red_message "There is no BIOS binary file!"
        exit $err
    fi
}

function bmc_init()
{
    cd ${INIT}/bmc
    rm -fr *.rom *.bin

    ln -snf bmcfwul.$(arch) bmcfwul
    ln -snf libkcsio.so.$(arch) libkcsio.so
    ln -snf libopenraw.so.$(arch) libopenraw.so
    err=$?
    [ $err -ne 0 ] && exit $err

    local bin=""
    for bin in `ls -1 ${FWHOME}/bmc | grep -i "$BMC"`
    do
        ln -snf ${FWHOME}/bmc/${bin} ${bin}
        if [ ! -f ${bin} ]; then
            err=2
            red_message "There is no BMC firmware!"
            exit $err
        fi
    done
    #   ln -snf ${FWHOME}/bmc/Linux/update.sh update_1218.sh
}

function dmi_init()
{
    [ ! -d ${INIT}/dmi ] && return 0
    cd ${INIT}/dmi
    ln -snf amidelnx_26.$(arch) amidelnx
    err=$?
    [ $err -ne 0 ] && exit $err
}

function ini_file_init()
{
    if [ "${Part_Number}" = "1A428BN00-600-G" ];then
        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

        lspci | grep QLogic
        result_Q=$?
        if [ $result_Q -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
        fi

        lspci | grep Mellanox
        result_M=$?
        if [ $result_M -eq 0 ];then
            hdd_model=`smartctl -i /dev/sdd | awk -F':' '/Device Model/ {gsub(" ",""); print $NF}'`
            if [ "$hdd_model" = "ST8000NM0055-1RM112" ];then
                cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
            elif [ "$hdd_model" = "HGSTHUH728080ALE600" ];then
                cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
            else
                err=10
                red_message "HDD model is wrong."
                exit $err
            fi
        fi
        if [ ! -d $CLI/cfg/${Part_Number} ];then
            err=11
            red_message "There is no ini file for ${Part_Number}."
            exit $err
        fi

        if [ $result_Q -ne 0 -a $result_M -ne 0 ];then
            err=12
            red_message "25G card is wrong."
            exit $err
            fi
    fi

   # if [ "${Part_Number}" = "1A428RK00-600-G" ];then

       # [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

       # dmidecode -t memory|grep -i Manufacturer|grep Hynix
       # if [ $? -eq 0 ];then
       #     cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
      #  fi

     #   dmidecode -t memory|grep -i Manufacturer|grep Micron
    #    if [ $? -eq 0 ];then
   #         cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
  #      fi
 #   fi

    if [ "${Part_Number}" = "1A428RK00-600-G" ];then

        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

            hdd_type=`smartctl -i /dev/sdd | awk -F':' '/Device Model/ {gsub(" ",""); print $NF}'`
            if [ "$hdd_type" = "SAMSUNGMZ7KM1T9HAJM-00005" ];then
                cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
            elif [ "$hdd_type" = "SDLF1CRR-019T-1HAB" ];then
                cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
            else
                err=10
                red_message "HDD type is wrong."
                exit $err
            fi
        fi
   # if [ "${Part_Number}" = "1A4292W00-600-G" ];then

    #    [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

     #   dmidecode -t memory|grep -i Manufacturer|grep Hynix
      #  if [ $? -eq 0 ];then
       #     cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
       # fi

        #dmidecode -t memory|grep -i Manufacturer|grep Samsung
        #if [ $? -eq 0 ];then
        #    cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
      #  fi
   # fi

  #  if [ "${Part_Number}" = "1A428RH00-600-G" ];then

   #     [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

    #    dmidecode -t memory|grep -i Manufacturer|grep Hynix
     #   if [ $? -eq 0 ];then
      #      cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
      #  fi

       # dmidecode -t memory|grep -i Manufacturer|grep Samsung
       # if [ $? -eq 0 ];then
       #     cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
       # fi
 #   fi


    if [ "${Part_Number}" = "1A42ABC00-600-G" ];then

        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

        HM=`smartctl -i /dev/sdd | awk -F':' '/Device Model/ {gsub(" ",""); print $NF}'`
        if [ "$HM" = "ST6000NM0024-1HT17Z" ];then
            cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
        elif [ "$HM" = "TOSHIBAMG04ACA600E" ];then
            cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
        elif [ "$HM" = "HGSTHUS726060ALE610" ];then
            cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
        else
            err=10
            red_message "HDD model is wrong."
            exit $err 
        fi
    fi

    if [ "${Part_Number}" = "1A428RJ00-600-G" ];then

        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

        lsscsi |grep -i ST8000NM0055
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_2 $CLI/cfg/${Part_Number}
        else
            cp -fr $CLI/cfg/${Part_Number}_1 $CLI/cfg/${Part_Number}
        fi
    fi


    if [ "${Part_Number}" = "1A428RM00-600-G" ];then
        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

        subdid=`lspci -s 04:00.0  -xxx|sed -n 4p|awk '{print $16}'`
        lsscsi |grep ST8000NM0055
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_1 $CLI/cfg/${Part_Number}
            cd $CLI/cfg/${Part_Number}
            if [ $subdid -eq 32 ];then
                cp hwchk32.xml hwchk.xml
                cp PCI32.XML PCI.XML
            else
                cp hwchk30.xml hwchk.xml
                cp PCI30.XML PCI.XML
            fi
            cd -
        fi
        lsscsi |grep HUH728080AL
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_2 $CLI/cfg/${Part_Number}
            cd $CLI/cfg/${Part_Number}
            if [ $subdid -eq 32 ];then
                cp hwchk32.xml hwchk.xml
                cp PCI32.XML PCI.XML
            else
                cp hwchk30.xml hwchk.xml
                cp PCI30.XML PCI.XML
            fi
            cd -
        fi
    fi


#H43.2b
     if [ "${Part_Number}" = "1A42CEE00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
           fi
       fi


  #H41************************
     if [ "${Part_Number}" = "1A42B7800-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
           fi
       #    if [ ! -f $CFG/${Part_Number}/HWCHK.xml ];then
       #      red_message "There is no HWCHK.xml file for ${Part_Number}."
       #      exit 1
       # fi

    fi
#N49.22
     if [ "${Part_Number}" = "1A42CSG00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
           fi
       #    if [ ! -f $CFG/${Part_Number}/HWCHK.xml ];then
       #      red_message "There is no HWCHK.xml file for ${Part_Number}."
       #      exit 1
       # fi

    fi
#N42.2B
     if [ "${Part_Number}" = "1A42BGE00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
           fi
       #    if [ ! -f $CFG/${Part_Number}/HWCHK.xml ];then
       #      red_message "There is no HWCHK.xml file for ${Part_Number}."
       #      exit 1
       # fi

    fi
 
    
     if [ "${Part_Number}" = "1A42CRN00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
       fi
    
    
    
    
    # H42.22
     if [ "${Part_Number}" = "1A42BHB00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
       fi
    #H43************************
     if [ "${Part_Number}" = "1A42BGF00-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 hdd=`lsscsi | grep "INTEL" | awk '{print $NF}'`
                  hdd_model=`smartctl -i $hdd | awk -F':' '/Device Model/ {gsub(" ",""); print $NF}'`
                  if [ "$hdd_model" = "INTELSSDSCKHB340G4" ];then     
                           cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
                      else 
                           cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
                      fi
             fi

             dmidecode -t memory|grep -i Manufacturer|grep Samsung
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
             fi
     fi
##########################################################################
     if [ "${Part_Number}" = "1A42BG900-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
       fi
     #N41-6T.2B
     if [ "${Part_Number}" = "1A42BH500-600-G" ];then
  
             [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
  
             dmidecode -t memory|grep -i Manufacturer|grep Hynix
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
           fi
  
             dmidecode -t memory|grep -i Manufacturer|grep Micron
             if [ $? -eq 0 ];then
                 cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
           fi
       fi

    if [ "${Part_Number}" = "1A42CRJ00-600-G" ];then

        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

        dmidecode -t memory|grep -i Manufacturer|grep Hynix
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
        fi
             dmidecode -t memory|grep -i Manufacturer|grep Micron
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
        fi
            dmidecode -t memory|grep -i Manufacturer|grep Samsung
        if [ $? -eq 0 ];then
            cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
        fi
    fi    

  #W41************************
     if [ "${Part_Number}" = "1A42CRE00-600-G" ];then

         [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

         dmidecode -t memory|grep -i Manufacturer|grep Hynix
         if [ $? -eq 0 ];then
             cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
         fi

         dmidecode -t memory|grep -i Manufacturer|grep Samsung
         if [ $? -eq 0 ];then
             cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
         fi
     fi

 #N32************************
     if [ "${Part_Number}" = "1A42B6L00-600-G" ];then

         [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

         dmidecode -t memory|grep -i Manufacturer|grep Hynix
         if [ $? -eq 0 ];then
             cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
         fi

         dmidecode -t memory|grep -i Manufacturer|grep  Micron
         if [ $? -eq 0 ];then
             cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
         fi

         dmidecode -t memory|grep -i Manufacturer|grep  Samsung
         if [ $? -eq 0 ];then
             cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
         fi
     fi
  #N48************************
        if [ "${Part_Number}" = "1A42CEJ00-600-G" ];then
   
                [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
   
                dmidecode -t memory|grep -i Manufacturer|grep Hynix
                if [ $? -eq 0 ];then
                    cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
              fi
   
                dmidecode -t memory|grep -i Manufacturer|grep Micron
                if [ $? -eq 0 ];then
                    cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
              fi
                dmidecode -t memory|grep -i Manufacturer|grep Samsung
                if [ $? -eq 0 ];then
                    cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
              fi
          #    if [ ! -f $CFG/${Part_Number}/HWCHK.xml ];then
          #      red_message "There is no HWCHK.xml file for ${Part_Number}."
          #      exit 1
          # fi
   
       fi


      #N49************************
            if [ "${Part_Number}" = "1A42BH100-600-G" ];then
     
                     [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
     
                     dmidecode -t memory|grep -i Manufacturer|grep Hynix
                     if [ $? -eq 0 ];then
                         cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
                   fi
     
                     dmidecode -t memory|grep -i Manufacturer|grep Micron
                     if [ $? -eq 0 ];then
                         cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
                   fi
                     dmidecode -t memory|grep -i Manufacturer|grep Samsung
                     if [ $? -eq 0 ];then
                         cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
                   fi
                                                            
            fi
            if [ "${Part_Number}" = "1A42CQN00-600-G" ];then
                [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}

                dmidecode -t memory|grep -i Manufacturer|grep Hynix
                if [ $? -eq 0 ];then
                     cp -fr $CLI/cfg/${Part_Number}_W01 $CLI/cfg/${Part_Number}
                fi
                 dmidecode -t memory|grep -i Manufacturer|grep Micron
                 if [ $? -eq 0 ];then
                     cp -fr $CLI/cfg/${Part_Number}_W02 $CLI/cfg/${Part_Number}
                 fi
                 dmidecode -t memory|grep -i Manufacturer|grep Samsung
                 if [ $? -eq 0 ];then
                     cp -fr $CLI/cfg/${Part_Number}_W03 $CLI/cfg/${Part_Number}
                 fi
             fi



    #N42 ********************
    if [ "${Part_Number}" = "1A428D400-600-G" ];then
        [ -d $CLI/cfg/${Part_Number} ] && rm -fr $CLI/cfg/${Part_Number}
        subdid=`lspci -s 04:00.0  -xxx|sed -n 4p|awk '{print $16}'`

        hdd_model=`smartctl -i /dev/sdd | awk -F':' '/Device Model/ {gsub(" ",""); print $NF}'`
        if [ "$hdd_model" = "ST6000NM0024-1HT17Z" ];then
            cp -fr $CLI/cfg/${Part_Number}_4 $CLI/cfg/${Part_Number}
            cd $CLI/cfg/${Part_Number}
            if [ $subdid -eq 32 ];then
                cp hwchk32.xml hwchk.xml
                cp PCI32.XML PCI.XML
            else
                cp hwchk30.xml hwchk.xml
                cp PCI30.XML PCI.XML
            fi
            cd -
        elif [ "$hdd_model" = "WDCWD6001FSYZ-01SS7B2" ];then
            select_mem=`dmidecode -t memory |grep -i "Manufacturer:" |sed -n 1p |awk '{print $2}'`

            if [ "$select_mem" = "Samsung" ];then
                cp -fr $CLI/cfg/${Part_Number}_6 $CLI/cfg/${Part_Number}
                cd $CLI/cfg/${Part_Number}
                if [ $subdid -eq 32 ];then
                    cp hwchk32.xml hwchk.xml
                    cp PCI32.XML PCI.XML
                else
                    cp hwchk30.xml hwchk.xml
                    cp PCI30.XML PCI.XML
                fi
                cd -
            elif [ "$select_mem" = "Hynix" ];then
                cp -fr $CLI/cfg/${Part_Number}_3 $CLI/cfg/${Part_Number}
                cd $CLI/cfg/${Part_Number}
                if [ $subdid -eq 32 ];then
                    cp hwchk32.xml hwchk.xml
                    cp PCI32.XML PCI.XML
                else
                    cp hwchk30.xml hwchk.xml
                    cp PCI30.XML PCI.XML
                fi
                cd -
            else
                err=14
                red_message "There is no this config for ${Part_Number}"
                exit $err
            fi

        elif [ "$hdd_model" = "TOSHIBAMG04ACA600E" ];then
            cp -fr $CLI/cfg/${Part_Number}_2 $CLI/cfg/${Part_Number}
            cd $CLI/cfg/${Part_Number}
            if [ $subdid -eq 32 ];then
                cp hwchk32.xml hwchk.xml
                cp PCI32.XML PCI.XML
            else
                cp hwchk30.xml hwchk.xml
                cp PCI30.XML PCI.XML
            fi
            cd -
        elif [ "$hdd_model" = "HGSTHUS726060ALE610" ];then
            select_mem=`dmidecode -t memory |grep -i "Manufacturer:" |sed -n 1p |awk '{print $2}'`

            if [ "$select_mem" = "Samsung" ];then
                cp -fr $CLI/cfg/${Part_Number}_5 $CLI/cfg/${Part_Number}
                cd $CLI/cfg/${Part_Number}
                if [ $subdid -eq 32 ];then
                    cp hwchk32.xml hwchk.xml
                    cp PCI32.XML PCI.XML
                else
                    cp hwchk30.xml hwchk.xml
                    cp PCI30.XML PCI.XML
                fi
                cd -
            elif [ "$select_mem" = "Micron" ];then
                cp -fr $CLI/cfg/${Part_Number}_1 $CLI/cfg/${Part_Number}
                cd $CLI/cfg/${Part_Number}
                if [ $subdid -eq 32 ];then
                    cp hwchk32.xml hwchk.xml
                    cp PCI32.XML PCI.XML
                else
                    cp hwchk30.xml hwchk.xml
                    cp PCI30.XML PCI.XML
                fi
                cd -
            else
                err=16
                red_message "There is no this config for ${Part_Number}"
                exit $err
            fi

        else
            err=15
            red_message "HDD model is wrong for ${Part_Number}"
            exit $err
        fi
    fi
    #N42************************
}


# Start from here ###########################################
err=0
. ${CFGFILE}
if [ "${Level_Number}" = "L6" -o "${Level_Number}" = "L10" ];then 
    # if [ "${Level_Number}" = "L6" ];then
    #     #        load_config_env "${Product_Name}-${Part_Number}" ${FWLIST}
    #     load_config_env "${Part_Number}" ${FWLIST}
    # elif [ "${Level_Number}" = "L10" ];then
    #     #        load_config_env "${Product_Name}-${Part_Number}" ${FWLIST}
    #     load_config_env "${Part_Number}" ${FWLIST}
    # fi
    # echo

    if [ ! -f $CFG/nvr.xml ];then
        red_message "Can not found the sequence ==> nvr.xml"
        exit 1
    fi

    #dos2unix $CFG/${Part_Number}-sequence.xml
    #if [ $? -ne 0 ];then
    #    red_message "Fail to dos2unix $CFG/${Part_Number}-sequence.xml"
    #    exit 1
    #fi
    echo
    #   . ${RCD}/runitem.sh
    # if [ "$runstatus" -eq 1 ];then
    ln -snf $CFG/nvr.xml $CFG/sequence.xml
    # else
    # ln -snf $CFG/${Part_Number}-BMC_share-sequence.xml $CFG/sequence.xml
    # fi

    if [ ! -f $CFG/nvr.xml ]; then
        red_message "There is not sequence for NVR"
        exit 1
    fi
    export UUTPN=${Part_Number}
elif [ "${Level_Number}" = "L12" ]; then
    [ -z "$Product_Name" ] && Product_Name=`dmidecode -t 1|awk '/Product Name/ {print $3}'`
    export Product_Name=$Product_Name
    load_config_env "${Product_Name}" ${FWLIST}
else
    red_message "Fail in getting product name!"
    exit 1
fi

show_platform_info
# shutdown_led
# clean_env
# load_test_driver
#bios_init
#bmc_init
# dmi_init

ini_file_init

#select_nic
#exit $err
