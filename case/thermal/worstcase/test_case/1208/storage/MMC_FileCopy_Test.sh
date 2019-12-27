#!/data/bin/busybox sh

. ../wcc_util.sh

# Usage
usage()
{
	echo "Usage: [EXTRA_TEST_PARAMETER]"
	echo "	01: src file system directory"
	echo "	02: dst file system directory"
	echo "	03: Duration (seconds)"
	echo "	04: process number"
	echo "	05: CPU ID to bind process with"
	echo ""
}

TEST_RESULT=0

############################################################
SRC_DIR=$1
DST_DIR=$2
DURATION=$3
PROCESS_NUM=$4
CPUID=$5
BUSYBOX="/data/bin/busybox"
############################################################

#==========================================================
# function 0: test setups
#==========================================================
MD5_RST="/tmp/.md5_result"
RT_RST="/tmp/.rt_result"
LOOP_PATTEN="LOOP_RSTFILE"
tst_setup()
{
	rm /tmp/*_$LOOP_PATTEN >/dev/null 2>&1
	rm $MD5_RST >/dev/null 2>&1
	rm $RT_RST >/dev/null 2>&1
	touch $MD5_RST
	touch $RT_RST
}

#==========================================================
# function 1: generate test data
#==========================================================
gen_files()
{
	local DIR=$1
	local NUM=$2
	local CNT=1
	local index=0

	[ $# -ne 2 ] && return 1

	while [ $index -lt $NUM ]
	do
		dd if=/dev/urandom of="$DIR"/"in.file.$index" bs=1024 count=$CNT >/dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "[FAIL]: generate data $DIR/in.file.$index"
			RT_ERR=$(($RT_ERR+1))
			return 1
		fi
		sync
		CNT=$(($CNT*2))
		index=$(($index+1))
	done
	return 0
}

#==========================================================
# function 2: file copy with MD5 checksum
#==========================================================
fcp_md5()
{
	local SRC_FILE=$1
	local DST_FILE=$2
	local INT_FILE=$SRC_FILE.back
	local RT_VAL=0
	[ $# -ne 2 ] && return 1

	SRC_MD5=`$BUSYBOX md5sum $SRC_FILE | $BUSYBOX awk '{print $1}'`
	cp $SRC_FILE $DST_FILE
	if [ $? -ne 0 ];then
		echo "[FAIL]: Copy $SRC_FILE to $DST_FILE"
		echo "FAIL" >> $RT_RST
		return 1
	fi
	sync
	DST_MD5=`$BUSYBOX md5sum $DST_FILE | $BUSYBOX awk '{print $1}'`

	cp $DST_FILE $INT_FILE
	if [ $? -ne 0 ];then
		echo "[FAIL]: Copy $DST_FILE to $INT_FILE"
		echo "FAIL" >> $RT_RST
		return 1
	fi
	sync
	INT_MD5=`$BUSYBOX md5sum $INT_FILE | $BUSYBOX awk '{print $1}'`

	if [ "$DST_MD5" = "$SRC_MD5" -a "$INT_MD5" = "$SRC_MD5" ];then
		echo " [**** PASS ****] File copy $SRC_FILE MD5 checksum verified OK !"
	else
		echo "[**** FAIL ****] File copy MD5 checksum verified failed !"
		echo "SRC_MD5: $SRC_MD5, DST_MD5: $DST_MD5, INT_MD5: $INT_MD5"
		echo "FAIL" >> $MD5_RST
		RT_VAL=1
	fi

	# clean up internal files
	rm $INT_FILE > /dev/null 2>&1
	sync

	return $RT_VAL
}

#==========================================================
# function 3: file copy process
#==========================================================
fcp_process()
{
	local ECP_SRC=$1
	local ECP_DES=$2
	local ECP_DURATION=$3

	[ $# -ne 3 ] && return 1

	local RT_VAL=0
	local LOOP=1
	local P_NUM=`echo $ECP_SRC | $BUSYBOX awk -F "." '{print $3}'`
	local L_FILE=/tmp/"$P_NUM"_"$LOOP_PATTEN"
	local ECP_CURR=`date +%s`
	local ECP_END=$(($ECP_CURR+$ECP_DURATION))
	
	while [ "$ECP_CURR" -lt "$ECP_END" ]
	do
		echo "****** Multi-process file copy in loop $LOOP, TIME: $ECP_CURR"
		# record test loops for each process
		echo $LOOP > $L_FILE
		fcp_md5 $ECP_SRC $ECP_DES
		[ $? -ne 0 ] && RT_VAL=1

		# clean up
		rm $ECP_DES >/dev/null 2>&1
		sync

		LOOP=$(($LOOP+1))
		ECP_CURR=`date +%s`
	done

	return $RT_VAL
}

#==========================================================
# function 4: random sync
#==========================================================
rnd_sync()
{
	local TST_DURATION=$1
	local CURR_DATE=`date +%s`
	let "END_DATE=$CURR_DATE+$TST_DURATION"
	while [ $CURR_DATE -lt $END_DATE ]
	do

		RND=$RANDOM
		let "r=$RND%8"
		sleep $r

		if [ $r -eq "4" ] || [ $r -eq "2" ] || [ $r -eq "6" ]
		then
			echo "Sync.., $r"
			sync 
		fi
		CURR_DATE=`date +%s`
	done
}

#==========================================================
# function 5: check test result and generate XML every 10s
#==========================================================
check_result()
{
	local CURR_DATE=`date +%s`
	let "END_DATE=$CURR_DATE+$DURATION"
	while [ $CURR_DATE -lt $END_DATE ]
	do
		RT_FAIL=`cat $RT_RST | $BUSYBOX grep "FAIL"`
		MD5_FAIL=`cat $MD5_RST | $BUSYBOX grep "FAIL"`
		if [ -n $RT_FAIL ];then
			RT_ERR=`echo $RT_FAIL | $BUSYBOX awk '{print NF}'`
		fi
		if [ -n $MD5_FAIL ];then
			MD5_ERR=`echo $MD5_FAIL | $BUSYBOX awk '{print NF}'`
		fi

		local index=0
		local TOTAL_LOOP=0
		while [ "$index" -lt $PROCESS_NUM ]
		do
			LOOP_RST=`cat /tmp/"$index"_"$LOOP_PATTEN"`
			TOTAL_LOOP=$(($TOTAL_LOOP+$LOOP_RST))
			index=$(($index+1))
		done
		TST_LOOP=$TOTAL_LOOP

		# generate XML result file
		get_result "MMC" $CPUID
		sleep 5
		CURR_DATE=`date +%s`
	done
}

############################################################
# Main : Start multi-process file copy test
############################################################
tst_setup
gen_files $SRC_DIR $PROCESS_NUM

temp=0
ECP_PID=""
while [ "$temp" -lt $PROCESS_NUM ]
do
	(fcp_process $SRC_DIR/in.file.$temp $DST_DIR/out.file.$temp $DURATION) &

	# bind test process to a specified core
	CPID=$!
	if [ $CPUID != "SCHD" ];then
		bind $CPID $CPUID
	fi

	[ $? -ne 0 ] && TEST_RESULT=1
	ECP_PID="$CPID $ECP_PID"
	let temp=$temp+1
done

############################################################
#(rnd_sync $DURATION)&
############################################################
check_result
wait $ECP_PID
############################################################
# Exit
exit $TEST_RESULT
