TARGET_LOG=$1
RESULT_FILE=$2
BROWSER_TAG=$3
INFO=()
PROC_NUM=0
TOUCH_TIME=0
START_TIME=0
PREVIOUS_FRAME_TIME=0
RESULT_COUNT=0
FPS=()
RESPONSE=()
JANK=()
MAX_DELAY=()
SMOOTH=()
FPS_AUTO=()
LAST_FRAME_TIME=()
TILE_PERCENTAGE=()
LINE=""
FLAG=0

if [ $BROWSER_TAG = "scroll" ]
then
	BROWSER_TAG_1="SCROLLING_START"
	BROWSER_TAG_2="scrolling fps"
fi

if [ $BROWSER_TAG = "zoom" ]
then
	BROWSER_TAG_1="ZOOMING_START"
	BROWSER_TAG_2="zooming fps"
fi

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
	cat $TARGET_LOG | grep -E '(UIAT|FPS|chromium)' > temp.txt
}

function parse_touch_log(){
	CURRENT_TIME=`echo $LINE | awk -F " " '{print $2}'`
	CURRENT_MSEC=`time_to_msec $CURRENT_TIME`
	echo $CURRENT_MSEC
}

function parse_start_log(){
	CURRENT_TIME=`echo $LINE | awk -F " " '{print $2}'`
	CURRENT_MSEC=`time_to_msec $CURRENT_TIME`
	echo $CURRENT_MSEC
}

function check_pid(){
	for((i=0;i<$PROC_NUM;i++))
	do
		j=`expr $i \* 10`
		if [ ${INFO[j]} -eq $1 ]
		then
			echo $i
			return;
		fi
	done
	echo $i
}

function parse_fps_log(){
	CURRENT_TIME=`echo $LINE | awk -F " " '{print $2}'`
	CURRENT_MSEC=`time_to_msec $CURRENT_TIME`
	CURRENT_PID=`echo $LINE | awk -F " " '{print $3}'`
	CURRENT_FRAME_TIME=`echo $LINE | awk -F " " '{print $15}'`
	
	PROC_INDEX=`check_pid $CURRENT_PID`
	if [ $PROC_INDEX -eq  $PROC_NUM ]
	then
		add_to_info $CURRENT_PID $TOUCH_TIME $START_TIME $CURRENT_MSEC
	else
		update_info $PROC_INDEX $CURRENT_MSEC $CURRENT_FRAME_TIME $PREVIOUS_FRAME_TIME
	fi
	
	PREVIOUS_FRAME_TIME=$CURRENT_FRAME_TIME
}

function update_info(){
	in=`expr $1 \* 10 + 4`					# last fps log time stamp
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
	in=`expr $PROC_NUM \* 10`		# pid
	INFO[in]=$1
	in=`expr $in + 1`				# touch time stamp
	INFO[in]=$2
	in=`expr $in + 1`				# start time stamp
	INFO[in]=$3
	in=`expr $in + 1`				# 1st fps log time stamp
	INFO[in]=$4
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
		#TEMP_FPS=`expr ${INFO[i*9+6]} \* 1000 / ${INFO[i*9+5]}`
		TEMP_FPS=`expr ${INFO[i*9+7]} \* 1000 / \( ${INFO[i*9+4]} - ${INFO[i*9+3]} \)`
		TEMP_RESPONSE=`expr ${INFO[i*9+2]} - ${INFO[i*9+1]}`
		TEMP_SMOOTH=`expr ${INFO[i*9+8]} \* 100 / ${INFO[i*9+7]}`
		TEMP_JANK=${INFO[i*9+9]}
		TEMP_MAX_DELAY=${INFO[i*9+5]}
		if [ $TEMP_FPS -gt $RESULT_FPS ]
		then
			RESULT_FPS=$TEMP_FPS
			RESULT_RESPONSE=$TEMP_RESPONSE
			RESULT_SMOOTH=$TEMP_SMOOTH
			RESULT_JANK=$TEMP_JANK
			RESULT_MAX_DEALY=$TEMP_MAX_DELAY
		fi
		echo "${INFO[i*9]}: $TEMP_FPS $TEMP_RESPONSE $TEMP_JANK $TEMP_MAX_DELAY $TEMP_SMOOTH%" >> $RESULT_FILE
	done
	FPS[${#FPS[@]}]=$RESULT_FPS
	RESPONSE[${#RESPONSE[@]}]=$RESULT_RESPONSE
	JANK[${#JANK[@]}]=$RESULT_JANK
	MAX_DELAY[${#MAX_DELAY[@]}]=$RESULT_MAX_DEALY
	SMOOTH[${#SMOOTH[@]}]=$RESULT_SMOOTH
	INFO=()
	PROC_NUM=0
	TOUCH_TIME=0
	START_TIME=0
	PREVIOUS_FRAME_TIME=0
}

function parse_touch_begin(){
	echo $LINE | grep UIAT | grep -q begin
	if [ $? -eq 0 ]
	then
		TOUCH_TIME=`parse_touch_log`
		FLAG=1
	fi
}

function parse_scroll_start(){
	echo $LINE | grep -q $BROWSER_TAG_1
	if [ $? -eq 0 ]
	then
		START_TIME=`parse_start_log`
		FLAG=2
	fi
}

function parse_fps(){
	echo $LINE | grep -q FPS
	if [ $? -eq 0 ]
	then
		parse_fps_log
	fi
	echo $LINE | egrep -q "$BROWSER_TAG_2"
	if [ $? -eq 0 ]
	then
		RESULT_COUNT=$((RESULT_COUNT+1))
		calculate_last_result
		TEMP_FPS_AUTO=`echo $LINE | awk -F " " '{print $11}' | awk -F "." '{print $1}'`
		FPS_AUTO[${#FPS_AUTO[@]}]=$TEMP_FPS_AUTO
		FLAG=3
	fi
}

function parse_last_frame_time(){
	echo $LINE | grep -q "last frame drawing time"
	if [ $? -eq 0 ]
	then
		TEMP_LAST_FRAME_TIME=`echo $LINE | awk -F " " '{print $18}' | awk -F "." '{print $1}'`
		LAST_FRAME_TIME[${#LAST_FRAME_TIME[@]}]=$TEMP_LAST_FRAME_TIME
		FLAG=4
	fi
}

function parse_tile_percentage(){
	echo $LINE | grep -q "tile percentage"
	if [ $? -eq 0 ]
	then
		PERCENT_INT=`echo $LINE | awk -F " " '{print $18}' | awk -F "." '{print $1}'`
		PERCENT_FRACTION=`echo $LINE | awk -F " " '{print $18}' | awk -F "." '{print $2}' | cut -c -2`
		if [ -n "$PERCENT_INT" ]
		then
			TEMP_TILE_PERCENTAGE=100
		else
			TEMP_TILE_PERCENTAGE=`expr $PERCENT_INT \* 100 + $PERCENT_FRACTION`
		fi
		TILE_PERCENTAGE[${#TILE_PERCENTAGE[@]}]=$TEMP_TILE_PERCENTAGE
		FLAG=0
	fi
}

function main(){
	START=0
	pre_parse
	while read LINE
	do
		case $FLAG in
			"0")	parse_touch_begin;;
			"1")	parse_scroll_start;;
			"2")	parse_fps;;
			"3")	parse_last_frame_time;;
			"4")	parse_tile_percentage;;
			*)		echo "error";;
		esac
	done < temp.txt
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
	TOTAL_FPS_AUTO=0
	MAX_FPS_AUTO=-1
	MIN_FPS_AUTO=-1
	for fps_auto in ${FPS_AUTO[@]}
	do
		if [ $MAX_FPS_AUTO -eq -1 ]
		then
			MAX_FPS_AUTO=$fps_auto
			MIN_FPS_AUTO=$fps_auto
		else
			if [ $fps_auto -gt $MAX_FPS_AUTO ]
			then
				MAX_FPS_AUTO=$fps_auto
			fi
			if [ $fps_auto -lt $MIN_FPS_AUTO ]
			then
				MIN_FPS_AUTO=$fps_auto
			fi
		fi
		TOTAL_FPS_AUTO=`expr $TOTAL_FPS_AUTO + $fps_auto`
	done
	AVERAGE_FPS_AUTO=`expr $TOTAL_FPS_AUTO / $RESULT_COUNT`
	TOTAL_LAST_FRAME_TIME=0
	MAX_LAST_FRAME_TIME=-1
	MIN_LAST_FRAME_TIME=-1
	for last_frame_time in ${LAST_FRAME_TIME[@]}
	do
		if [ $MAX_LAST_FRAME_TIME -eq -1 ]
		then
			MAX_LAST_FRAME_TIME=$last_frame_time
			MIN_LAST_FRAME_TIME=$last_frame_time
		else
			if [ $last_frame_time -gt $MAX_LAST_FRAME_TIME ]
			then
				MAX_LAST_FRAME_TIME=$last_frame_time
			fi
			if [ $last_frame_time -lt $MIN_LAST_FRAME_TIME ]
			then
				MIN_LAST_FRAME_TIME=$last_frame_time
			fi
		fi
		TOTAL_LAST_FRAME_TIME=`expr $TOTAL_LAST_FRAME_TIME + $last_frame_time`
	done
	AVERAGE_LAST_FRAME_TIME=`expr $TOTAL_LAST_FRAME_TIME / $RESULT_COUNT`
	TOTAL_TILE_PERCENTAGE=0
	MAX_TILE_PERCENTAGE=-1
	MIN_TILE_PERCENTAGE=-1
	for tile_percentage in ${TILE_PERCENTAGE[@]}
	do
		if [ $MAX_TILE_PERCENTAGE -eq -1 ]
		then
			MAX_TILE_PERCENTAGE=$tile_percentage
			MIN_TILE_PERCENTAGE=$tile_percentage
		else
			if [ $tile_percentage -gt $MAX_TILE_PERCENTAGE ]
			then
				MAX_TILE_PERCENTAGE=$tile_percentage
			fi
			if [ $tile_percentage -lt $MIN_TILE_PERCENTAGE ]
			then
				MIN_TILE_PERCENTAGE=$tile_percentage
			fi
		fi
		TOTAL_TILE_PERCENTAGE=`expr $TOTAL_TILE_PERCENTAGE + $tile_percentage`
	done
	AVERAGE_TILE_PERCENTAGE=`expr $TOTAL_TILE_PERCENTAGE / $RESULT_COUNT`
	echo "		TIME	FPS	JANK	MAX DELAY	SMOOTH	FPS_REF	LAST TIME	TILE PER"
	echo "		TIME	FPS	JANK	MAX DELAY	SMOOTH	FPS_REF	LAST TIME	TILE PER" >> $RESULT_FILE
	for((i=0, j=1;i<RESULT_COUNT;i++, j++))
	do
		echo "$j:		${RESPONSE[i]}ms	${FPS_AUTO[i]}	${JANK[i]}	${MAX_DELAY[i]}ms		${SMOOTH[i]}%	${FPS[i]}	${LAST_FRAME_TIME[i]}ms		${TILE_PERCENTAGE[i]}%"
		echo "$j:		${RESPONSE[i]}ms	${FPS_AUTO[i]}	${JANK[i]}	${MAX_DELAY[i]}ms		${SMOOTH[i]}%	${FPS[i]}	${LAST_FRAME_TIME[i]}ms		${TILE_PERCENTAGE[i]}%" >> $RESULT_FILE
	done
	echo "AVERAGE:	${AVERAGE_RESPONSE}ms	$AVERAGE_FPS_AUTO	$AVERAGE_JANK	${AVERAGE_MAX_DELAY}ms		$AVERAGE_SMOOTH%	$AVERAGE_FPS	${AVERAGE_LAST_FRAME_TIME}ms		$AVERAGE_TILE_PERCENTAGE%"
	echo "AVERAGE:	${AVERAGE_RESPONSE}ms	$AVERAGE_FPS_AUTO	$AVERAGE_JANK	${AVERAGE_MAX_DELAY}ms		$AVERAGE_SMOOTH%	$AVERAGE_FPS	${AVERAGE_LAST_FRAME_TIME}ms		$AVERAGE_TILE_PERCENTAGE%" >> $RESULT_FILE
	echo "MAX:		${MAX_RESPONSE}ms	$MAX_FPS_AUTO	$MAX_JANK	${MAX_MAX_DELAY}ms		$MAX_SMOOTH%	$MAX_FPS	${MAX_LAST_FRAME_TIME}ms		$MAX_TILE_PERCENTAGE%"
	echo "MAX:		${MAX_RESPONSE}ms	$MAX_FPS_AUTO	$MAX_JANK	${MAX_MAX_DELAY}ms		$MAX_SMOOTH%	$MAX_FPS	${MAX_LAST_FRAME_TIME}ms		$MAX_TILE_PERCENTAGE%" >> $RESULT_FILE
	echo "MIN:		${MIN_RESPONSE}ms	$MIN_FPS_AUTO	$MIN_JANK	${MIN_MAX_DELAY}ms		$MIN_SMOOTH%	$MIN_FPS	${MIN_LAST_FRAME_TIME}ms		$MIN_TILE_PERCENTAGE%"
	echo "MIN:		${MIN_RESPONSE}ms	$MIN_FPS_AUTO	$MIN_JANK	${MIN_MAX_DELAY}ms		$MIN_SMOOTH%	$MIN_FPS	${MIN_LAST_FRAME_TIME}ms		$MIN_TILE_PERCENTAGE%" >> $RESULT_FILE
}

main
result
