dateStart=`date +%s`
dateEnd=`date +%s`
interval=`busybox expr $dateEnd - $dateStart`
while [ $interval -lt $2 ]
do
    coremark $1
    dateEnd=`date +%s`
    interval=`busybox expr $dateEnd - $dateStart`
done
