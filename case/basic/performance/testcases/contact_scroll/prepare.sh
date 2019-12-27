#! /bin/bash
######## Configuration ########
LOG_FILE="contact_scroll"
$ADB root

DEVICE=$1
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
##############################

# prepare
echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
adb shell am start -n com.android.contacts/.activities.PeopleActivity
sleep 2

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
