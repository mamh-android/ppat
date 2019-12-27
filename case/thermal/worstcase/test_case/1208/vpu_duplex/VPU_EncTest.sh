#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/vpu_duplex"
TST_APP=VPU_appCoda7542Enc_b_EM
STRM_PATH=/tmp
STRM_FILE="720p.yuv"
CONF_FILE="VPU_Coda7542EncConfig_d_EM.par"

ENC_IN_FILE=$STRM_PATH/$STRM_FILE
ENC_OUT_FILE=$STRM_PATH/enc_720p.h264
ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_EM.md5
ENC_LOG_FILE=$STRM_PATH/enc_720p.log
ENC_PAR_FILE=$STRM_PATH/$CONF_FILE


if [ "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE" ];then
	TST_APP=VPU_appCoda7542Enc_b_HL
	CONF_FILE="VPU_Coda7542EncConfig_d_HL.par"
	STRM_FILE="1080p_50f.yuv"
	ENC_OUT_FILE=$STRM_PATH/enc_1080p.h264
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_HL.md5
	ENC_LOG_FILE=$STRM_PATH/enc_1080p.log	


	ENC_IN_FILE=$STRM_PATH/$STRM_FILE
	ENC_PAR_FILE=$STRM_PATH/$CONF_FILE
fi


if [ "$ATD_HW_PF" = "HELAN_LTE" ];then
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_HL_LTE.md5
fi

if [ "$ATD_HW_PF" = "HELAN2" ];then
	TST_APP=VPU_appCoda7542Enc_b_HL2
	CONF_FILE="VPU_Coda7542EncConfig_d_HL.par"
	STRM_FILE="1080p_50f.yuv"
	ENC_OUT_FILE=$STRM_PATH/enc_1080p.h264
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_HL2.md5
	ENC_LOG_FILE=$STRM_PATH/enc_1080p.log	


	ENC_IN_FILE=$STRM_PATH/$STRM_FILE
	ENC_PAR_FILE=$STRM_PATH/$CONF_FILE
fi



if [ "$ATD_HW_PF" = "EDEN" ];then
    TST_APP=VPU_appHantroEnc_b_EDEN
    CONF_FILE="VPU_HantroEncConfig_d_EDEN.par"
    STRM_FILE="1080p_50f.yuv"
	ENC_OUT_FILE=$STRM_PATH/enc_1080p.h264
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_EDEN.md5
	ENC_LOG_FILE=$STRM_PATH/enc_1080p.log	

	if [ "$ATD_HW_PF" = "HELAN_LTE" ];then
		ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_HL_LTE.md5
	fi


	ENC_IN_FILE=$STRM_PATH/$STRM_FILE
	ENC_PAR_FILE=$STRM_PATH/$CONF_FILE
fi

if [ "$ATD_HW_PF" = "ULC1" ];then
	TST_APP=VPU_appCoda7542Enc_b_ULC1
	CONF_FILE="VPU_Coda7542EncConfig_d_HL.par"
	STRM_FILE="1080p_50f.yuv"
	ENC_OUT_FILE=$STRM_PATH/enc_1080p.h264
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_ULC1.md5
	ENC_LOG_FILE=$STRM_PATH/enc_1080p.log	


	ENC_IN_FILE=$STRM_PATH/$STRM_FILE
	ENC_PAR_FILE=$STRM_PATH/$CONF_FILE
fi

if [ "$ATD_HW_PF" = "HELAN3" ];then
	TST_APP=VPU_appCoda7542Enc_b_HELAN3
	CONF_FILE="VPU_Coda7542EncConfig_d_HL.par"
	STRM_FILE="1080p_50f.yuv"
	ENC_OUT_FILE=$STRM_PATH/enc_1080p.h264
	ENC_MD5_FILE=$TST_DIR/VPU_EncMD5_d_HELAN3.md5
	ENC_LOG_FILE=$STRM_PATH/enc_1080p.log	


	ENC_IN_FILE=$STRM_PATH/$STRM_FILE
	ENC_PAR_FILE=$STRM_PATH/$CONF_FILE
fi

[ $# -ne 2 ] && exit 1

[ ! -f $ENC_IN_FILE ] && cp $TST_DIR/$STRM_FILE $STRM_PATH/
[ ! -f $ENC_PAR_FILE ] && cp $TST_DIR/$CONF_FILE $STRM_PATH/

CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	[ -f $ENC_LOG_FILE ] && rm $ENC_LOG_FILE
	[ -f $ENC_OUT_FILE ] && rm $ENC_OUT_FILE
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  VPU encode test in loop $TST_LOOP time $CURR_DATE *************"
	# disable this routine since only "EDEN" has exception, and would be handled as below
    #if [ "$ATD_HW_PF" = "EMEI" -o "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE" -o "$ATD_HW_PF" = "HELAN2" ];then
        $TST_DIR/$TST_APP "-i:$ENC_IN_FILE -o:$ENC_OUT_FILE -l:$ENC_LOG_FILE -p:$ENC_PAR_FILE" > /dev/null &
    #fi
    if [ "$ATD_HW_PF" = "EDEN" ];then
        # close dynamic clock on/off
        $TST_DIR/$TST_APP "-i:$ENC_IN_FILE -o:$ENC_OUT_FILE -fmt:5 -color:0 -p:$ENC_PAR_FILE -dynaclk:0" > /dev/null &
    else 
	$TST_DIR/$TST_APP "-i:$ENC_IN_FILE -o:$ENC_OUT_FILE -l:$ENC_LOG_FILE -p:$ENC_PAR_FILE" > /dev/null &
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
		get_result "VPU_ENC" $CPUID
		exit 0
	fi
	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** FAIL *****] VPU encode case launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "VPU_ENC" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		
		#out log to console
		cat $ENC_LOG_FILE
		continue
	fi

  	# MD5 checksum
	md5_checksum $ENC_MD5_FILE $ENC_OUT_FILE "VPU encode test"
	if [ $? -ne 0 ];then
		dbg_dump_file "VPU_ENC" $ENC_OUT_FILE
		let "MD5_ERR=$MD5_ERR+1"
		reg_dump
		# out log to console
		cat $ENC_LOG_FILE
	fi

	# generate XML
	get_result "VPU_ENC" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "VPU_ENC" $CPUID
