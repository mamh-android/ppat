#! /bin/bash
######## Configuration ########
LOG_NAME="gallery_flick_portrait"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
##############################

# prepare
echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.EnterGalleryPortrait

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
