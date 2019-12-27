#!/bin/bash
id=$1

adb -s $id shell cap_temperature.sh 1900 > temperature.log &
sleep 600

adb -s $id shell am force-stop com.android.camera2
kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')
