pid=`top -t -d 1 -n 1 | busybox grep $1 | busybox awk -F" " '{print $2}' | busybox sed -n 1p`
kill -9 $pid

