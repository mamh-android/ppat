#!/bin/bash
id=$1
platform=$2

adb -s $id shell cap_temperature.sh 1900 > temperature.log &

if [ $2 == "edenff" ]
then
	./set.sh 1208 $id EDEN 30
elif [ $2 == "hln3ff" ]
then
	./set.sh 1208 $id HELAN3 30
else
	echo "ERROR: platform $2 not supported!!!"
fi

kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')
