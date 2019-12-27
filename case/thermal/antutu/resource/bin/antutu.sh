#!/bin/bash
id=$1

adb -s $id shell cap_temperature.sh 400 > temperature.log &
sleep 10
adb -s $id shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -n com.antutu.ABenchMark/com.antutu.benchmark.activity.ScoreBenchActivity

adb -s $id shell logcat -c
k=10
while [ $k -ne "0" ]
do
    adb -s $id logcat -d -s AnTuTuBenchmarkScore > score.temp
	cmd=`cat score.temp | awk 'BEGIN{FS=":"}{if (substr($1,1,22) == "I/AnTuTuBenchmarkScore")print "OK";}'`
	cmd=${cmd:0:2}
	if [ "$cmd" == "OK" ]
	then
		break
	fi
	echo "Test is not finished..."
	echo "Wait 30 seconds. ($k times left to try)"
	sleep 30
	k=$(($k-1))
done

adb -s $id shell am force-stop com.antutu.ABenchMark
kill -9 $(ps -ef |awk '/cap_temperature.sh/{print $2}')
cat score.temp | awk 'BEGIN{FS=":"}{if(substr($1,1,22) == "I/AnTuTuBenchmarkScore")print $2,$3}' > score.log

rm score.temp
