export PATH=/data/bin/:$PATH
export ATD_HW_PF=ULC1
phs_cmd 5 manual
setprop persist.sys.dump.enable 1;
echo 1 > /sys/devices/system/cpu/hotplug/lock;
echo 1 > /sys/devices/system/cpu/cpu1/online;
echo 1 > /sys/devices/system/cpu/cpu2/online;
echo 1 > /sys/devices/system/cpu/cpu3/online;
svc power stayon true;
. /data/bin/p.sh;
phs_cmd 5 manual;
cg userspace;
dg userspace;
vg userspace;
gcg userspace;
gc2g userspace;
gsg userspace;
echo user_space > /sys/class/thermal/thermal_zone0/policy;
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

cd /sys/class/thermal/thermal_zone0/
echo 120000 > trip_point_0_temp
echo 121000 > trip_point_1_temp
echo 122000 > trip_point_2_temp
echo 123000 > trip_point_3_temp
echo 124000 > trip_point_4_temp
echo 125000 > trip_point_5_temp
cd -


cf 1248000;
df 528000;
gcf 705000;
gc2f 624000;
gsf 705000;
vf 528750;
vcc 1250000;
cf;
df;
gcf;
gc2f;
gsf;
vf;
vcc;
./wcc.sh 6
