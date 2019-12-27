#! /system/bin/sh
test_time=$1
if [ -z $test_time ]
then
	test_time=60
	echo "Warning: Test time is not specified. Set test time as 60s"
else
	echo "Set test time: $test_time s"
fi

device=`getprop ro.build.product`
init_date=`date +%s`
if [ "$device" = "pxa1928ff" ] || [ "$device" = "pxa1928dkb" ]
then
	echo "=========Thermal Cap[$device]=========="
	echo "time temp CPU0 Core_num GC2D GC3D DDR"
	while [ "$_time" -ne "$test_time" ]
	do
		_current_time=`date +%s`
		_time=$(($_current_time-$init_date))
		#_temp_vpu=`cat /sys/class/thermal/thermal_zone1/temp`
		#_temp_cpu=`cat /sys/class/thermal/thermal_zone2/temp`
		#_temp_gc=`cat /sys/class/thermal/thermal_zone3/temp`
		_temp_max=`cat /sys/class/thermal/thermal_zone4/temp`
		_core=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		_online=`cat /sys/devices/system/cpu/cpunum_qos/cur_core_num`
		_gc2d=`cat /sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_freq`
		_gc3d=`cat /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq`
		_ddr=`cat /sys/class/devfreq/devfreq-ddr/cur_freq`

		#echo "$_time $_temp_cpu $_temp_vpu $_temp_gc $_temp_max $_core $_online $_gc2d $_gc3d $_ddr"
		echo "$_time $_temp_max $_core $_online $_gc2d $_gc3d $_ddr"
		sleep 1
	done
elif [ "$device" = "pxa1936dkb" ]
then
	echo "=========Thermal Cap[$device]=========="
	echo "time temp CPU0 CPU4 GC2D GC3D DDR"
	while [ "$_time" -ne "$test_time" ]
	do
		_current_time=`date +%s`
		_time=$(($_current_time-$init_date))
		_temp_max=`cat /sys/class/thermal/thermal_zone1/temp`
		_core0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		_core4=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
		_gc2d=`cat /sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_freq`
		_gc3d=`cat /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq`
		_ddr=`cat /sys/class/devfreq/devfreq-ddr/cur_freq`
		echo "$_time $_temp_max $_core0 $_core4 $_gc2d $_gc3d $_ddr"

	sleep 1
	done
elif [ "$device" = "pxa1936ff" ]
then
	echo "=========Thermal Cap[$device]=========="
	echo "time temp CPU0 CPU4 GC2D GC3D DDR"
	while [ "$_time" -ne "$test_time" ]
	do
		_current_time=`date +%s`
		_time=$(($_current_time-$init_date))
		_temp_max=`cat /sys/class/thermal/thermal_zone0/temp`
		_core0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		_core4=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
		_gc2d=`cat /sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_freq`
		_gc3d=`cat /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq`
		_ddr=`cat /sys/class/devfreq/devfreq-ddr/cur_freq`
#		echo "$_time $_temp_max $_core0 $_core4  $_ddr"
		echo "$_time $_temp_max $_core0 $_core4 $_gc2d $_gc3d $_ddr"

	sleep 1
	done
fi



