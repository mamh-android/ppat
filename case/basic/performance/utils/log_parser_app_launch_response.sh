TARGET_LOG=$1
RESULT_FILE=$2
TARGET_PID=$3
FLAG=0
FIRST=0
LAST_SECOND=0
TIME_RESULT_COUNT=0
TIME_MAX=0
TIME_MIN=0
FPS_AVERAGE_MAX=0
FPS_AVERAGE_MIN=0
FPS_RESULT_COUNT=0
FPS_MAX[$FPS_RESULT_COUNT]=-1
FPS_MIN[$FPS_RESULT_COUNT]=-1
FPS_COUNT=0
FPS_ARRAY=()
SMOOTH_RESULT=()
NUMBER=(1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th)

function analyse_smooth(){
	frame_first=2
	frame_last=2
	frame_middle=`expr ${#FPS_ARRAY[@]} - $frame_last`
	fps_first=20
	fps_middle=30
	fps_middle_lowest=20
	fps_last=20
	CONTINUOUS_FRAME_NUM=5
	
	i=1
	for fps in "${FPS_ARRAY[@]}"
	do
		#analyse the animation fps of the beginning
		if [ $i -le $frame_first ]
		then
			if [ $fps -lt $fps_first ]
			then
				SMOOTH_RESULT[${#SMOOTH_RESULT[@]}]="Not smooth(begin)"
				return
			fi
		else
			#analyse the animation fps of the middle
			if [ $i -le $frame_middle ]
			then
				if [ $fps -lt $fps_middle ]
				then
					if [ $fps -ge $fps_middle_lowest ]
					then
						j=$i
						k=0
						while [ $k -lt $CONTINUOUS_FRAME_NUM ]
						do
							if [ ${FPS_ARRAY[$j]} -lt $fps_middle -a $j -lt $frame_middle ]
							then 
								SMOOTH_RESULT[${#SMOOTH_RESULT[@]}]="Not smooth(middle)"
								return
							fi
							k=$((k+1))
							j=$((j+1))
						done
					else
						SMOOTH_RESULT[${#SMOOTH_RESULT[@]}]="Not smooth(middle)"
						return
					fi
				fi
			#analyse the animation fps of the endding
			else
				if [ $fps -lt $fps_last ]
				then
					SMOOTH_RESULT[${#SMOOTH_RESULT[@]}]="Not smooth(end)"
					return
				fi
			fi
		fi
		
		i=$((i+1))
	done
	SMOOTH_RESULT[${#SMOOTH_RESULT[@]}]="Smooth"
}

function touch_event_check(){
	echo $LINE | grep UIAT | grep -q begin
	if [ $? -eq 0 ]
	then
		# ............touch event log
		START_SECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $1}'`
		
		# DIFF. ..touch event....touch...event....
		if [ $START_SECOND -lt $LAST_SECOND ]
		then
			DIFF=`expr $START_SECOND + 60 - $LAST_SECOND`
		else
			DIFF=`expr $START_SECOND - $LAST_SECOND`
		fi
		
		# .....touch event....touch...event......................touch......event
		# .......touch event...fps log................
		if [ $FIRST -eq 0 -o $DIFF -ge 20 ]
		then
			if [ $FIRST -ne 0 ]
			then
				FPS_AVERAGE[$FPS_RESULT_COUNT]=`expr $FPS_COUNT \* 1000 / $TOTAL`
				if [ ${FPS_AVERAGE[$FPS_RESULT_COUNT]} -lt ${FPS_AVERAGE[$FPS_AVERAGE_MIN]} ]
				then
					FPS_AVERAGE_MIN=$FPS_RESULT_COUNT
				fi
				if [ ${FPS_AVERAGE[$FPS_RESULT_COUNT]} -gt ${FPS_AVERAGE[$FPS_AVERAGE_MAX]} ]
				then
					FPS_AVERAGE_MAX=$FPS_RESULT_COUNT
				fi
				FPS_RESULT_COUNT=$(($FPS_RESULT_COUNT+1))
				# FPS.......
				TOTAL=0
				FPS_COUNT=0
				FPS_MAX[$FPS_RESULT_COUNT]=-1
				FPS_MIN[$FPS_RESULT_COUNT]=-1
				#analyse_smooth
				FPS_ARRAY=()
			fi
		
			FLAG=1
			FIRST=1
			START_MSECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $2}' | awk -F " " '{print $1}'`
			LAST_SECOND=$START_SECOND
		fi
	else
		#..touch event.....fps log...max.min fps
		if [ $FIRST -ne 0 ]
		then
			END_SECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $1}'`
			END_MSECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $2}' | awk -F " " '{print $1}'`
			if [ $END_SECOND -eq 0 -a $END_MSECOND -lt 400 ]
			then
				return
			else
				FPS_COUNT=$(($FPS_COUNT+1))
				CURRENT_FRAME_TIME=`echo $LINE | awk -F " " '{print $14}'`
				# 去除fps无限大的情况（此时显示画一帧用了0ms）
				if [ $CURRENT_FRAME_TIME -eq 0 ]
				then
					FPS_ARRAY[${#FPS_ARRAY[@]}]=1000
					return
				fi
				
				CURRENT_FPS=`expr 1000 / $CURRENT_FRAME_TIME`
				if [ ${FPS_MIN[$FPS_RESULT_COUNT]} -eq -1 ]
				then
					FPS_MIN[$FPS_RESULT_COUNT]=$CURRENT_FPS
					FPS_MAX[$FPS_RESULT_COUNT]=$CURRENT_FPS
				else
					if [ $CURRENT_FPS -gt ${FPS_MAX[$FPS_RESULT_COUNT]} ]
					then
						FPS_MAX[$FPS_RESULT_COUNT]=$CURRENT_FPS
					fi
					if [ $CURRENT_FPS -lt ${FPS_MIN[$FPS_RESULT_COUNT]} ]
					then
						FPS_MIN[$FPS_RESULT_COUNT]=$CURRENT_FPS
					fi
				fi
				TOTAL=`expr $TOTAL + $CURRENT_FRAME_TIME`
				FPS_ARRAY[${#FPS_ARRAY[@]}]=$CURRENT_FPS
			fi
		fi
	fi
}

function fps_log_check(){
	echo $LINE | grep -q $TARGET_PID
	if [ $? -eq 0 ]
	then
		FLAG=0
		END_SECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $1}'`
		END_MSECOND=`echo $LINE | awk -F ":" '{print $3}' | awk -F "." '{print $2}' | awk -F " " '{print $1}'`
		if [ $END_SECOND -eq 0 -a $END_MSECOND -lt 200 ]
		then
			return
		fi
		# Get the response time
		if [ $END_SECOND -lt $START_SECOND ]
		then 
			RESPONSE_TIME[$TIME_RESULT_COUNT]=`expr \( $END_SECOND + 60 \) \* 1000 + $END_MSECOND - $START_SECOND \* 1000 - $START_MSECOND`
		else
			RESPONSE_TIME[$TIME_RESULT_COUNT]=`expr $END_SECOND \* 1000 + $END_MSECOND - $START_SECOND \* 1000 - $START_MSECOND`
		fi
		if [ ${RESPONSE_TIME[$TIME_RESULT_COUNT]} -lt ${RESPONSE_TIME[$TIME_MIN]} ]
		then
			TIME_MIN=$TIME_RESULT_COUNT
		fi
		if [ ${RESPONSE_TIME[$TIME_RESULT_COUNT]} -gt ${RESPONSE_TIME[$TIME_MAX]} ]
		then
			TIME_MAX=$TIME_RESULT_COUNT
		fi
		#echo "${NUMBER[$TIME_RESULT_COUNT]} ${RESPONSE_TIME[$TIME_RESULT_COUNT]}"
		TIME_RESULT_COUNT=$(($TIME_RESULT_COUNT+1))
	fi
}

# Get the content we want
cat $TARGET_LOG | grep -E '(UIAT|FPS)' > temp.txt

START_TIME=`date +%s`
# The Real Parser
while read LINE
do
	case $FLAG in
		"0")	touch_event_check;;
		"1")	fps_log_check;;
		*)		echo "error";;
	esac
done < temp.txt
FPS_AVERAGE[$FPS_RESULT_COUNT]=`expr $FPS_COUNT \* 1000 / $TOTAL`
FPS_RESULT_COUNT=$(($FPS_RESULT_COUNT+1))
#analyse_smooth
CURRENT_TIME=`date +%s`
ELAPSE=`expr $CURRENT_TIME - $START_TIME`
#echo "Total time: $ELAPSE"

# Print the result
echo "$LOG_FILE" > $RESULT_FILE
TOTAL=0
TOTAL_FPS=0
echo "		TIME	"
echo "		TIME	" >> $RESULT_FILE
for((j=0, i=1;j<$TIME_RESULT_COUNT;j++, i++))
do
	echo "${i}:		${RESPONSE_TIME[$j]}ms	"
	echo "${i}:		${RESPONSE_TIME[$j]}ms	" >> $RESULT_FILE
	if [ $j -eq $TIME_MIN -a $TIME_RESULT_COUNT -ne 1 ]
	then
		continue
	fi
	TOTAL=`expr $TOTAL + ${RESPONSE_TIME[$j]}`
	TOTAL_FPS=`expr $TOTAL_FPS + ${FPS_AVERAGE[$j]}`
done

# Print Average
if [ $j -lt 1 ]
then
	j=$(($j-1))
fi
AVERAGE=`expr $TOTAL / $j`
AVERAGE_FPS=`expr $TOTAL_FPS / $j`
echo "Average:	${AVERAGE}ms	"
echo "AVERAGE:	${AVERAGE}ms	" >> $RESULT_FILE

# Print MAX
# echo "MAX:		${RESPONSE_TIME[$TIME_MAX]}ms	"
# echo "MAX:		${RESPONSE_TIME[$TIME_MAX]}ms	" >> $RESULT_FILE

# Print MIN
# echo "MIN:		${RESPONSE_TIME[$TIME_MIN]}ms	"
# echo "MIN:		${RESPONSE_TIME[$TIME_MIN]}ms	" >> $RESULT_FILE

## Print Variance
# TOTAL=0
# for((j=0;j<$FPS_RESULT_COUNT;j++))
# do
	# if [ $j -eq $TIME_MIN -a $FPS_RESULT_COUNT -ne 1 ]
	# then
		# continue
	# fi
	# TEMP=`expr ${RESPONSE_TIME[$j]} - $AVERAGE`
	# TEMP=`expr $TEMP \* $TEMP`
	# TOTAL=`expr $TOTAL + $TEMP`
# done
# if [ $j -lt 1 ]
# then
	# j=$(($j-1))
# fi
# VARIANCE=`expr $TOTAL / $j`
## FPS
# TOTAL=0
# for((j=0;j<$TIME_RESULT_COUNT;j++))
# do
	# if [ $j -eq $TIME_MIN -a $TIME_RESULT_COUNT -ne 1 ]
	# then
		# continue
	# fi
	# TEMP=`expr ${FPS_AVERAGE[$j]} - $AVERAGE_FPS`
	# TEMP=`expr $TEMP \* $TEMP`
	# TOTAL=`expr $TOTAL + $TEMP`
# done
# if [ $j -lt 1 ]
# then
	# j=$(($j-1))
# fi
# FPS_VARIANCE=`expr $TOTAL / $j`
# echo "Varience:	${VARIANCE}	"
# echo "Varience:	${VARIANCE}	" >> $RESULT_FILE
