export PATH=/data/bin/:$PATH
export ATD_HW_PF=HELAN3
phs_cmd 5 manual
setprop persist.sys.dump.enable 1;

# temporally disable this since currently HELAN3 Platform does not support this
#echo 1 > /sys/devices/system/cpu/hotplug/lock;

echo 1 > /sys/devices/system/cpu/cpu1/online;
echo 1 > /sys/devices/system/cpu/cpu2/online;
echo 1 > /sys/devices/system/cpu/cpu3/online;

if [ $ATD_HW_PF = HELAN3 ]; then
	echo 1 > /sys/devices/system/cpu/cpu4/online;
	echo 1 > /sys/devices/system/cpu/cpu5/online;
	echo 1 > /sys/devices/system/cpu/cpu6/online;
	echo 1 > /sys/devices/system/cpu/cpu7/online;
fi

svc power stayon true;
. /data/bin/p.sh;
phs_cmd 5 manual;
cg userspace;
bcg userspace;
dg userspace;
vg userspace;
gcg userspace;
gc2g userspace;
gsg userspace;
echo user_space > /sys/class/thermal/thermal_zone1/policy;
echo 0 > /sys/class/devfreq/devfreq-ddr/polling_interval;
echo 1 > /sys/class/devfreq/devfreq-ddr/device/disable_ddr_fc;
cd /data/worst_case;
insmod simple_dvfc_mod.ko;
input keyevent 82;

echo "disable kernel touch boost"
echo 0 > /sys/kernel/debug/inputbst_enable

echo "Disable all idle state"
echo 0 > /sys/devices/system/cpu/cpu0/cpuidle/state0/disable
echo 0 > /sys/devices/system/cpu/cpu1/cpuidle/state0/disable
echo 0 > /sys/devices/system/cpu/cpu2/cpuidle/state0/disable
echo 0 > /sys/devices/system/cpu/cpu3/cpuidle/state0/disable

echo 0 > /sys/devices/system/cpu/cpu0/cpuidle/state1/disable
echo 0 > /sys/devices/system/cpu/cpu1/cpuidle/state1/disable
echo 0 > /sys/devices/system/cpu/cpu2/cpuidle/state1/disable
echo 0 > /sys/devices/system/cpu/cpu3/cpuidle/state1/disable

echo 0 > /sys/devices/system/cpu/cpu0/cpuidle/state2/disable
echo 0 > /sys/devices/system/cpu/cpu1/cpuidle/state2/disable
echo 0 > /sys/devices/system/cpu/cpu2/cpuidle/state2/disable
echo 0 > /sys/devices/system/cpu/cpu3/cpuidle/state2/disable

echo 0 > /sys/devices/system/cpu/cpu0/cpuidle/state3/disable
echo 0 > /sys/devices/system/cpu/cpu1/cpuidle/state3/disable
echo 0 > /sys/devices/system/cpu/cpu2/cpuidle/state3/disable
echo 0 > /sys/devices/system/cpu/cpu3/cpuidle/state3/disable

cat /sys/devices/system/cpu/cpu0/cpuidle/state0/disable
cat /sys/devices/system/cpu/cpu1/cpuidle/state0/disable
cat /sys/devices/system/cpu/cpu2/cpuidle/state0/disable
cat /sys/devices/system/cpu/cpu3/cpuidle/state0/disable

cat /sys/devices/system/cpu/cpu0/cpuidle/state1/disable
cat /sys/devices/system/cpu/cpu1/cpuidle/state1/disable
cat /sys/devices/system/cpu/cpu2/cpuidle/state1/disable
cat /sys/devices/system/cpu/cpu3/cpuidle/state1/disable

cat /sys/devices/system/cpu/cpu0/cpuidle/state2/disable
cat /sys/devices/system/cpu/cpu1/cpuidle/state2/disable
cat /sys/devices/system/cpu/cpu2/cpuidle/state2/disable
cat /sys/devices/system/cpu/cpu3/cpuidle/state2/disable

cat /sys/devices/system/cpu/cpu0/cpuidle/state3/disable
cat /sys/devices/system/cpu/cpu1/cpuidle/state3/disable
cat /sys/devices/system/cpu/cpu2/cpuidle/state3/disable
cat /sys/devices/system/cpu/cpu3/cpuidle/state3/disable

cd /sys/class/thermal/thermal_zone1/
echo 120000 > trip_point_0_temp
echo 115000 > trip_point_0_hyst
echo 121000 > trip_point_1_temp
echo 116000 > trip_point_1_hyst
echo 122000 > trip_point_2_temp
echo 117000 > trip_point_2_hyst
echo 123000 > trip_point_3_temp
echo 118000 > trip_point_3_hyst
echo 124000 > trip_point_4_temp
echo 119000 > trip_point_4_hyst
echo 125000 > trip_point_5_temp
echo 120000 > trip_point_5_hyst
cd -
