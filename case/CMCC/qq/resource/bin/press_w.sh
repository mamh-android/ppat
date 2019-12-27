#!/system/bin/sh
i=0
while [ $i -lt 20 ]
do
    sendevent /sdcard/press_w.evt
    sleep 0.3
    let i=$i+1
done
sendevent /sdcard/send.evt
