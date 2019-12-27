core_num=$1
core_num=4
i=0
while [ i -ne $1 ]
do
	cmd=`cpueater $i`

	result=`echo $cmd | busybox awk '{if($33 == "pid")print "OK"}'`
	echo $result
	if [ $result == "OK" ]
	then
		i=$(($i+1))
	fi
done
