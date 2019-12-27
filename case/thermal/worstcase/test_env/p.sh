#!/data/bin/busybox sh
##############################################################################################
# lib for clock control on Helan
_VER_MAJOR=2
_VER_MINOR=1
##############################################################################################
VCC=/sys/simple_dvfc/vcc_core
CORE_FREQ=/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
CORE_FREQ_R=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
CORE_FREQ_L=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
CORE_FREQ_MAX=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
CORE_FREQ_MAX_SET=/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
CORE_FREQ_MIN=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq

B_CORE_FREQ=/sys/devices/system/cpu/cpu4/cpufreq/scaling_setspeed
B_CORE_FREQ_R=/sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq
B_CORE_FREQ_L=/sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies
B_CORE_FREQ_MAX=/sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq
B_CORE_FREQ_MAX_SET=/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
B_CORE_FREQ_MIN=/sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq

CORE_GOV=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
CORE_GOV_L=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

B_CORE_GOV=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
B_CORE_GOV_L=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

VDDQ=/sys/simple_dvfc/vbuck3

DDR_FREQ=/sys/class/devfreq/devfreq-ddr/device/ddr_freq
DDR_FC_DIS=/sys/class/devfreq/devfreq-ddr/device/disable_ddr_fc
DDR_POLLING_INTERVAL=/sys/class/devfreq/devfreq-ddr/polling_interval
DDR_FREQ_L=/sys/class/devfreq/devfreq-ddr/available_frequencies
DDR_FREQ_MAX=/sys/class/devfreq/devfreq-ddr/max_freq
DDR_FREQ_MIN=/sys/class/devfreq/devfreq-ddr/min_freq
DDR_FREQ_GOVERNOR=/sys/class/devfreq/devfreq-ddr/governor
DDR_FREQ_GOVERNOR_L=/sys/class/devfreq/devfreq-ddr/available_governors
DDR_PROFILING=/sys/class/devfreq/devfreq-ddr/device/ddr_profiling

VPU_FREQ=/sys/class/devfreq/devfreq-vpu.0/cur_freq
VPU_FREQ_L=/sys/class/devfreq/devfreq-vpu.0/available_frequencies
VPU_FREQ_GOVERNOR_L=/sys/class/devfreq/devfreq-vpu.0/available_governors
VPU_FREQ_GOVERNOR=/sys/class/devfreq/devfreq-vpu.0/governor
VPU_FREQ_SET=/sys/class/devfreq/devfreq-vpu.0/userspace/set_freq

##gc
GC_DRV=/sys/devices/platform/galcore/gpu/

GC2D_FCLK=$GC_DRV/gpu1/gpufreq/scaling_cur_freq
GC2D_FCLK_L=$GC_DRV/gpu1/gpufreq/scaling_available_frequencies
GC2D_FCLK_GOV=$GC_DRV/gpu1/gpufreq/scaling_governor
GC2D_FCLK_GOV_L=$GC_DRV/gpu1/gpufreq/scaling_available_governors

GC2D_ACLK=/sys/simple_dvfc/gc2d_aclk

GPU_CLK_ALL=/sys/devices/platform/galcore/gpu/current_freq

GC_FCLK=$GC_DRV/gpu0/gpufreq/scaling_cur_freq
GC_FCLK_L=$GC_DRV/gpu0/gpufreq/scaling_available_frequencies
GC_FCLK_GOV=$GC_DRV/gpu0/gpufreq/scaling_governor
GC_FCLK_GOV_L=$GC_DRV/gpu0/gpufreq/scaling_available_governors


GC_SCLK=$GC_DRV/gpu2/gpufreq/scaling_cur_freq
GC_SCLK_L=$GC_DRV/gpu2/gpufreq/scaling_available_frequencies
GC_SCLK_GOV=$GC_DRV/gpu2/gpufreq/scaling_governor
GC_SCLK_SET=$GC_DRV/gpu2/gpufreq/userspace/customize_rate

GC_SCLK2=/sys//simple_dvfc/gc_sclk


#reg dump
REG_DUMP=/sys/simple_dvfc/reg_dump

#hotplug
HP_LOCK=/sys/devices/system/cpu/hotplug/lock
HP_C1=/sys/devices/system/cpu/cpu1/online
HP_C2=/sys/devices/system/cpu/cpu2/online
HP_C3=/sys/devices/system/cpu/cpu3/online

#DRO
DRO=/sys/kernel/debug/PM/DRO_Status

##thermal
THERMAL_TEMP=/sys/class/thermal/thermal_zone1/temp

#duty cycle 
DC_DIR=/sys/kernel/debug/pxa/stat/
##############################################################################################
MMP_CHIPID_PHYS=0xD4282C00
##############################################################################################
#PMIC setting
PMIC_POWER_ADDR=0x31
PMIC_POWER_VBUCK1_ADDR=0x3C
PMIC_POWER_VBUCK3_ADDR=0x41 
##############################################################################################
#video freq path check
if [ ! -f  $VPU_FREQ ];then
VPU_FREQ=/sys/devices/platform/devfreq-vpu.0/devfreq/devfreq-vpu.0/cur_freq
VPU_FREQ_AV=/sys/devices/platform/devfreq-vpu.0/devfreq/devfreq-vpu.0/available_frequencies
VPU_FREQ_SET=/sys/devices/platform/devfreq-vpu.0/devfreq/devfreq-vpu.0/userspace/set_freq 
fi

##ddr devfreq patch check
if [ ! -f $DDR_FREQ_L ];then
DDR_FREQ_L=/sys/class/devfreq/devfreq-ddr/available_frequencies
fi
##dvfs
DVFS=/sys/kernel/debug/pxa/dvfs/voltage
##############################################################################################
##check or set core voltage
vcc()
{


	if [ $# -eq 1 ];then
	  echo $1 > $VCC
	else
	  cat $VCC
		  fi
}

##check or set core freq
bcf()
{
	if [ $# -eq 1 ];then
	  echo $1 > $B_CORE_FREQ
	else
	  _CUR=`cat $B_CORE_FREQ_R`
		  _AVL=`cat $B_CORE_FREQ_L`

		  echo "current_core_freq:$_CUR"
		  echo "available freq:$_AVL"
		  fi 
}
##check or set core freq
cf()
{
	if [ $# -eq 1 ];then
	  echo $1 > $CORE_FREQ
	else
	  _CUR=`cat $CORE_FREQ_R`
	  _AVL=`cat $CORE_FREQ_L`

		  echo "current_core_freq:$_CUR"
		  echo "available freq:$_AVL"
		  fi 
}
#check or set the governor
bcg()
{
	if [ $# -eq 1 ];then
	  echo $1 > $B_CORE_GOV
	else
	  _CUR=`cat $B_CORE_GOV`
		  _AVL=`cat $B_CORE_GOV_L`

		  echo "current_governor:$_CUR"
		  echo "avaiable governor:$_AVL"
		  fi
}
#check or set the governor
cg()
{
	if [ $# -eq 1 ];then
	  echo $1 > $CORE_GOV
	else
	  _CUR=`cat $CORE_GOV`
		  _AVL=`cat $CORE_GOV_L`

		  echo "current_governor:$_CUR"
		  echo "avaiable governor:$_AVL"
		  fi
}
#get max freq for core
cmax()
{
	if [ $# -eq 1 ];then
	  echo $1 > $CORE_FREQ_MAX_SET
	else
	  cat $CORE_FREQ_MAX_SET
		  fi
}
cmin()
{
	cat $CORE_FREQ_MIN
}

cnum()
{
	on_line=$1

	if [ $# -ge 1 ]; then
		echo 0 > /sys/devices/system/cpu/cpu1/online
		echo 0 > /sys/devices/system/cpu/cpu2/online
		echo 0 > /sys/devices/system/cpu/cpu3/online
		echo 0 > /sys/devices/system/cpu/cpu4/online
		echo 0 > /sys/devices/system/cpu/cpu5/online
		echo 0 > /sys/devices/system/cpu/cpu6/online
		echo 0 > /sys/devices/system/cpu/cpu7/online

		index=1

		while [ $index -lt $on_line ];
		do
			echo 1 > /sys/devices/system/cpu/cpu$index/online 
			let "index=index+1"
		done

	else
		index=1
		total=1
		while [ $index -le 7 ];
		do
			online=`cat /sys/devices/system/cpu/cpu$index/online`
			let "total=total+online"

			let "index=index+1"
		done
		
		echo "current core num is $total"

	fi
}

#check or set the ddr freq
df()
{
	FC_DIS=`cat $DDR_FC_DIS`
		echo $FC_DIS | grep "= 1" >/dev/null
		if [ $? -ne 0 ];then
		  echo 1 > $DDR_FC_DIS
			  echo 0 > $DDR_POLLING_INTERVAL
			  fi

			  if [ $# -eq 1 ];then
				echo 0 > $DDR_POLLING_INTERVAL
					echo $1 > $DDR_FREQ
			  else
				cat $DDR_FREQ
					cat $DDR_FREQ_L
					fi
}
dmin()
{
	cat $DDR_FREQ_MIN
}
dmax()
{
	cat $DDR_FREQ_MAX
}
dg()
{
	if [ $# -eq 1 ];then
	  echo $1 > $DDR_FREQ_GOVERNOR
	else
	  cat $DDR_FREQ_GOVERNOR
		  cat $DDR_FREQ_GOVERNOR_L
		  fi	
}
dp()
{
	if [ $# -eq 0 ];then
	  echo "usage: dp 0 to stop and print out profiling
		  dp 1 to start profing
		  "	
		  elif [ $1 -eq 0 ];then
		  echo 0 > $DDR_PROFILING
		  cat $DDR_PROFILING
	else 	
	  echo 1 > $DDR_PROFILING
		  fi
}
#check core duty cycle
cs()
{
	if [ $# -eq 1 ];then
	  mount -t debugfs none /sys/kernel/debug >/dev/null 2>&1
		  echo 1 >/sys/kernel/debug/pxa/stat/cpu_dc_stat 
	else
	  echo 0 >/sys/kernel/debug/pxa/stat/cpu_dc_stat 
		  cat /sys/kernel/debug/pxa/stat/cpu_dc_stat 

		  fi
}

#//set vddq
#deprecated
__vddq()
{

	if [ $# -eq 1 ];
	then
		echo $1 > $VDDQ
	else
	  _VDDQ=`cat $VDDQ`
		  echo "$_VDDQ"
		  fi

}

##vpu
vf()
{
	if [ $# -eq 1 ];
	then
		echo $1 > $VPU_FREQ_SET
	else
	  _F=`cat $VPU_FREQ`
		  echo "VPU_FREQ:$_F"
		  _A=`cat $VPU_FREQ_L`
		  echo "Aviable:$_A"
		  fi
}
vg()
{
	if [ $# -eq 1 ]; then
	  echo 1 > $VPU_FREQ_GOVERNOR
	else
	  cat $VPU_FREQ_GOVERNOR
		  cat $VPU_FREQ_GOVERNOR_L
		  fi	
}
##gc2d
g2f()
{
	if [ $# -eq 1 ];
	then
		echo $1 > $GC2D_FCLK
	else
	  _F=`cat $GC2D_FCLK`
		  echo "$_F"
		  fi

}
g2a()
{
	if [ $# -eq 1 ];
	then
		echo $1 > $GC2D_ACLK
	else
	  _F=`cat $GC2D_ACLK`
		  echo "GC2D_ACLK:$_F"
		  fi
}
gc2f()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_DRV/gpu1/gpufreq/userspace/customize_rate
	else
	  _F=`cat $GC2D_FCLK_L`
		  echo "CUR=`cat $GC2D_FCLK`"
		  echo "GC2D_FCLK:$_F"
		  fi 
}
gc2g()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC2D_FCLK_GOV
	else
	  cat $GC2D_FCLK_GOV
		  fi
}
##gc3d
gc()
{
	cat $GPU_CLK_ALL
}
gf()
{
	if [ $# -eq 1 ];
	then
		echo $1 > $GC_FCLK
	else
	  _F=`cat $GC_FCLK`
		  echo "$_F"
		  cat $GC_FCLK_L
		  fi
}
ga()
{
	if [ $# -eq 1 ];
	then
		echo $1 > $GC_ACLK
	else
	  _F=`cat $GC_ACLK`
		  echo "GC_ACLK:$_F"
		  fi
}

gcf()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_DRV/gpu0/gpufreq/userspace/customize_rate
	else
	  _F=`cat $GC_FCLK_L`
		  echo "CUR=`cat $GC_FCLK`"
		  echo "GC_FCLK:$_F"
		  fi
}
gcg()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_FCLK_GOV
	else
	  cat $GC_FCLK_GOV
		  fi
}

#gcSh
gsf2()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_SCLK2
	else
	  cat $GC_SCLK2
		  fi
}
gsf()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_SCLK_SET
	else
	  _F=`cat $GC_SCLK`
		  echo "CUR:$_F"
		  echo "GC_SCLK:`cat $GC_SCLK_L`"
		  fi
}
gsg()
{
	if [ $# -eq 1 ];then
	  echo $1 > $GC_SCLK_GOV
	else
	  cat $GC_SCLK_GOV
		  fi
}
gs()
{
	if [ $# -eq 1 ];then
	  mount -t debugfs none /sys/kernel/debug >/dev/null 2>&1
		  echo 1 >/sys/kernel/debug/pxa/stat/gc_dc_stat 
	else
	  echo 0 >/sys/kernel/debug/pxa/stat/gc_dc_stat 
		  cat /sys/kernel/debug/pxa/stat/gc_dc_stat 

		  fi
}

##regdump
rd()
{
	echo 1 > $REG_DUMP
		cat $REG_DUMP
}

#hotplug
hpl()
{
	if [ $# -eq 1 ];then
	  echo 1 > $HP_LOCK
		  echo "hotplug locked"
	else
	  echo 0 > $HP_LOCK
		  echo "hotplug lock released"
		  fi
}

hpc1()
{
	if [ $# -eq 1 ];then
	  echo 1 > $HP_C1
		  echo "Core1 online"
	else
	  echo 0 > $HP_C1
		  echo "Core1 offline"
		  fi
}
hpc2()
{
	if [ $# -eq 1 ];then
	  echo 1 > $HP_C2
		  echo "Core2 online"
	else
	  echo 0 > $HP_C2
		  echo "Core2 offline"
		  fi
}
hpc3()
{
	if [ $# -eq 1 ];then
	  echo 1 > $HP_C3
		  echo "Core3 online"
	else
	  echo 0 > $HP_C3
		  echo "Core3 offline"
		  fi
}
hpc()
{
	if [ $# -eq 1 ];then
	  hpc1 1 
		  hpc2 1
		  hpc3 1
	else
	  hpc1
		  hpc2
		  hpc3
		  fi	
}
ci()
{
	cat /proc/cpuinfo
}
###############################################################################
info()
{
	vcc=`vcc | cut -d ' ' -f 2`
		core=`cat $CORE_FREQ_R`
		ddr=`cat  $DDR_FREQ | cut -d ' ' -f 5`
		gc=`cat $GC_FCLK | cut -d ' ' -f 3`
		gcs=`cat $GC_SCLK`
		g2d=`cat $GC2D_FCLK | cut -d ' ' -f 3`
		vpu=`cat $VPU_FREQ | cut -d ':' -f 2`

		echo "vcc@${vcc}_core@${core}_ddr@${ddr}_gc@${gc}_gcs@${gcs}_g2d@${g2d}_vpu@${vpu}"

}
###############################################################################
dvfs()
{
	cat $DVFS
}
###############################################################################
getvolt()
{
	_reg=$1
		steps=`i2cget -y -f 2 $PMIC_POWER_ADDR $_reg`
		let steps=$steps+0	
		volt=`echo "12.5 $steps * 600 + p" | /data/bin/busybox dc`
		echo "$volt"
}
setvolt()
{
	local _reg=$1
		local volt=$2
		local steps=`echo "$volt 600 - 12.5 / p" | /data/bin/busybox dc | /data/bin/busybox awk '{print int($1+0.5)}'` ##up round
		echo "send $steps to PMIC ..."
		i2cset -y -f 2 $PMIC_POWER_ADDR $_reg $steps		
}
##1st parameter is level
getvolt_dvc()  
{
	local _lvl=$1
		let _reg=$_lvl+$PMIC_POWER_VBUCK1_ADDR
		local _vol=`getvolt $_reg`
		echo "LV$_lvl $_vol mv"
}
###############################################################################
vcc2()
{
	if [ $# -eq 0 ];then
	  getvolt_dvc 0
		  getvolt_dvc 1
		  getvolt_dvc 2
		  getvolt_dvc 3
		  elif [ $# -eq 1 ];then
		  getvolt $1
		  elif [ $# -eq 2 ];then
		  let _reg=$1+$PMIC_POWER_VBUCK1_ADDR
		  setvolt $_reg $2
		  fi	
}
###############################################################################
vddq()
{
	if [ $# -eq 0 ]; then
	  local _vol=`getvolt $PMIC_POWER_VBUCK3_ADDR`
		  echo "vddq: $_vol mv"
	else
	  setvolt $PMIC_POWER_VBUCK3_ADDR $1
		  fi	
}
###############################################################################
dro()
{
	cat $DRO
}
chipid()
{
	hw.sh >/dev/null 2>&1
		_id=`hwacc r $MMP_CHIPID_PHYS | /data/bin/busybox grep "Value" | /data/bin/busybox cut -d ' ' -f 8`
		echo "Your chip id: $_id"
}

temp()
{
	local _TEMP=`cat $THERMAL_TEMP`
		echo "CURRENT TEMPERATURE:$_TEMP"	
}
###############################################################################
#duty_cycle stat
__dc_modules=""
dc()
{
	if [ $# -eq 0 ];then
	  echo "usage: dc 1 modules 
		  modules are: gc,gc2d, gc_shader, vpu,ddr,cpu,axi"
		  elif [ "$1" = "STOP" ];then
#then stop any duty cycle calculaton
		  for _mod in "cpu ddr axi gc gc2d gc_shader vpu";do
			echo 0 > $DC_DIR/${_mod}_dc_stat
				done
				elif [ $# -eq 1 ];then
				for _mod in $__dc_modules;do
				  echo 0 > $DC_DIR/${_mod}_dc_stat
					  cat $DC_DIR/${_mod}_dc_stat
					  done	
					  elif [ $# -gt 1 ];then
					  shift
					  __dc_modules=$*
					  for _mod in $__dc_modules;do
						echo 1 > $DC_DIR/${_mod}_dc_stat
							done
							echo "dc_stat on for $__dc_modules"
							fi	
}
###############################################################################
help()
{
	echo "
		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		**Marvell SVC helper script(p.sh) $_VER_MAJOR.$_VER_MINOR imported! **
		supported commands:
		vcc  --- vcc_main by simple_dvfc.ko
		vcc2 --- vcc_main get/set by PMIC I2C bus
		cf   --- core
		cg   --- core governor
		cmax--- core max freq
		cs   --- core duty cycle
		hpl  --- hotplug lock
		hpc1 --- core1 hotplug	
		hpc2 --- core1 hotplug	
		hpc3 --- core1 hotplug	
		hpc  --- core1/2/3 hotplug
		ci   --- cpuinfo
		df   --- ddr freq
		dg   --- ddr governor
		g2f  --- gc2d fclk
		g2a  --- gc2d aclk
		gf   --- gc fclk
		ga   --- gc aclk
		gsf  --- gc sclk
		gsg  --- gc sclk governor 
		rd   --- reg dump for PMU
		dvfs --- show DVFS status
		dro  --- show the DRO/profile info
		chipid --- show mmp_chipid
		temp --- show thermal temperature
		help --- show this info
		supported platforms:
		PXA1088	- Helan
		PXA1L88 - HelanLTE
		PXA1U88 - Helan2
		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		+created & maintained by chengwei@marvell.com                      +
		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		"
}

###############################################################################
help
###############################################################################
lsmod | grep simple_dvfc_mod  >/dev/null 2>&1
if [ $? -ne 0 ];then
insmod simple_dvfc_mod.ko
if [ $? -ne 0 ];then
echo "cannot insert simple_dvfc_mod.ko"
echo "below commands not supported:
vcc --- vcc_main
rd  --- reg dump for PMU
"

fi
fi
###############################################################################
