TARGET_LOG=$1
RESULT_FILE=$2
INFO=()
PROC_NUM=0
TOUCH_TIME=0
PREVIOUS_FRAME_TIME=0
RESULT_COUNT=0
FPS=()
RESPONSE=()
JANK=()
MAX_DELAY=()
SMOOTH=()
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
	cat $TARGET_LOG | grep -E '(UIAT|libEGL)' > temp.txt
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

function pid_to_procname(){
	PROCNAME=`$ADB shell ps | grep " $1 " | cut -b 55-`
	echo $PROCNAME
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

function calculate_last_result(){
	RESULT_FPS=0;
	echo "$RESULT_COUNT touch" >> $RESULT_FILE
	for((i=0;i<$PROC_NUM;i++))
	do
		PROC=`pid_to_procname ${INFO[i*9]}`
		echo $PROC | grep -q surfaceflinger
		if [ $? -eq 0 ]
		then
			#TEMP_FPS=`expr ${INFO[i*9+6]} \* 1000 / ${INFO[i*9+5]}`
			TEMP_FPS=`expr ${INFO[i*9+6]} \* 1000 / \( ${INFO[i*9+3]} - ${INFO[i*9+2]} \)`
			TEMP_RESPONSE=`expr ${INFO[i*9+2]} - ${INFO[i*9+1]}`
			TEMP_SMOOTH=`expr ${INFO[i*9+7]} \* 100 / ${INFO[i*9+6]}`
			TEMP_JANK=${INFO[i*9+8]}
			TEMP_MAX_DELAY=${INFO[i*9+4]}
			if [ $TEMP_FPS -gt $RESULT_FPS ]
			then
				RESULT_FPS=$TEMP_FPS
				RESULT_RESPONSE=$TEMP_RESPONSE
				RESULT_SMOOTH=$TEMP_SMOOTH
				RESULT_JANK=$TEMP_JANK
				RESULT_MAX_DEALY=$TEMP_MAX_DELAY
			fi
			echo "${INFO[i*9]}: $TEMP_FPS $TEMP_RESPONSE $TEMP_JANK $TEMP_MAX_DELAY $TEMP_SMOOTH%" >> $RESULT_FILE
		fi
	done
	FPS[${#FPS[@]}]=$RESULT_FPS
	RESPONSE[${#RESPONSE[@]}]=$RESULT_RESPONSE
	JANK[${#JANK[@]}]=$RESULT_JANK
	MAX_DELAY[${#MAX_DELAY[@]}]=$RESULT_MAX_DEALY
	SMOOTH[${#SMOOTH[@]}]=$RESULT_SMOOTH
	INFO=()
	PROC_NUM=0
	TOUCH_TIME=0
	PREVIOUS_FRAME_TIME=0
}

function main(){
	START=0
	OPERATION_END=0
	pre_parse
	while read LINE
	do
		echo $LINE | grep UIAT | grep -q begin
		if [ $? -eq 0 ]
		then
			if [ $START -eq 0 ]
			then
				START=1
			else
				OPERATION_END=0
				RESULT_COUNT=$((RESULT_COUNT+1))
			fi
			if [ $RESULT_COUNT -ne 0 ]
			then
				calculate_last_result
			fi
			TOUCH_TIME=`parse_touch_log`
		fi
		echo $LINE | grep libEGL | grep -q FPS
		if [ $? -eq 0 -a $START -eq 1 -a $OPERATION_END -eq 0 ]
		then
			FRAME_TIME=`echo $LINE | awk -F " " '{print $14}'`
			TIME=`echo $LINE | awk -F " " '{print $2}'`
			TEMP=`is_on_the_minute $TIME`
			if [ $TEMP -eq 1 -a $FRAME_TIME -gt 200 ]
			then
				OPERATION_END=1
				continue
			else
				parse_fps_log
			fi
		fi
	done < temp.txt
	RESULT_COUNT=$((RESULT_COUNT+1))
	calculate_last_result
}

function result(){
	TOTAL_FPS=0
	MAX_FPS=-1
	MIN_FPS=-1
	for fps in ${FPS[@]}
	do
		if [ $MAX_FPS -eq -1 ]
		then
			MAX_FPS=$fps
			MIN_FPS=$fps
		else
			if [ $fps -gt $MAX_FPS ]
			then
				MAX_FPS=$fps
			fi
			if [ $fps -lt $MIN_FPS ]
			then
				MIN_FPS=$fps
			fi
		fi
		TOTAL_FPS=`expr $TOTAL_FPS + $fps`
	done
	AVERAGE_FPS=`expr $TOTAL_FPS / $RESULT_COUNT`
	TOTAL_RESPONSE=0
	MAX_RESPONSE=-1
	MIN_RESPONSE=-1
	for response in ${RESPONSE[@]}
	do
		if [ $MAX_RESPONSE -eq -1 ]
		then
			MAX_RESPONSE=$response
			MIN_RESPONSE=$response
		else
			if [ $response -gt $MAX_RESPONSE ]
			then
				MAX_RESPONSE=$response
			fi
			if [ $response -lt $MIN_RESPONSE ]
			then
				MIN_RESPONSE=$response
			fi
		fi
		TOTAL_RESPONSE=`expr $TOTAL_RESPONSE + $response`
	done
	AVERAGE_RESPONSE=`expr $TOTAL_RESPONSE / $RESULT_COUNT`
	TOTAL_JANK=0
	MAX_JANK=-1
	MIN_JANK=-1
	for jank in ${JANK[@]}
	do
		if [ $MAX_JANK -eq -1 ]
		then
			MAX_JANK=$jank
			MIN_JANK=$jank
		else
			if [ $jank -gt $MAX_JANK ]
			then
				MAX_JANK=$jank
			fi
			if [ $jank -lt $MIN_JANK ]
			then
				MIN_JANK=$jank
			fi
		fi
		TOTAL_JANK=`expr $TOTAL_JANK + $jank`
	done
	AVERAGE_JANK=`expr $TOTAL_JANK / $RESULT_COUNT`
	TOTAL_MAX_DELAY=0
	MAX_MAX_DELAY=-1
	MIN_MAX_DELAY=-1
	for max_delay in ${MAX_DELAY[@]}
	do
		if [ $MAX_MAX_DELAY -eq -1 ]
		then
			MAX_MAX_DELAY=$max_delay
			MIN_MAX_DELAY=$max_delay
		else
			if [ $max_delay -gt $MAX_MAX_DELAY ]
			then
				MAX_MAX_DELAY=$max_delay
			fi
			if [ $max_delay -lt $MIN_MAX_DELAY ]
			then
				MIN_MAX_DELAY=$max_delay
			fi
		fi
		TOTAL_MAX_DELAY=`expr $TOTAL_MAX_DELAY + $max_delay`
	done
	AVERAGE_MAX_DELAY=`expr $TOTAL_MAX_DELAY / $RESULT_COUNT`
	TOTAL_SMOOTH=0
	MAX_SMOOTH=-1
	MIN_SMOOTH=-1
	for smooth in ${SMOOTH[@]}
	do
		if [ $MAX_SMOOTH -eq -1 ]
		then
			MAX_SMOOTH=$smooth
			MIN_SMOOTH=$smooth
		else
			if [ $smooth -gt $MAX_SMOOTH ]
			then
				MAX_SMOOTH=$smooth
			fi
			if [ $smooth -lt $MIN_SMOOTH ]
			then
				MIN_SMOOTH=$smooth
			fi
		fi
		TOTAL_SMOOTH=`expr $TOTAL_SMOOTH + $smooth`
	done
	AVERAGE_SMOOTH=`expr $TOTAL_SMOOTH / $RESULT_COUNT`
	echo "		TIME	FPS	JANK	MAX DELAY	SMOOTH"
	echo "		TIME	FPS	JANK	MAX DELAY	SMOOTH" >> $RESULT_FILE
	for((i=0, j=1;i<RESULT_COUNT;i++, j++))
	do
		echo "$j:		${RESPONSE[i]}ms	${FPS[i]}	${JANK[i]}	${MAX_DELAY[i]}ms		${SMOOTH[i]}%"
		echo "$j:		${RESPONSE[i]}ms	${FPS[i]}	${JANK[i]}	${MAX_DELAY[i]}ms		${SMOOTH[i]}%" >> $RESULT_FILE
	done
	echo "AVERAGE:	${AVERAGE_RESPONSE}ms	$AVERAGE_FPS	$AVERAGE_JANK	${AVERAGE_MAX_DELAY}ms		$AVERAGE_SMOOTH%"
	echo "AVERAGE:	${AVERAGE_RESPONSE}ms	$AVERAGE_FPS	$AVERAGE_JANK	${AVERAGE_MAX_DELAY}ms		$AVERAGE_SMOOTH%" >> $RESULT_FILE
	echo "MAX:		${MAX_RESPONSE}ms	$MAX_FPS	$MAX_JANK	${MAX_MAX_DELAY}ms		$MAX_SMOOTH%"
	echo "MAX:		${MAX_RESPONSE}ms	$MAX_FPS	$MAX_JANK	${MAX_MAX_DELAY}ms		$MAX_SMOOTH%" >> $RESULT_FILE
	echo "MIN:		${MIN_RESPONSE}ms	$MIN_FPS	$MIN_JANK	${MIN_MAX_DELAY}ms		$MIN_SMOOTH%"
	echo "MIN:		${MIN_RESPONSE}ms	$MIN_FPS	$MIN_JANK	${MIN_MAX_DELAY}ms		$MIN_SMOOTH%" >> $RESULT_FILE
}

main
result
