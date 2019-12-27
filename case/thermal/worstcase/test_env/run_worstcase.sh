#!/data/bin/busybox sh

export PATH=/data/bin/:$PATH
export ATD_HW_PF=$1

cd /data/worst_case

insmod simple_dvfc_mod.ko
./wcc.sh $2


