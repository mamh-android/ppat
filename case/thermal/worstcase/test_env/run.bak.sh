export PATH=/data/bin/:$PATH
export ATD_HW_PF=ULC1
phs_cmd 5 manual
setprop persist.sys.dump.enable 1;
echo 1 > /sys/devices/system/cpu/hotplug/lock;
echo 1 > /sys/devices/system/cpu/cpu1/online;
echo 1 > /sys/devices/system/cpu/cpu2/online;
echo 1 > /sys/devices/system/cpu/cpu3/online;
echo userspace > /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_governor;
svc power stayon true;
. /data/bin/p.sh;
phs_cmd 5 manual;
cg userspace;
dg userspace;
#vg userspace;
#gcg userspace;
#gc2g userspace;
#echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
#echo 0 > /sys/class/devfreq/devfreq-ddr/polling_interval;
#echo 1 > /sys/class/devfreq/devfreq-ddr/device/disable_ddr_fc;
cd /data/worst_case;
insmod simple_dvfc_mod.ko;
input keyevent 82;

./wcc.sh 1
