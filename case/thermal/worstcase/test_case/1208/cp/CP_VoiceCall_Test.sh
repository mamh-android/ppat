#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/cp"
TST_LOG=$TST_DIR/cp.log
TST_APP=$TST_DIR/tel_at_client

[ $# -ne 2 ] && exit 1
[ -f $TST_LOG ] && rm $TST_LOG

CASE_FAIL=0
RT_ERR=1

CURR_DATE=`date +%s`
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "********  CP voice call test in loop $TST_LOOP time $CURR_DATE: Fail[$CASE_FAIL] **********" 

	# 10 seconds 10086 call
	$TST_APP 1 10086 10 >> $TST_LOG 2>&1 &

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
		get_result "CP" $CPUID
		exit 0
	fi

	if [ $EXIT_CODE -ne 0 ];then
        	let "CASE_FAIL=$CASE_FAIL+1"
        	echo "[***** FAIL ($CASE_FAIL/$TST_LOOP)*****] CP voice call test launched failed"
	else
        	# once pass, let RT_ERR as 0
        	RT_ERR=0
	fi

	# generate XML
	get_result "CP" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "CP" $CPUID
