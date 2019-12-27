#! /bin/bash
cd $(dirname $0)
. ../../utils/UI_utils.sh $1
LOG_FILE="app_launch_browser"
TESTAPP="browser"

echo "===========prepare==========="
sleep 2
gc_fps_setprop

# to the start location
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.FindBrowser

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""

