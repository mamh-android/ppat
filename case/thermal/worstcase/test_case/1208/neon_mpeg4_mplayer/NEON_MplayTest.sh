#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/neon_mpeg4_mplayer"
TST_APP=NEON_MplayerSoftVFP_b_EM
TST_LOG=$TST_DIR/NEON_TEST_on_CPU"$CPUID".log
STRM_PATH=/tmp
STRM_FILE="Avatar_Blu-ray__DVD_Spot_640_360.mp4"

INPUT_F=$STRM_PATH/$STRM_FILE

MD5_DST=$TST_DIR/md5sums
MD5_SRC=$TST_DIR/NEON_md5sums_d_EM.md5

[ $# -ne 2 ] && exit 1

[ ! -f $INPUT_F ] && cp $TST_DIR/$STRM_FILE $STRM_PATH/


mkdir $TST_DIR/$CPUID/
cp $TST_APP $TST_DIR/$CPUID/

MD5_DST=$TST_DIR/$CPUID/md5sums

CURR_DATE=`date +%s`
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	[ -f $TST_LOG ] && rm $TST_LOG
	[ -f $MD5_DST ] && rm $MD5_DST
	let "TST_LOOP=$TST_LOOP+1"
	echo "*********** [CPU"$CPUID"] NEON H264 decode test in loop $TST_LOOP time $CURR_DATE *************" 
	#$TST_DIR/$TST_APP -vo md5sum -vc ffh264 -nosound $INPUT_F > $TST_LOG 2>&1 &
	cd $TST_DIR/$CPUID/ && ./$TST_APP -vo md5sum -vc ffh264 -nosound $INPUT_F > $TST_LOG 2>&1 &

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
		get_result "NEON_$CPUID" $CPUID
		exit 0
	fi
	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] [CPU"$CPUID"] NEON H264 decoding case launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "NEON_$CPUID" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi
	
	# MD5 checksum
	md5sums_check2 $MD5_SRC $MD5_DST
	if [ $? -ne 0 ];then
		let "MD5_ERR=$MD5_ERR+1"
		reg_dump
	fi

	# generate XML
	get_result "NEON_$CPUID" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "NEON_$CPUID" $CPUID
