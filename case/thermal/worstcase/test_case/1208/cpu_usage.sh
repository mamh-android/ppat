#!/data/bin/busybox sh

PREV_TOTAL=0
PREV_IDLE=0
PREV_TOTAL_0=0
PREV_TOTAL_1=0
PREV_IDLE_0=0
PREV_IDLE_1=0
CPU_LOGFILE=/data/cpu_usage.log
CPU0_LOGFILE=/data/cpu0_usage.log
CPU1_LOGFILE=/data/cpu1_usage.log
[ -f $CPU_LOGFILE ] && rm -r $CPU_LOGFILE
[ -f $CPU0_LOGFILE ] && rm -r $CPU0_LOGFILE
[ -f $CPU1_LOGFILE ] && rm -r $CPU1_LOGFILE

[ $# -ne 1 ] && exit 1
TST_TIME=$1

cpu_stat()
{
local CURR_DATE=`date +%s`
local END_DATE=0
let "END_DATE=$CURR_DATE+$1"
while [ $CURR_DATE -lt $END_DATE ];do
	CPU=`cat /proc/stat | grep '^cpu ' | cut -d " " -f 2-`
	CUR_TOTAL=`echo $CPU | awk '{print $1+$2+$3+$4}'`
	CUR_IDLE=`echo $CPU | awk '{print $4}'`
	
	#calculate cpu usage since last check
	DIFF_TOTAL=$(($CUR_TOTAL-$PREV_TOTAL))
	DIFF_IDLE=$(($CUR_IDLE-$PREV_IDLE))
	CPU_USAGE=$((100*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL))
	#log to file
	echo $CPU_USAGE >> $CPU_LOGFILE
	echo -en "\rCPU: $CPU_USAGE%	\b\b"

	PREV_TOTAL=$CUR_TOTAL
	PREV_IDLE=$CUR_IDLE

	# interleave 1s to calculate cpu usage
	sleep 1
	CURR_DATE=`date +%s`
done
}

cpu0_cpu1_stat()
{
local CURR_DATE=`date +%s`
local END_DATE=0
let "END_DATE=$CURR_DATE+$1"
while [ $CURR_DATE -lt $END_DATE ];do
	CPU0=`cat /proc/stat | grep '^cpu0' | cut -d " " -f 2-`
	CPU1=`cat /proc/stat | grep '^cpu1' | cut -d " " -f 2-`
	CUR_TOTAL_0=`echo $CPU0 | awk '{print $1+$2+$3+$4}'`
	CUR_TOTAL_1=`echo $CPU1 | awk '{print $1+$2+$3+$4}'`
	CUR_IDLE_0=`echo $CPU0 | awk '{print $4}'`
	CUR_IDLE_1=`echo $CPU1 | awk '{print $4}'`
	
	#calculate cpu usage since last check
	DIFF_TOTAL_0=$(($CUR_TOTAL_0-$PREV_TOTAL_0))
	DIFF_TOTAL_1=$(($CUR_TOTAL_1-$PREV_TOTAL_1))
	DIFF_IDLE_0=$(($CUR_IDLE_0-$PREV_IDLE_0))
	DIFF_IDLE_1=$(($CUR_IDLE_1-$PREV_IDLE_1))
	CPU0_USAGE=$((100*($DIFF_TOTAL_0-$DIFF_IDLE_0)/$DIFF_TOTAL_0))
	CPU1_USAGE=$((100*($DIFF_TOTAL_1-$DIFF_IDLE_1)/$DIFF_TOTAL_1))

	#log to file
	echo $CPU0_USAGE >> $CPU0_LOGFILE
	echo $CPU1_USAGE >> $CPU1_LOGFILE
	echo -en "\rCPU0: $CPU0_USAGE%\t CPU1: $CPU1_USAGE% \b\b"

	PREV_TOTAL_0=$CUR_TOTAL_0
	PREV_TOTAL_1=$CUR_TOTAL_1
	PREV_IDLE_0=$CUR_IDLE_0
	PREV_IDLE_1=$CUR_IDLE_1

	# interleave 1s to calculate cpu usage
	sleep 1
	CURR_DATE=`date +%s`
done
}

CPU_NUM=`cat /proc/stat | grep '^cpu' | wc -l`
case $CPU_NUM in
	2)
	cpu_stat $TST_TIME
	;;
	3)
	cpu0_cpu1_stat $TST_TIME
	;;
	*) ;;
esac
