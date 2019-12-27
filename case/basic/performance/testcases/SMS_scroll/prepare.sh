#! /bin/bash
######## Configuration ########
LOG_FILE="SMS_scroll"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
$ADB root

echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
$ADB shell am start -n com.android.mms/.ui.ConversationList
sleep 2

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
