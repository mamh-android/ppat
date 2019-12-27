#! /bin/bash
######## Configuration ########
LOG_FILE="music_scroll"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
$ADB root


echo "===========prepare==========="
sleep 2
gc_fps_setprop

# to the start location
$ADB shell am start -n com.android.music/.MusicBrowserActivity
sleep 2

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
