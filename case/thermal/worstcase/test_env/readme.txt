[How to setup test env]

on PC:

	push every thing in this folder to board /data/worst_case/
on board:
	mkdir /data/bin/
	cp /data/worst_case/busybox /data/bin/
	cp /data/worst_case/env.sh /data/bin/
	/data/bin/env.sh


[How to run the test case]

on Board:

su
export PATH=/data/bin:$PATH
export ATD_HW_PF=EDEN

insmod simple_dvfc_mod.ko

. /data/bin/p.sh

./wcc.sh 10  #(10 is the case execution time, minutes)
