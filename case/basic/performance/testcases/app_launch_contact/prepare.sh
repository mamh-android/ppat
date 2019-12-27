#! /bin/bash
cd $(dirname $0)
. ../../utils/UI_utils.sh $1
LOG_FILE="app_launch_contact"
TESTAPP="contacts"
$ADB root

# prepare
echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.FindContact

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""

