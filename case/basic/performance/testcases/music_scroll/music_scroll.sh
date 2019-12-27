######## Configuration ########
LEFT="normal_flick_up.evt"
RIGHT="normal_flick_down.evt"
ENTER_MUSIC="enter_music.evt"
LOG_NAME="music_scroll"
OPERATION_INTERVAL=3
OPERATION_LOOP=3
##############################

# prepare
echo "===========prepare==========="
sleep 2

# import public utils
. ../../utils/UI_utils.sh

# root
adb root
sleep 2

# push the uevent file into sdcard
LOCATION=`pwd`
echo "push the uevent file into sdcard..."
cd ../../lib
adb push $LEFT /sdcard/
adb push $RIGHT /sdcard/
adb push $ENTER_MUSIC /sdcard/
cd $LOCATION

# setprop to show the touch and fps in log
echo "setprop..."
general_setprop

# to the start location
echo "to the start location..."
adb shell input keyevent 3
sleep 2
adb shell input keyevent 3
sleep 2
adb shell am start -n com.sec.android.app.music/.list.activity.MpMainTabActivity
sleep 2
adb shell sendevent /sdcard/$ENTER_MUSIC
sleep 1
echo "============================="
echo ""

# clean logcat
echo "===========clean logcat==========="
sleep 2
adb logcat -c
echo ""

# start log
echo "===========music scroll start==========="
sleep 2
RESULT=`date +%F-%H-%M-%S`
start_log ${RESULT}_${LOG_NAME}
sleep 2

######## operation ########
while [ $OPERATION_LOOP -gt 0 ]
do
	adb shell sendevent /sdcard/$LEFT
	sleep $OPERATION_INTERVAL
	adb shell sendevent /sdcard/$RIGHT
	sleep $OPERATION_INTERVAL
	
	OPERATION_LOOP=$(($OPERATION_LOOP-1))
done
sleep 3
echo "========================================"
echo ""
###########################

# end log
echo "===========music scroll end==========="
end_log
sleep 2
echo "======================================"
echo ""

# log parser
echo "===========parse log begin==========="
. ../../utils/log_parser.sh ../../log/${RESULT}_${LOG_NAME}.log ../../result/${RESULT}_${LOG_NAME}.txt
echo "===========parse log end============="
echo ""

adb shell input keyevent 4
sleep 1
adb shell input keyevent 4
sleep 1
echo "===========end==========="
echo ""
echo ""