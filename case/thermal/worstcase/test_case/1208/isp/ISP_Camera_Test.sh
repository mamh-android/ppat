#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/isp"

if [ $ATD_HW_PF = HELAN3 ]; then
	TST_APP=ISP_B52_HOME_MADE_b_HELAN3
else
	#TST_APP=ISP_B52_b_HL2
	TST_APP=ISP_B52_b_ULC1
fi

TST_LOG=$TST_DIR/ISP_TEST_ON_CPU"$CPUID".log

[ $# -ne 2 ] && exit 1

check_result()
{
    echo "check result"
}

CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  [CPU"$CPUID"] ISP test in loop $TST_LOOP time $CURR_DATE *************" 
	# clear log file
	[ -f $TST_LOG ] && rm $TST_LOG

	if [ $ATD_HW_PF = HELAN3 ]; then
		$TST_DIR/$TST_APP 1 1 1 1 1 &
	else
		#$TST_DIR/$TST_APP -s 3 0 > $TST_LOG 2>&1 &
		$TST_DIR/$TST_APP -s 0 0 > $TST_LOG 2>&1 &
	fi
	# bind test process to a specified core
	CPID=$!
	if [ $CPUID != "SCHD" ];then
		bind $CPID $CPUID
	fi

	# wait test process to finish
	wait $CPID
        EXIT_CODE=$?

	# if child process receive SIGKILL signal, 137 returned
	if [ $EXIT_CODE -eq 137 ];then
		get_result "ISP_$CPUID" $CPUID
		exit 0
	fi
	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] [CPU"$CPUID"] ISP test launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "ISP" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi

	# check ISP result
	check_result

	# generate XML
	get_result "ISP_$CPUID" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`

done

get_result "ISP_$CPUID" $CPUID
