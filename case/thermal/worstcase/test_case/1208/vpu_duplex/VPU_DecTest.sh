#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/vpu_duplex"
TST_APP=VPU_appCoda7542Dec_b_EM
STRM_PATH=/tmp
STRM_FILE="1080p.h264"

DEC_IN_FILE=$STRM_PATH/$STRM_FILE
DEC_OUT_FILE=$STRM_PATH/dec_1080p.yuv
DEC_LOG_FILE=$STRM_PATH/dec_1080p.log
DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_EM.md5


if [ "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE"  ];then
	TST_APP=VPU_appCoda7542Dec_b_HL
	DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_HL.md5
fi

if [ "$ATD_HW_PF" = "HELAN_LTE" ];then
	DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_HL_LTE.md5
fi

if [ "$ATD_HW_PF" = "HELAN2" ];then
	TST_APP=VPU_appCoda7542Dec_b_HL2
	DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_HL2.md5
fi


if [ "$ATD_HW_PF" = "EDEN" ];then
    TST_APP=VPU_appHantroDec_b_EDEN
    DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_EDEN.md5
fi

if [ "$ATD_HW_PF" = "ULC1" ];then
	TST_APP=VPU_appCoda7542Dec_b_ULC1
    DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_ULC1.md5
fi

if [ "$ATD_HW_PF" = "HELAN3" ];then
	TST_APP=VPU_appCoda7542Dec_b_HELAN3
    DEC_MD5_FILE=$TST_DIR/VPU_DecMD5_d_HELAN3.md5
fi


[ $# -ne 2 ] && exit 1

[ ! -f $DEC_IN_FILE ] && cp $TST_DIR/$STRM_FILE $STRM_PATH/

CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	[ -f $DEC_LOG_FILE ] && rm $DEC_LOG_FILE
	[ -f $DEC_OUT_FILE ] && rm $DEC_OUT_FILE
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  VPU decode test in loop $TST_LOOP time $CURR_DATE *************"
    
	# disable this routine since only "EDEN" has exception, and would be handled as below
	#if [ "$ATD_HW_PF" = "EMEI" -o "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE" -o "$ATD_HW_PF" = "HELAN2" ];then
      #  $TST_DIR/$TST_APP "-fmt:5 -i:$DEC_IN_FILE -o:$DEC_OUT_FILE -polling:0 -fileplay:1 -l:$DEC_LOG_FILE " > /dev/null &
    #fi

    if [ "$ATD_HW_PF" = "EDEN" ];then
        # close dynamic clock on/off
        $TST_DIR/$TST_APP "-i:$DEC_IN_FILE -o:$DEC_OUT_FILE -fmt:5 -dynaclk:0" > /dev/null &
else 
	$TST_DIR/$TST_APP "-fmt:5 -i:$DEC_IN_FILE -o:$DEC_OUT_FILE -polling:0 -fileplay:1 -l:$DEC_LOG_FILE " > /dev/null &    
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
		get_result "VPU_DEC" $CPUID
		exit 0
	fi

	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] VPU decode case launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "VPU_DEC" $CPUID
		# out log to console
		cat $DEC_LOG_FILE
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi

	# MD5 checksum
	md5_checksum $DEC_MD5_FILE $DEC_OUT_FILE "VPU decode test"
	if [ $? -ne 0 ];then
		dbg_dump_file "VPU_DEC" $DEC_OUT_FILE
		let "MD5_ERR=$MD5_ERR+1"
		reg_dump
		#out log to console
		cat $DEC_LOG_FILE
	fi

	# generate XML
	get_result "VPU_DEC" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "VPU_DEC" $CPUID
