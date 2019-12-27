######## operation ########
while [ $OPERATION_LOOP -gt 0 ]
do
	adb shell sendevent /sdcard/press_${COLUMN_NUM}_${ROW_NUM}.evt
	sleep $OPERATION_INTERVAL
	adb shell input keyevent 4
	sleep 2
	### force close the app if need cold launch every time ###
	if [ $NEED_FORCE_CLOSE -eq 1 -o $ALL_NEED_FORCE_CLOSE=1]
	then
		adb shell am force-stop com.android.contacts
	fi
	
	OPERATION_LOOP=$(($OPERATION_LOOP-1))
done
echo "================================================"
echo ""
###########################