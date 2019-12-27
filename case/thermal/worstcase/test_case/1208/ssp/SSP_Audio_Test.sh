#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/ssp"
TST_APP=1920_ssp_vmin.sh
TST_LOG=$TST_DIR/SSP_TEST_ON_CPU"$CPUID".log

[ $# -ne 2 ] && exit 1

check_result()
{
	echo "SSP test should pass"
}

CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  [CPU"$CPUID"] SSP Audio test in loop $TST_LOOP time $CURR_DATE *************" 
	# clear log file
	[ -f $TST_LOG ] && rm $TST_LOG

	$TST_DIR/$TST_APP > $TST_LOG 2>&1 &
	CPID=$!

	# bind test process to a specified core
	if [ $CPUID != "SCHD" ];then
		bind $CPID $CPUID
	fi

	# wait test process to finish
	wait $CPID
	EXIT_CODE=$?

	# if child process receive SIGKILL signal, 137 returned
	if [ $EXIT_CODE -eq 137 ];then
		get_result "SSP" $CPUID
		exit 0
	fi

	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] [CPU"$CPUID"] SSP Audio test launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "SSP" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		cat $TST_LOG
		continue
	fi
	
	# check CoreMark result
	check_result

	# generate XML
	get_result "SSP" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`

done

get_result "SSP" $CPUID
