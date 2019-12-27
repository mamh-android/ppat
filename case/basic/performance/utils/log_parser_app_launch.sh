#! /bin/bash
TARGET_LOG=$1
RESULT_FILE=$2
TESTAPP=$3
INFO=()
PROC_NUM=0
TOUCH_TIME=0
PREVIOUS_FRAME_TIME=0
RESULT_COUNT=0
RESPONSE=0
LINE=""

function time_to_msec(){
	TARGET_TIME=$1
	TARGET_HOUR=`echo $TARGET_TIME | awk -F ":" '{print $1}'`
	TARGET_MINUTE=`echo $TARGET_TIME | awk -F ":" '{print $2}'`
	TARGET_SEC=`echo $TARGET_TIME | awk -F ":" '{print $3}' | awk -F "." '{print $1}'`
	TARGET_MSEC=`echo $TARGET_TIME | awk -F ":" '{print $3}' | awk -F "." '{print $2}'`
	
	TARGET_RESULT=`expr $TARGET_HOUR \* 3600 \* 1000 + $TARGET_MINUTE \* 60 \* 1000 + $TARGET_SEC \* 1000 + $TARGET_MSEC`
	echo $TARGET_RESULT
}

function is_on_the_minute(){
	TARGET_TIME=$1
	TARGET_SEC=`echo $TARGET_TIME | awk -F ":" '{print $3}' | awk -F "." '{print $1}'`
	TARGET_MSEC=`echo $TARGET_TIME | awk -F ":" '{print $3}' | awk -F "." '{print $2}'`
	
	if [ $TARGET_SEC -eq 0 -a $TARGET_MSEC -le 100 ]
	then
		echo 1;
	else
		echo 0
	fi
}

function pre_parse(){
	cat $TARGET_LOG | grep -E '(UIAT|libEGL|Displayed)' > temp.txt
}

function parse_touch_log(){
	CURRENT_TIME=`echo $LINE | awk -F " " '{print $2}'`
	CURRENT_MSEC=`time_to_msec $CURRENT_TIME`
	echo $CURRENT_MSEC
}

function check_pid(){
	for((i=0;i<$PROC_NUM;i++))
	do
		j=`expr $i \* 9`
		if [ ${INFO[j]} -eq $1 ]
		then
			echo $i
			return;
		fi
	done
	echo $i
}

function procname_to_pid(){
	PROCNAME=$1
	TARGET_PID=`$ADB shell ps | grep $PROCNAME | awk -F " " '{print $2}'`
	echo $TARGET_PID
}

function parse_fps_log(){
	CURRENT_TIME=`echo $LINE | awk -F " " '{print $2}'`
	CURRENT_MSEC=`time_to_msec $CURRENT_TIME`
	CURRENT_PID=`echo $LINE | awk -F " " '{print $3}'`
	CURRENT_FRAME_TIME=`echo $LINE | awk -F " " '{print $14}'`
	
	PROC_INDEX=`check_pid $CURRENT_PID`
	if [ $PROC_INDEX -eq  $PROC_NUM ]
	then
		add_to_info $CURRENT_PID $TOUCH_TIME $CURRENT_MSEC
	else
		update_info $PROC_INDEX $CURRENT_MSEC $CURRENT_FRAME_TIME $PREVIOUS_FRAME_TIME
	fi
	
	PREVIOUS_FRAME_TIME=$CURRENT_FRAME_TIME
}

function update_info(){
	in=`expr $1 \* 9 + 3`					# last fps log time stamp
	INFO[in]=$2
	in=`expr $in + 1`						# max delay time
	if [ $3 -gt ${INFO[in]} ]
	then
		INFO[in]=$3
	fi
	in=`expr $in + 1`						# total frame time
	INFO[in]=`expr ${INFO[in]} + $3`
	in=`expr $in + 1`						# frame number
	INFO[in]=`expr ${INFO[in]} + 1`
	in=`expr $in + 1`						# good frame number
	if [ $3 -le 20 ]
	then
		INFO[in]=`expr ${INFO[in]} + 1`
	fi
	in=`expr $in + 1`						# jank count
	DELTA=`expr $3 - $4`
	if [ $DELTA -gt 16 ]
	then
		INFO[in]=`expr ${INFO[in]} + 1`
	fi
}

function add_to_info(){
	in=`expr $PROC_NUM \* 9`		# pid
	INFO[in]=$1
	in=`expr $in + 1`				# touch time stamp
	INFO[in]=$2
	in=`expr $in + 1`				# 1st fps log time stamp
	INFO[in]=$3
	PROC_NUM=$((PROC_NUM+1))
	in=`expr $in + 1`				# last fps log time stamp
	INFO[in]=0
	in=`expr $in + 1`				# max delay time
	INFO[in]=0
	in=`expr $in + 1`				# total frame time
	INFO[in]=0
	in=`expr $in + 1`				# frame number
	INFO[in]=0
	in=`expr $in + 1`				# good frame number
	INFO[in]=0
	in=`expr $in + 1`				# jank count
	INFO[in]=0
}

function main(){
	START=0
	pre_parse
	while read LINE
	do
		echo $LINE | grep UIAT | grep -q begin
		if [ $? -eq 0 ]
		then
			if [ $START -eq 0 ]
			then
				START=1
			fi
			TOUCH_TIME=`parse_touch_log`
		fi
		echo $LINE | grep libEGL | grep -q FPS
		if [ $? -eq 0 -a $START -eq 1 ]
		then
			FRAME_TIME=`echo $LINE | awk -F " " '{print $14}'`
			TIME=`echo $LINE | awk -F " " '{print $2}'`
			TEMP=`is_on_the_minute $TIME`
			if [ $TEMP -eq 1 -a $FRAME_TIME -gt 200 ]
			then
				continue
			else
				parse_fps_log
			fi
		fi
	done < temp.txt
}

function result(){
	PID=`procname_to_pid $TESTAPP`
	PID_INDEX=`check_pid $PID`
	LAST_FPS_TIME=${INFO[PID_INDEX*9+3]}
	RESPONSE=`expr $LAST_FPS_TIME - $TOUCH_TIME`
	echo "		TIME"
	echo "		TIME" >> $RESULT_FILE
	echo "AVERAGE:	${RESPONSE}ms"
	echo "AVERAGE:	${RESPONSE}ms" >> $RESULT_FILE
}

main
result
