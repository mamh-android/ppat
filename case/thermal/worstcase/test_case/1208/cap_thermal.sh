#!/data/bin/busybox sh

init_date=`date +%s`

if [ $ATD_HW_PF = HELAN3 ]; then
	CORE_NUM=7
	echo -e "time\\tc_temp\\tcore0_freq\\tcore1_freq\\tgc_freq\\tcore_num\\tdvc\\tvcc_main"
else
	CORE_NUM=3
	echo -e "time\\tc_temp\\tcore_freq\\tgc_freq\\tcore_num\\tdvc\\tvcc_main"
fi

while [ 1 ]
do
	_date=`/data/udate $init_date`
	if [ $ATD_HW_PF = HELAN3 ]; then
		_temp=`cat /sys/class/thermal/thermal_zone1/temp`
		_core0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		_core1=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
	else		
		_temp=`cat /sys/class/thermal/thermal_zone0/temp`
		_core0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
	fi
	_gc=`cat /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq`
	
	_dvc=`cat /sys/simple_dvfc/dvc`
	#_ddr=`cat /sys/class/devfreq/devfreq-ddr/cur_freq`

	i=1;
	_online=1;

	while [ $i -le $CORE_NUM ] 
	do
		online_x=`cat /sys/devices/system/cpu/cpu"$i"/online`
		let "_online=_online+online_x"
		let "i=i+1"
	done
	if [ $ATD_HW_PF = HELAN3 ]; then
		echo  -e "$_date \\t $_temp $_core0 $_core1 $_gc \\t $_online \\t $_dvc"
	else
		echo  -e "$_date \\t $_temp $_core0 $_gc \\t $_online \\t $_dvc"
	fi
	busybox usleep 100000
done
