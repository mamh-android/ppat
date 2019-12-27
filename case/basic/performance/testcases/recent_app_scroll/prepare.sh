#! /bin/bash
######## Configuration ########
LOG_FILE="recent_app_scroll"
DEVICE=$1
# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE
$ADB root
echo "===========prepare==========="
sleep 2
general_setprop

# to the start location
$ADB shell input keyevent 3
sleep 2
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n com.android.browser/.BrowserActivity
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n com.android.contacts/.activities.PeopleActivity
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n com.android.gallery3d/.app.Gallery 
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.mms/.ui.ConversationList
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.settings/.Settings
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.deskclock/.DeskClock
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.calculator2/.Calculator
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.calendar/.AllInOneActivity
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.android.music/.ArtistAlbumBrowserActivity
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell am start -n  com.example.android.notepad/.NotesList
sleep 5
$ADB shell input keyevent 3
sleep 2
$ADB shell uiautomator runtest UIAT2.jar -c com.uiat.EnterRecentApp

# clean logcat
echo "===========clean logcat==========="
sleep 2
$ADB logcat -c
echo ""
