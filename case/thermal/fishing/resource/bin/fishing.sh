#!/bin/bash
id=$1
storage=$2

adb -s $id shell cap_temperature.sh 1850 > temperature.log &
echo "launch game fishing"
adb -s $id shell sendevent /${storage}/prepare_fishing.evt
sleep 1800

adb -s $id shell am force-stop org.cocos2dx.FishGame
kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')
