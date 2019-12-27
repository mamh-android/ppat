cd /sdcard/DKB_power_data 
# kill started  ftp ul/dl process
busybox cat pid.txt | while read line
do
    echo "kill $line"
    kill -9 $line
done
busybox rm pid.txt
exit
