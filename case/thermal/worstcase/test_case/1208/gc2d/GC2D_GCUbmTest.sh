#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2
TST_DIR="$TOP_DIR/gc2d"
TST_APP=GC2D_GCUbmTest_b_EM
TST_LOG="result_log/libGCU_Log.txt"
PERF_LOG="result_log/Perf_result.csv"


# Disable this if option since it is universal to all platform (except EMEI)
if [ "$ATD_HW_PF" = "ULC1" -o "$ATD_HW_PF" = "HELAN3" -o "$ATD_HW_PF" = "EDEN" ];then
	mkdir $TST_DIR/result_log >/dev/null 2>&1

	SURFACE_DIR=/data/gc2d001/
	TST_APP=GC2D_GCUbmTest_b_ULC1

	mkdir $SURFACE_DIR >/dev/null 2>&1
	rm -fr $SURFACE_DIR/*

fi

[ $# -ne 2 ] && exit 1

check_fps()
{
	local FPS=`cat $TST_DIR/$PERF_LOG | $BUSYBOX grep "UYVY=>ARGB8888(1080P=>720P)" | $BUSYBOX sed -n '$p' | $BUSYBOX awk '{print $8}'`
	if [ -n "$FPS" ];then
		get_min_max_fps $FPS
		FPS_DATA="$FPS $FPS_DATA"
		return 0
	else
		echo "[****** GC3D FAIL ******] could not get FPS data !"
		let "LOG_ERR=$LOG_ERR+1"
		reg_dump
		return 1
	fi
}

_md5sum()
{
	file=$1
	MD5=`md5sum $file | cut -d " " -f 1`
	echo $MD5
}

check_result()
{
	# Disable this if option since it is universal to all platform
	#if [ "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE" -o "$ATD_HW_PF" = "HELAN2" ];then
		#md5sum check
		GC2D_MD5SUM=$TST_DIR/"GC2D_MD5SUM_d_HL.par"

		if [ "$ATD_HW_PF" = "HELAN_LTE" ];then
			GC2D_MD5SUM=$TST_DIR/"GC2D_MD5SUM_d_HL_LTE.par"
		else
			GC2D_MD5SUM=$TST_DIR/"GC2D_MD5SUM_d_$ATD_HW_PF.par"
		fi


		MD5=`_md5sum $GC2D_MD5SUM`


		for sur in `ls $SURFACE_DIR`
		do
			M1=`_md5sum $SURFACE_DIR/$sur`
			echo "$M1 $sur" >> GC2D_MD5SUM_d_HELAN3_raw.par
			M2=`cat $GC2D_MD5SUM | grep $sur | cut -d ' ' -f 1`
			if [ "$M1" != "$M2" ];then
				echo "GC2D surface<$sur>  md5 check error"
				echo "expected  $M2, but got $M1"

				let MD5_ERR=$MD5_ERR+1
			fi

		done

		return 


	#fi ##for HELAN only

	local err=`$BUSYBOX tail $TST_DIR/$TST_LOG | $BUSYBOX grep "End the libGCU_Performance Test!"`
	if [ -z "$err" ];then
		let "LOG_ERR=$LOG_ERR+1"
		reg_dump
	fi
}

CURR_DATE=`date +%s`
PRE_DATE=$CURR_DATE
let "END_DATE=$CURR_DATE+$TST_SEC"
while [ $CURR_DATE -lt $END_DATE ]
do
	let "TST_LOOP=$TST_LOOP+1"
	echo "***********  GC2D test in loop $TST_LOOP time $CURR_DATE *************" 
	[ -f $TST_DIR/$TST_LOG ] && rm $TST_DIR/$TST_LOG
	[ -f $TST_DIR/$PERF_LOG ] && rm $TST_DIR/$PERF_LOG
	
	# Disable this if option since it is universal to all platform
	#if [ "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN_LTE" -o "$ATD_HW_PF" = "HELAN2" -o "$ATD_HW_PF" = "EDEN" ];then
		rm -fr $SURFACE_DIR/*
	#fi

	$TST_DIR/$TST_APP > $TST_LOG &
	
	#Use GC2D cases to replace GCU benchmark
	#$TST_DIR/gal2d_s_single ./ 0 /data/test.log TC_GAL2D_06 36000000 /dev/graphics/fb0 720 1280 1 2 200000 100 1 0 > $TST_LOG &

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
		get_result "GC2D" $CPUID
		exit 0
	fi
	if [ $EXIT_CODE -ne 0 ];then
		echo "[***** LOOP: $TST_LOOP *****] GC 2D test launched failed"
		let "RT_ERR=$RT_ERR+1"
		reg_dump
		# generate XML
		get_result "GC2D" $CPUID
		# refresh current time
		CURR_DATE=`date +%s`
		continue
	fi

	# check result
	check_result

	# check fps result
	check_fps

	# generate XML
	get_result "GC2D" $CPUID

	# refresh current time
	CURR_DATE=`date +%s`
done

get_result "GC2D" $CPUID
