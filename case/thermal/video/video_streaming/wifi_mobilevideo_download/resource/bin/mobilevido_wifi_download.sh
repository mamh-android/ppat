#!/bin/bash
id=$1

adb -s $id shell cap_temperature.sh 1900 > temperature.log &
sleep 1800
kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')
