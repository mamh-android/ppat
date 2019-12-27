#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/ddr"
TST_APP="DDR_Memtest_b_EM"

#if [ $ATD_HW_PF = HELAN3 ]; then
	TST_APP="DDR_Memtest_b_HELAN3"
#fi

TST_LOG=$TST_DIR/DDR_Memtest_on_CPU"$CPUID".log

[ $# -ne 2 ] && exit 1

CURR_DATE=`date +%s`
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	[ -f $TST_LOG ] && rm $TST_LOG
	let "TST_LOOP=$TST_LOOP+1"
	echo "*********** [CPU"$CPUID"] DDR Memtest in loop $TST_LOOP time $CURR_DATE *************" 
	$TST_DIR/$TST_APP memcpy stress 8 10 > $TST_LOG 2>&1 &

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
		get_result "DDR_$CPUID" $CPUID
		exit 0
	fi

	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] [CPU"$CPUID"] DDR MemTest case failed"
		let "MD5_ERR=$MD5_ERR+1"
		reg_dump
		# generate XML
		get_result "DDR_$CPUID" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi

	# generate XML
	get_result "DDR_$CPUID" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "DDR_$CPUID" $CPUID
