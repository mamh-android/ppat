#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/gps"
TST_APP=
TST_LOG=$TST_DIR/GPS_CM3"$CPUID".log
TST_FW=GPS_Firmware_b_HL2.bin 

if [ $ATD_HW_PF -eq ULC1 ]; then
	TST_FW=GPS_Firmware_b_ULC1.bin 
fi

[ $# -ne 2 ] && exit 1

cm3_mod_prepare()
{
	lsmod | grep "msocketk"
	if [ $? -ne 0 ];then
		insmod /lib/modules/msocketk.ko
	fi	

	lsmod | grep m3rmdev
	if [ $? -ne 0 ];then
		insmod $TOP_DIR/gps/m3rmdev.ko
	fi

	lsmod | grep hwmap
	if [ $? -ne 0 ];then
		insmod /lib/modules/hwmap.ko
	fi
}

cm3_poweroff()
{
	$TST_DIR/GPS_Firmware_Loader_b_HL2  -s 0  -t
	echo "GPS CM3 has been powered off!"
}

cm3_release()
{
	$TST_DIR/GPS_Firmware_Loader_b_HL2  -s 0 -i -f $TST_DIR/$TST_FW 
}

__PINGS=0
cm3_status()
{
	#ping
	$TST_DIR/GPS_AMIPC_b_HL2 1
	_ping_id0=`cat /sys/kernel/debug/amipc/packetstat | grep total | awk '{print $9}'`
	#ping again
	$TST_DIR/GPS_AMIPC_b_HL2 1 
	_ping_id1=`cat /sys/kernel/debug/amipc/packetstat | grep total | awk '{print $9}'`

	let __PINGS=$__PINGS+2

	if [ $_ping_id0 -eq $_ping_id1 ];then
		#echo "GPS CM3 hang found, no AMIPC response, $_ping_id0, $_ping_id1, total ping($__PINGS)"
		cat /sys/kernel/debug/amipc/sharemem
		cat /sys/kernel/debug/amipc/packetstat
		RT_ERR=0
		#let "RT_ERR=$RT_ERR+1"
	else
		echo "GPS CM3 status is OK ($_ping_id0,$_ping_id1)!"	
	fi
	
}

check_result()
{
    cm3_status
}


# clear log file
[ -f $TST_LOG ] && rm $TST_LOG
cm3_mod_prepare
cm3_poweroff
cm3_release >$TST_LOG &
# bind test process to a specified core
CPID=$!
if [ $CPUID != "SCHD" ];then
	bind $CPID $CPUID
fi
echo "GPS CM3 stress launched, loader pid:$CPID"


CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  [CPU"$CPUID"] GPS test in loop $TST_LOOP time $CURR_DATE *************" 

#	# wait test process to finish
#	wait $CPID
#        EXIT_CODE=$?
#
#	# if child process receive SIGKILL signal, 137 returned
#	if [ $EXIT_CODE -eq 137 ];then
#		get_result "GPS_$CPUID" $CPUID
#		exit 0
#	fi
#	if [ $EXIT_CODE -ne 0 ];then
#		echo "[***** FAIL *****] [CPU"$CPUID"] GPS test launched failed"
#		let "RT_ERR=$RT_ERR+1"
#		reg_dump
#		# generate XML
#		get_result "GPS_$CPUID" $CPUID
#		# refresh current time
#		CURR_DATE=`date +%s`
#		continue
#	fi
	
	sleep 5 # every 5 seconds, check the CM3 results

	# check GPS result
	check_result
		
	# generate XML
	get_result "GPS_$CPUID" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`

done

get_result "GPS_$CPUID" $CPUID
