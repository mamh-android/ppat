#!/system/bin/sh
i=0
while [ $i -lt 100 ]
do
    sendevent /sdcard/press_w.evt
    sleep 0.5
    let i=$i+1
done
