#!/bin/bash

if [ $# -ge 2 ];then
	ADB_SERIAL="-s $2"
	echo "Your ADB device id: $2"
else 
	ADB_SERIAL=""
fi

adb $ADB_SERIAL root

echo "Now waiting for adb $ADB_SERIAL device ... "
adb $ADB_SERIAL wait-for-device


usage()
{
	echo "./set.sh [case_version] [adb device serial] [Platform] [launch time (minutes)]"
	exit 1
}

if [ $# -lt 1 ];then
	usage
fi

V=$1

wc_dir=../test_case/$1
data_dir=../test_case/data/

echo "install busybox ..."
adb $ADB_SERIAL shell mkdir /data/bin/
adb $ADB_SERIAL push ./busybox /data/bin/
adb $ADB_SERIAL push ./env.sh /data/bin/

adb $ADB_SERIAL shell /data/bin/env.sh
adb $ADB_SERIAL push p.sh /data/bin/

echo "remove power daemon && set power hinter service ..."
adb $ADB_SERIAL remount
adb $ADB_SERIAL shell mv /system/bin/powerdaemon /system/bin/powerdaemon.bak
adb $ADB_SERIAL shell phs_cmd 5 manual


echo "install worst case ..."
adb $ADB_SERIAL shell mkdir /data/worst_case/
adb $ADB_SERIAL push  $wc_dir/  /data/worst_case/
adb $ADB_SERIAL shell chmod -R 777 /data/worst_case/*

echo "install data ..."
adb $ADB_SERIAL push $data_dir  /data/worst_case/
adb $ADB_SERIAL push $data_dir/gc3d/sdcard /sdcard

adb $ADB_SERIAL install  $wc_dir/gc3d/VivantePort3Activity_KK4.4_hacked.apk

adb $ADB_SERIAL push ./readme.txt /data/worst_case/

adb $ADB_SERIAL push run_worstcase.sh /data/bin
adb $ADB_SERIAL shell chmod 777 /data/bin/run_worstcase.sh
adb $ADB_SERIAL shell /data/bin/run_worstcase.sh $3 $4

echo "bye"
