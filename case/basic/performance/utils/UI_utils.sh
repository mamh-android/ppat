#! /bin/bash
###############
# UI test utils
###############

# device id configuration
DEVICE_ID=$1
if [ -z $DEVICE_ID ]
then
	ADB="adb"
else
	ADB="adb -s $DEVICE_ID"
fi

function general_setprop(){
	$ADB shell setprop marvell.graphics.print_fps 0
	$ADB shell setprop marvell.graphics.egl.fps 1
}

function gc_fps_setprop(){
	$ADB shell setprop marvell.graphics.egl.fps 0
	$ADB shell setprop marvell.graphics.print_fps 1
}

function start_logcat(){
	TEST_LOG=$1
	date > $TEST_LOG
	echo "start logcat -d to $TEST_LOG"
	$ADB logcat -d -v threadtime >> $TEST_LOG
}

function start_log(){
	LOG_FILENAME=$1
	start_logcat ../../log/$LOG_FILENAME.log
}

function end_log(){
	ps -ef | grep threadtime | grep -v grep | awk '{print $2}' | xargs kill -9
}

function clear_browser_cache_cookies(){
	$ADB shell am force-stop com.android.browser
	$ADB shell am start -n com.android.browser/.BrowserActivity
	sleep 2
	$ADB shell input keyevent 82
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 66
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 66
	sleep 1
	# clear cache
	$ADB shell input keyevent 66
	sleep 1
	$ADB shell input keyevent 22
	sleep 1
	$ADB shell input keyevent 22
	sleep 1
	$ADB shell input keyevent 66
	# clear cache end
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	$ADB shell input keyevent 20
	sleep 1
	# clear cookies data
	$ADB shell input keyevent 66
	sleep 1
	$ADB shell input keyevent 22
	sleep 1
	$ADB shell input keyevent 22
	sleep 1
	$ADB shell input keyevent 66
	# clear cookies end
	sleep 1
	$ADB shell am force-stop com.android.browser
}
