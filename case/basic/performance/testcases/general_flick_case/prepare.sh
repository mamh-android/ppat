#! /bin/bash
######## Configuration ########
LOG_NAME="general_flick_case"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
$ADB root

echo "===========prepare==========="
sleep 2
general_setprop

# to the start location


# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
