#!/bin/bash
id=$1

echo "LCD off"
adb -s $id shell input keyevent 26

echo "force all cores on line"
core_num=`adb -s $id shell cat /sys/devices/system/cpu/cpunum_qos/max_core_num`
core_num=`echo $core_num | awk '{print substr($1,1,1)}'`
if [ $core_num -eq "4" ]
then
echo "echo 4 to min"
	adb -s $id shell 'echo 4 > /sys/devices/system/cpu/cpunum_qos/min_core_num'
elif [ $core_num -eq "8" ]
then
echo "echo 8 to min"
	adb -s $id shell 'echo 8 > /sys/devices/system/cpu/cpunum_qos/min_core_num'
fi

echo "start Soc cap"
adb -s $id shell cap_temperature.sh 400 > temperature.log &

echo "start $core_num cpueater"
adb -s $id shell cpueater_launch.sh $core_num

sleep 1800

adb -s $id shell ps cpueater | awk '{print $2}' > temp.log
cpueater_PID=($(cat temp.log))
echo $cpueater_PID
num_PID=${#cpueater_PID[*]}
echo "cpueater num: $num_PID"
i=1
while [ $i -ne $num_PID ]
do
	adb -s $id shell kill ${cpueater_PID[i]}
	i=$(($i+1))
done

kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')

adb -s $id shell 'echo 1 > /sys/devices/system/cpu/cpunum_qos/min_core_num'
adb -s $id shell svc power stayon true
adb -s $id shell input keyevent 82
rm temp.log
