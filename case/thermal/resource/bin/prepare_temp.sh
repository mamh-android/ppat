#!/bin/bash
id=$1
i=0
while [ "$i" -ne "5" ]
do
	thermal_type=`adb -s $id shell cat /sys/class/thermal/thermal_zone$i/type`
	thermal_type=${thermal_type:0:8}
	test="tsen_max"
	if [ $thermal_type == $test ]
	then
		echo "found"
		break;
	fi
	i=$(($i+1))
done
#	echo $thermal_type

j=10
while [ "$j" -ne "0" ]
do
	thermal_temp=`adb -s $id shell cat /sys/class/thermal/thermal_zone$i/temp`
#		echo $thermal_temp
	if [ `echo $thermal_temp | awk -v ai=42000 '{print($1<ai)?"1":"0"}'` == "1" ]
	then
		break
	fi
	if [ $j -eq "10" ]
	then
		adb -s $id shell input keyevent 26
	fi
	echo "SoC is still higher than 42degC: $thermal_temp"
	echo "Wait 3 min. ($j times left to try)"
	sleep 180
	j=$(($j-1))
done

if [ "$j" -ne "10" ]
then
	adb -s $id shell svc power stayon true
	adb -s $id shell input keyevent 82
fi

if [ "$j" -eq "0" ]
then
	echo "Device is too hot for thermal test!"
	echo "Exit.."
	exit 1
fi

exit 0

