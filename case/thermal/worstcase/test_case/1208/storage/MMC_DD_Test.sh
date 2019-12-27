#!/data/bin/busybox sh

. ../wcc_util.sh

TST_DIR1=$1
TST_DIR2=$2
TST_DUR=$3
CPUID=$4
TST_FILE="file.dat"
MAX_CN=262144
DD_RST="/tmp/.dd_test_result"
LOOP_PATTEN="TST_LOOP_RST"
BUSYBOX=/data/bin/busybox
TST_RST=0

dd_test()
{
	local TST_DIR=$1
	local TST_TIME=$2
	local TST_PID=$3

	[ $# -ne 3 ] && return 1

	local CN=1
	local LOOP=1
	local LOOP_LOG=/tmp/"$TST_PID"_"$LOOP_PATTEN"
	local CUR_T=`date +%s`
	local END_T=$(($CUR_T+$TST_TIME))
	while [ $CUR_T -lt $END_T ]
	do
		while [ $CN -le $MAX_CN ]
		do
			echo " [dd Test in loop $LOOP ] Generating file: $TST_DIR/$TST_FILE size: $(($CN*512)) Bytes"
			echo $LOOP > $LOOP_LOG
			$BUSYBOX time dd if=/dev/urandom of=$TST_DIR/$TST_FILE bs=512 count=$CN
			if [ $? -ne 0 ];then
				echo "**** FAIL **** [loop: $LOOP] dd file size: $(($CN*512)) Bytes"
				echo "FAIL" >> $DD_RST
				TST_RST=1
			fi
			sync
			rm $TST_DIR/$TST_FILE
			sync
			sleep 2
			CN=$(($CN*2))
			LOOP=$(($LOOP+1))
		done
		CUR_T=`date +%s`
	done
}

check_result()
{
	local index=0
	local CURR_DATE=`date +%s`
	let "END_DATE=$CURR_DATE+$TST_DUR"
	while [ $CURR_DATE -lt $END_DATE ]
	do
		DD_FAIL=`cat $DD_RST | $BUSYBOX grep "FAIL"`
		if [ -n $DD_FAIL ];then
			RT_ERR=`echo $DD_FAIL | $BUSYBOX awk '{print NF}'`
		fi

		local index=0
		local TOTAL_LOOP=0
		while [ "$index" -lt 2 ]
		do
			LOOP_RST=`cat /tmp/"$index"_"$LOOP_PATTEN"`
			TOTAL_LOOP=$(($TOTAL_LOOP+$LOOP_RST))
			index=$(($index+1))
		done
		TST_LOOP=$TOTAL_LOOP

		# generate XML result file
		get_result "MMC" $CPUID
		sleep 10
		CURR_DATE=`date +%s`
	done
}

[ $# -ne 4 ] && exit 1
# clean up
rm -r $DD_RST > /dev/null 2>&1
rm -r /tmp/*_$LOOP_PATTEN > /dev/null 2>&1
touch $DD_RST

dd_test $TST_DIR1 $TST_DUR 0 &
# bind test process to a specified core
CPID=$!
if [ $CPUID != "SCHD" ];then
bind $CPID $CPUID
fi
dd_test $TST_DIR2 $TST_DUR 1 &
# bind test process to a specified core
CPID=$!
if [ $CPUID != "SCHD" ];then
bind $CPID $CPUID
fi
check_result
wait
exit $TST_RST
