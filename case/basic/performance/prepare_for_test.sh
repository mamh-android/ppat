DEVICE_ID=$1
if [ -z $DEVICE_ID ]
then
	ADB="adb"
else
	ADB="adb -s $DEVICE_ID"
fi
cd $(dirname $0)
# create result, log folder
if [ ! -d result ]; then
    mkdir result
fi
if [ ! -d log ]; then
    mkdir log
fi
# UIAT2 uiautomator needed file
$ADB root
sleep 3
$ADB remount
$ADB push utils/libUI.so /system/lib/
$ADB push utils/libUI_64.so /system/lib64/libUI.so
$ADB push utils/UIAT2.jar /data/local/tmp/

#APP
$ADB install resource/app/3DMarkMobile06.apk
$ADB push resource/app/mm06 /${storage}/mm06
$ADB install resource/app/3DMarkMobile07.apk
$ADB push resource/app/mm07 /${storage}/mm07
$ADB install resource/app/AnimationTest.apk
$ADB install resource/app/ScreenResolution.apk
$ADB install resource/app/Test.apk
$ADB install resource/app/antutu4.0.3.apk
$ADB install resource/app/GLBenchmark2.1.5_savelog.apk
$ADB install resource/app/quadrant_advanced_v2.1.1.apk
$ADB install resource/app/temple_run_2_c1.9.4.apk
$ADB push resource/app/press_ok.jar /data/local/tmp/
$ADB install resource/app/taobao_07_17_4.6.0.apk
$ADB install resource/app/youku_08_08_4.1.3.apk

# fill the home screen with icons
$ADB shell am start -n com.example.test/.MainActivity --ei num 30
sleep 5
$ADB shell input keyevent 4
sleep 2

#Picture
$ADB push resource/picture/ /${storage}/picture/

#Contact
$ADB push resource/contact/contact.vcf /${storage}/
$ADB shell am start -n com.android.contacts/.activities.PeopleActivity
sleep 5
$ADB shell input keyevent 20
sleep 2
$ADB shell input keyevent 20
sleep 2
$ADB shell input keyevent 20
sleep 2
$ADB shell input keyevent 20
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 4
sleep 2

# import call log
$ADB install resource/500Calllog/CallLogBackupRestore.apk
$ADB push resource/500Calllog/calllog.xml /${storage}/
$ADB shell am start -n com.riteshsahu.CallLogBackupRestore/.FreeMainActivity
sleep 5
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 20
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 66
sleep 2
$ADB shell input keyevent 61
sleep 2
$ADB shell input keyevent 66
sleep 90
$ADB shell input keyevent 4
sleep 2
$ADB shell input keyevent 4
sleep 2
$ADB shell input keyevent 4
sleep 2


#MP3
$ADB push resource/music/MP3-50/ /${storage}/MP3-50

#Video
$ADB push resource/video/Rise_of_the_Guardians-Trailer_2_\(HD_1080p\).mp4 /${storage}/
