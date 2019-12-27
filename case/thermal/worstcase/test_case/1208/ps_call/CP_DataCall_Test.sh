#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/ps_call"
TST_LOG=$TST_DIR/ps_call.log
TST_APP=CP_WGET_b_EM
PS_DOWN_FILE="/tmp/l.gif"
PS_URL="http://61.135.169.125/img/baidu_sylogo1.gif"
PS_DOWN_FILE_MD5="$TST_DIR/CP_DataCall_MD5_d_EM.md5"

[ $# -ne 2 ] && exit 1
[ -f $TST_LOG ] && rm $TST_LOG

# This is a weak pass criteria, initially this flag is marked to 1, and if test pass rate larger than PASS_CRITERIA,
# MD5_ERR is set to 0 as final test result
MD5_ERR=1
# To count failure times.
CASE_FAIL=0
# This PASS criteria means data call fail rate criteria, which should be tuned according to actual test condition.
# If fail rate larger than this PASS_CRITERIA, final test result of CP data call is FAIL. Otherwise, result is PASS.
# For CP data call by wget, we need to strengthen the pass criteria to avoid some cases when under low/critical boundary
# Vmin, CP data call may pass 1~2 times among 300~500 retries. This should be marked as failure in Vmin shmoo result.
PASS_CRITERIA=0.90

CURR_DATE=`date +%s`
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  PS call test in loop $TST_LOOP time $CURR_DATE: Fail[$CASE_FAIL/$TST_LOOP] *************" 
	
	rm -fr $PS_DOWN_FILE >/dev/null 2>&1 

	$TST_DIR/$TST_APP --timeout=10 -t 1 $PS_URL -O $PS_DOWN_FILE > $TST_LOG 2>&1 &

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
		get_result "ps_call" $CPUID
		exit 0
	fi
	if [ $EXIT_CODE -ne 0 ];then
		case $EXIT_CODE in
			8)
			echo "[***** WARNING: PS call(wget) Web Server issued an error response  ******]"
			;;
			7)
			echo "[***** WARNING: PS call(wget) network protocol errors  ******]"
			;;
			4)
			echo "[***** WARNING: PS call(wget) Network connection failure ******]"
			;;
			3)
			echo "[***** WARNING: PS call(wget) Download to file I/O failure ******]"
			;;
			*)
			echo "[***** WARNING: PS call(wget) connection timeout ******]"
			;;
		esac
		let "CASE_FAIL=$CASE_FAIL+1"
		# generate XML
		get_result "ps_call" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi

	# MD5 checksum
	if [ -f $PS_DOWN_FILE ];then ##weaker criteria for pass
		md5_checksum "$PS_DOWN_FILE_MD5" "$PS_DOWN_FILE" "ps_call_download"
		if [ $? -ne 0 ];then
			let "CASE_FAIL=$CASE_FAIL+1"
			echo "[***** <FAIL> PS down file MD5 check error ($CASE_FAIL/$TST_LOOP) ******]"
			reg_dump
		else
			fail_rate=`echo "$CASE_FAIL $TST_LOOP" | awk '{printf("%.2f",$1/$2)}'`
			echo "[****** PS call fail rate: $fail_rate ********]"
			pass=`echo "$fail_rate $PASS_CRITERIA" | awk '{printf("%d", $1 >= $2 ? 0 : 1)}'`
			[ $pass -eq 1 ] && MD5_ERR=0
		fi
	fi

	# generate XML
	get_result "ps_call" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "ps_call" $CPUID

