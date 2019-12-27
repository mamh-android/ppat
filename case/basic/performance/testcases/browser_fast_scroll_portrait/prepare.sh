#! /bin/bash
cd $(dirname $0)
. ../../utils/UI_utils.sh $1
######## Configuration ########

LOG_FILE="browser_fast_scroll_portrait"
$ADB root
LOADING_TIME=80
WEB_SITE=`cat website_list.txt`
echo "===========prepare==========="
sleep 2
gc_fps_setprop
$ADB shell setprop marvell.webcore.scrollingfps 1
$ADB shell setprop marvell.webcore.zoomingfps 0

# to the start location
$ADB shell input keyevent 3
sleep 2
$ADB shell input keyevent 3
sleep 2
clear_browser_cache_cookies
sleep 1
$ADB shell am start -n com.android.browser/.BrowserActivity -a android.intent.action.VIEW -d $1
sleep 2
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.ChooseDesktop
sleep $LOADING_TIME

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
