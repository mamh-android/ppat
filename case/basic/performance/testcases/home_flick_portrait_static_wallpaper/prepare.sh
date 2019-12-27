#! /bin/bash
######## Configuration ########
LOG_FILE="home_flick_portrait_static_wallpaper"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
$ADB root
echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.HomeStaticWallpaper

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
