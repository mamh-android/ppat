#!/data/bin/busybox sh
############################################################
#	Vmin worst concurrency case
# 	Copyright (c)  2012 Marvell Corporation
############################################################

# global variables
TST_RET=0
TST_RST="PASS"
BUSYBOX="/data/bin/busybox"

export PATH=/data/bin:$PATH
export TOP_DIR=${PWD}
SRC_DIR=/data/mmc_src_dir
DST_DIR=/data/mmc_dst_dir
SD_DIR=/sdcard
MIN_CPUID=0
MAX_CPUID=3
if [ $ATD_HW_PF = HELAN3 ]; then
	MAX_CPUID=7
fi
MAX_CFG_NUM=5
CONFIG_FILE="wcc.cfg"
RST_FILE="wcc.xml"
CPU_TEMP_FILE="/tmp/cpu_temp.dat"
VPU_TEMP_FILE="/tmp/vpu_temp.dat"

# add platform support here
if [ "$ATD_HW_PF" = "EDEN" ];then
	if [ "$VL0_SCAN" = '1' ];then
	CONFIG_FILE="VL0_EDEN.cfg"
	else
	CONFIG_FILE="wcc_EDEN.cfg"
	fi
	VL_TBL="VL_EDEN.tbl"
	DFC_CLK_LIST="CORE DDR GC3D GC2D VPU_ENC VPU_DEC"
	DVC_COMP_LIST="CORE DDR GC3D GC2D VPU_ENC VPU_DEC"
elif [ "$ATD_HW_PF" = "HELAN2" ];then
	if [ "$VL0_SCAN" = '1' ];then
	CONFIG_FILE="VL0_HL2.cfg"
	else
	CONFIG_FILE="wcc_HL2.cfg"
	fi
	VL_TBL="VL_HL2.tbl"
	DFC_CLK_LIST="CORE DDR GC3D GC3D_SHADER GC2D VPU"
	DVC_COMP_LIST="CORE DDR GC3D GC3D_SHADER GC2D VPU"
elif [ "$ATD_HW_PF" = "HELAN_LTE" ];then
	if [ "$VL0_SCAN" = '1' ];then
	CONFIG_FILE="VL0_HL_LTE.cfg"
	else
	CONFIG_FILE="wcc_HL_LTE.cfg"
	fi
	VL_TBL="VL_HL_LTE.tbl"
	DFC_CLK_LIST="CORE DDR GC3D GC3D_SHADER GC2D VPU"
	DVC_COMP_LIST="CORE DDR GC3D GC3D_SHADER GC2D VPU"
elif [ "$ATD_HW_PF" = "ULC1" ];then
	CONFIG_FILE="wcc_ULC1.cfg" 
elif [ "$ATD_HW_PF" = "HELAN2" ];then
	CONFIG_FILE="wcc_HL2.cfg" 
elif [ "$ATD_HW_PF" = "HELAN" ];then
	CONFIG_FILE="wcc_HL.cfg"
elif [ "$ATD_HW_PF" = "EMEI" ];then
	CONFIG_FILE="wcc_EM.cfg"
fi

# define CONFIG_FILE for all platform
CONFIG_FILE=wcc_$ATD_HW_PF.cfg

# Debug print
DBG_LOG_DIR=/data/
CHIP_TEMP_LOG=$DBG_LOG_DIR/thermal_temp.log
GC_MEM_LOG=$DBG_LOG_DIR/gc_mem_usage.log
CLK_DUMP_LOG=$DBG_LOG_DIR/clk_vol_setting.log


CHIP_TEMP_MONITOR=1
GC_MEM_MONITOR=0
ENA_CLK_DUMP=1
DUMP_DC=1
RANDOM_FC=0

PID_LIST=""
LOG_LIST=""
CHD_P_LIST="com.marvell.vivanteport.tutorial3 com.marvell.graphics.mm07 gcubenchmark_android tmark appCoda7542Dec appCoda7542Enc mplayer-armv7a-neon-softvfp tel_at_client"
TST_LIST="CPU NEON VPU_DEC VPU_ENC GC2D GC3D DDR CP PS_CALL DXO MMC ISP SSP GPS"
APK_PACKAGE_LIST="VivantePort3Activity.apk"
COMP_NO_RUN=""

# Usage
usage()
{
	echo "======================================================="
	echo
	echo "Usage: $1 <test_duration> <test_config>"
	echo "	01: Duration (mintues)"
	echo "	02: Config (optional)"
	echo "		- 0: (default) static Vmin scan for all PPs"
	echo "		- 1: DFC Vmin scan within VL0"
	echo "		- 2: DFC Vmin scan within VL1"
	echo "		- 3: DFC Vmin scan within VL2"
	echo "		- 4: DFC Vmin scan within VL3"
	echo "		- 5: DFC Vmin scan based on current configured PP(Vmin shmoo only)"
	echo "	03: Comp Name List (optional)"
	echo "		\"CORE\""
	echo "		\"CORE DDR GC3D GC2D\""
	echo
	echo "======================================================="
	exit 1

}

if [ $# -eq 1 ];then
	TST_TIME=$1
	TST_CFG=0
elif [ $# -eq 2 ];then
	TST_TIME=$1
	TST_CFG=$2
elif [ $# -eq 3 ];then
	TST_TIME=$1
	TST_CFG=$2
	DFC_CLK_LIST=$3
else
	usage $0
fi

if [ $TST_CFG -gt $MAX_CFG_NUM ];then
	usage $0
fi

TST_SEC=$(($TST_TIME*60))
START_TIME=`date +%s`
END_TIME=$(($START_TIME+$TST_SEC))
############################################################
# Test Start
echo "########## Vmin Concurrency Test Start [$START_TIME] ###########"

#==========================================================
# function 0: get SD card device
#==========================================================
get_sd_device()
{
	# default sd node
	mmcblkpx=xxx

	MMC_DEVS=`ls /sys/block/ | grep mmcblk`
	for mmc in $MMC_DEVS
	do
		if [ -d /sys/block/$mmc ]
		then
			type=`cat /sys/block/$mmc/device/type 2> /dev/null`
			if [ "$type" = "SD" ]
			then
				# check partition number
				pn=`cat /sys/block/$mmc/uevent | $BUSYBOX grep NPARTS | $BUSYBOX awk -F "=" '{print $2}' 2>/dev/null`
				if [ "$pn" -ne "0" ];then
					# use partition 1 by default
					mmcblkpx="$mmc"p1
				else
					# use block device if no partition
					mmcblkpx="$mmc"
				fi
			fi
		fi
	done

	if [ -b /dev/block/$mmcblkpx ]
	then
		return "/dev/block/$mmcblkpx"
	else
		return ""
	fi
}

#==========================================================
# function 1: check SD mount
#==========================================================
check_sd()
{
if [ -d $SD_DIR ];then
	SD_MNT=`mount | awk '{print $3}' | grep "^/sdcard"`
	if [ -z "$SD_MNT" ];then
		NEED_MNT=1
	fi
else
	mount -o remount,rw /
	mkdir $SD_DIR
	NEED_MNT=1
fi

if [ $NEED_MNT -eq 1 ];then
	SD_DEV=get_sd_device
	if [ -n $SD_DEV ];then
		mount $SD_DEV $SD_DIR
	else
		echo "ERROR: cound not found SD card inserted !"
		exit 1
	fi
fi
}

#==========================================================
# function 2: setup test environment
#		1). clean XML log files if existed
#		2). clean MMC test data if existed
#		3). create test directories if not existed
#==========================================================
tst_setup()
{
	XML_FILE=`$BUSYBOX find . -name "*.xml"`
	if [ -n "$XML_FILE" ];then
		for xml_file in $XML_FILE
		do
			rm -r "$xml_file" > /dev/null 2>&1
		done
		sync
	fi

	if [ -d $SRC_DIR ];then
		rm -r $SRC_DIR/* > /dev/null 2>&1
		sync
	else
		mkdir $SRC_DIR
	fi
	if [ -d $DST_DIR ];then
		rm -r $DST_DIR/* > /dev/null 2>&1
		sync
	else
		mkdir $DST_DIR
	fi
}

#==========================================================
# function 3: Find all child processes by PPID
#==========================================================
get_child_pids()
{
	c_pid=$1
	while [ -n "${c_pid}" ]; do
		CHILD_PIDS=${c_pid}" "${CHILD_PIDS}
		c_pid_list=`ps | awk '{print $2" "$3}'| grep " ${c_pid}"| awk '{print $1}'`
		[ -z "${c_pid_list}" ] && return
		for i in ${c_pid_list}; do
			# avoid parent processes be endless recursed
			[ $c_pid -ne $i ] && get_child_pids $i
		done
	done
}

#==========================================================
# function 4: kill process running in background
#==========================================================
kill_process()
{
if false;then
	# kill 2nd-level child process created by 1st-level child process
	for pn in $CHD_P_LIST
	do
		cpid=`ps | grep "$pn" | awk '{print $2}'`
		[ -n "$cpid" ] && kill -9 $cpid
	done

	# kill 1st-level child process
	echo "PID LIST: $PID_LIST"
	for pid in $PID_LIST
	do
		alive=`ps | awk '{print $2}' | grep $pid`
		if [ -n "$alive" ];then
			kill -9 $pid
		fi
	done
else
	CUR_PID=$$
	get_child_pids $CUR_PID
	for kpid in $CHILD_PIDS
	do
		# Keep main process alive to generate final result
		[ "$kpid" -ne "$CUR_PID" ] && kill -9 "$kpid" 2>/dev/null
	done

	# kill processes of binaries to double assurance
	for pn in $CHD_P_LIST
	do
		cpid=`ps | grep "$pn" | awk '{print $2}'`
		[ -n "$cpid" ] && kill -9 "$cpid"
	done
	echo "All child processes are killed: $CHILD_PIDS"
fi
}

#==========================================================
# function 5: create process to run worst case
#==========================================================
run_test()
{
	local item=$1
	local cpuid=$2
	local pid=0

	if [ -z $cpuid ];then
		echo "[FAIL]: Test item: $item, Wrong CPUID to bind core to ! Please check wcc.cfg file"
		kill_process
		exit 255
	fi

	if [ $cpuid = "SCHD" ];then
		echo "$item test is not bind to specific core"
	elif [ $cpuid -gt $MAX_CPUID -o $cpuid -lt $MIN_CPUID ];then
		echo "[FAIL]: Test item: $item, CPUID $cpuid is not valid, should be within [$MIN_CPUID, $MAX_CPUID]"
		kill_process
		exit 255
	fi

	case $item in
	   CPU)
		#==========================================
		#	CPU CoreMark test
		#==========================================
		cd core && ./CPU_CoreMark_Test.sh $TST_SEC $cpuid &
		LOG_LIST="core/CPU_$cpuid.xml $LOG_LIST"
		;;
	   NEON)
		#==========================================
		#	NEON H264 decode test
		#==========================================
		#cd neon_h264_ipp && ./neon.sh $TST_SEC &
		#LOG_LIST="neon_h264_ipp/NEON.xml $LOG_LIST"
		cd neon_mpeg4_mplayer && ./NEON_MplayTest.sh $TST_SEC $cpuid &
		LOG_LIST="neon_mpeg4_mplayer/NEON_$cpuid.xml $LOG_LIST"
		;;
	   VPU_DEC)
		#==========================================
		#   VPU 1080p decode test
		#==========================================
		cd vpu_duplex && ./VPU_DecTest.sh $TST_SEC $cpuid &
		LOG_LIST="vpu_duplex/VPU_DEC.xml $LOG_LIST"
		;;
	   VPU_ENC)
		#==========================================
		#   VPU 720p encode test
		#==========================================
		cd vpu_duplex && ./VPU_EncTest.sh $TST_SEC $cpuid &
		LOG_LIST="vpu_duplex/VPU_ENC.xml $LOG_LIST"
		;;

	   GC2D)
		#==========================================
		#	GC 2D render test
		#==========================================
		cd gc2d && ./GC2D_GCUbmTest.sh $TST_SEC $cpuid &
		LOG_LIST="gc2d/GC2D.xml $LOG_LIST"
		;;
	   GC3D)
		#==========================================
		#	GC3D Texture 07 test
		#==========================================
		cd gc3d && ./GC3D_Texture7_Test.sh $TST_SEC $cpuid &
		LOG_LIST="gc3d/GC3D.xml $LOG_LIST"
		;;
	   DXO)
		#==========================================
		#	DxO FVTS test
		#==========================================
		cd dxo && ./DxO_CamCtrl_Test.sh $TST_SEC $cpuid &
		LOG_LIST="dxo/DXO.xml $LOG_LIST"
		;;
	   MMC)
		#==========================================
		#	SD/EMMC file copy test
		#==========================================
		cd storage && ./MMC_FileCopy_Test.sh $SRC_DIR $DST_DIR $TST_SEC 14 $cpuid &
		#cd storage && ./dd_test.sh $SRC_DIR $DST_DIR $TST_SEC &
		LOG_LIST="storage/MMC.xml $LOG_LIST"
		;;
	PS_CALL)
		#==========================================
		#	PS DATA CALL
		#==========================================
		cd ps_call && ./CP_DataCall_Test.sh $TST_SEC $cpuid &
		LOG_LIST="ps_call/ps_call.xml $LOG_LIST"
		;;
	   CP)
		#==========================================
		#	CP voice call test
		#==========================================
		cd cp && ./CP_VoiceCall_Test.sh $TST_SEC $cpuid &
		LOG_LIST="cp/CP.xml $LOG_LIST"
		;;
	   DDR)
		#==========================================
		#	DDR Memtest
		#==========================================
		cd ddr && ./DDR_Memtest.sh $TST_SEC $cpuid &
		LOG_LIST="ddr/DDR_$cpuid.xml $LOG_LIST"
		;;
	   ISP)
		#==========================================
		#	ISP camera test
		#==========================================
		cd isp && ./ISP_Camera_Test.sh $TST_SEC $cpuid &
		LOG_LIST="isp/ISP_$cpuid.xml $LOG_LIST"
		;;

	   SSP)
	   	#==========================================
		#	SSP audio test
		#==========================================
		cd ssp && ./SSP_Audio_Test.sh $TST_SEC $cpuid &
		LOG_LIST="ssp/SSP.xml $LOG_LIST"
		;;

	   GPS)
	   	#==========================================
		#	SSP audio test
		#==========================================
		cd gps && ./GPS_CM3_Test.sh $TST_SEC $cpuid &
		LOG_LIST="gps/GPS_$cpuid.xml $LOG_LIST"
		;;


	   *)
		echo "[FAIL] Error test component"
		TST_RET=128
		;;
	esac

	# track shell pid in PID_LIST to be killed when test time is up
	pid=$!
	PID_LIST="$pid $PID_LIST"

	cd $TOP_DIR
}

#==========================================================
# function 6: Debug print chip temperature via thermal sensor
#==========================================================
thermal_print()
{
	U_INTERVAL=$1

	[ -f $CHIP_TEMP_LOG ] && rm -r $CHIP_TEMP_LOG
	local CUR_DATE=`date +%s`
	local END_DATE=0
	let "END_DATE=$CUR_DATE+$TST_SEC"

	local init_date=`date +%s`

	local local_bin=`pwd`

	while [ $CUR_DATE -lt $END_DATE ]
	do
		_date=`$local_bin/udate $init_date`

		if [ "$ATD_HW_PF" = "EDEN" ]; then
			VPU_TEMP=`cat /sys/class/thermal/thermal_zone1/temp`
			CPU_TEMP=`cat /sys/class/thermal/thermal_zone2/temp`
			#GC_TEMP=`cat /sys/class/thermal/thermal_zone3/temp`
		elif [ "$ATD_HW_PF" = "HELAN_LTE" -o "$ATD_HW_PF" = "ULC1" ]; then
			CPU_TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
		else
			CPU_TEMP=`cat /sys/class/thermal/thermal_zone1/temp`
			echo $CPU_TEMP >> $CPU_TEMP_FILE
		fi

		_core_freq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`

		online_1=`cat /sys/devices/system/cpu/cpu1/online`
		online_2=`cat /sys/devices/system/cpu/cpu2/online`
		online_3=`cat /sys/devices/system/cpu/cpu3/online`
		let "_online=1+$online_1+$online_2+$online_3"

		if [ "$ATD_HW_PF" = "HELAN3" ]; then
			online_4=`cat /sys/devices/system/cpu/cpu4/online`
			online_5=`cat /sys/devices/system/cpu/cpu5/online`
			online_6=`cat /sys/devices/system/cpu/cpu6/online`
			online_7=`cat /sys/devices/system/cpu/cpu7/online`
			let "_online=$online_4+$online_5+$online_6+$online_7"
		fi

		echo -e "$_date\t$VPU_TEMP\t$CPU_TEMP\t$_core_freq\t$_online" >> $CHIP_TEMP_LOG

		busybox usleep $U_INTERVAL

		local NOW=`date +%s`
		echo "================== Thermal Temperature ================="
		echo
		echo "[$NOW] CPU_TEMP: $CPU_TEMP" 
		if [ "$ATD_HW_PF" = "EDEN" ];then
			echo "[$NOW] VPU_TEMP: $VPU_TEMP" 
			#echo "GC_TEMP: $GC_TEMP" 
		fi
		echo
		echo "================== Thermal Temperature ================="

		CUR_DATE=`date +%s`
	done
}

#==========================================================
# function 7: Debug print GC memory usage
#==========================================================
gc_mem_print()
{
	[ -f $GC_MEM_LOG ] && rm -r $GC_MEM_LOG
	local CUR_DATE=`date +%s`
	local END_DATE=0
	let "END_DATE=$CUR_DATE+$TST_SEC"
	while [ $CUR_DATE -lt $END_DATE ]
	do
		sleep 10
		cat /proc/driver/gc | tee -a $GC_MEM_LOG
		CUR_DATE=`date +%s`
	done
}

#==========================================================
# function 8: Debug print Core/DDR/GC/VPU clock setting
#==========================================================
clk_dbg_print()
{
	[ -f $CLK_DUMP_LOG ] && rm -r $CLK_DUMP_LOG
	local CUR_DATE=`date +%s`
	local END_DATE=0
	let "END_DATE=$CUR_DATE+$TST_SEC"
	while [ $CUR_DATE -lt $END_DATE ]
	do
		sleep 10
		CORE0_CLK=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
		if [ "$ATD_HW_PF" = "HELAN3" ];then
			CORE1_CLK=`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq`
		fi
		if [ "$ATD_HW_PF" = "EDEN" -o "$ATD_HW_PF" = "HELAN2" -o "$ATD_HW_PF" = "ULC1" -o "$ATD_HW_PF" = "HELAN3" ];then
			DDR_CLK=`cat /sys/class/devfreq/devfreq-ddr/device/ddr_freq | awk -F ":" '{print $2}'`
		else
			DDR_CLK=`cat /sys/devices/platform/devfreq-ddr/ddr_freq | awk -F ":" '{print $2}'`
		fi

		# voltage
		VCC_CORE=`cat /sys/simple_dvfc/vcc_core | awk -F ":" '{print $2}'`

		# GC3D clock rate
		GC3D_FCLK=`cat /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq`

		# GC2D clock rate
		GC2D_FCLK=`cat /sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_freq`

		# GCSH interface for HELAN3 and ULC1 platform
		if [ $ATD_HW_PF = HELAN3 -o $ATD_HW_PF = ULC1 ]; then
			GCSH_FCLK=`cat /sys/devices/platform/galcore/gpu/gpu2/gpufreq/scaling_cur_freq`
		fi

		# VPU clock rate
		if [ "$ATD_HW_PF" = "EDEN" ];then
			VPU_ENC_FCLK=`cat /sys/class/devfreq/devfreq-vpu.1/cur_freq`
			VPU_DEC_FCLK=`cat /sys/class/devfreq/devfreq-vpu.0/cur_freq`
		else
			VPU_FCLK=`cat /sys/class/devfreq/devfreq-vpu.0/cur_freq`
		fi

		local NOW=`date +%s`
		echo "[$NOW] L_CPU Freq: $CORE0_CLK" | tee -a $CLK_DUMP_LOG
		if [ "$ATD_HW_PF" = "HELAN3" ];then
			echo "[$NOW] B_CPU Freq: $CORE1_CLK" | tee -a $CLK_DUMP_LOG
		fi
		echo "[$NOW] DDR Freq: $DDR_CLK" | tee -a $CLK_DUMP_LOG
		echo "[$NOW] GC3D_FCLK: $GC3D_FCLK"| tee -a $CLK_DUMP_LOG
		if [ $ATD_HW_PF = HELAN3 -o $ATD_HW_PF = ULC1 ]; then
			echo "[$NOW] GCSH_FCLK: $GCSH_FCLK"| tee -a $CLK_DUMP_LOG
		fi
		echo "[$NOW] GC2D_FCLK: $GC2D_FCLK"| tee -a $CLK_DUMP_LOG

		if [ "$ATD_HW_PF" = "EDEN" ];then
			echo "[$NOW] VPU_ENC_FCLK: $VPU_ENC_FCLK" | tee -a $CLK_DUMP_LOG
			echo "[$NOW] VPU_DEC_FCLK: $VPU_DEC_FCLK" | tee -a $CLK_DUMP_LOG
		else
			echo "[$NOW] VPU_FCLK: $VPU_FCLK" | tee -a $CLK_DUMP_LOG
		fi
		echo "[$NOW] VCC_CORE: $VCC_CORE" | tee -a $CLK_DUMP_LOG

		if [ "$ATD_HW_PF" = "EDEN" ];then
		echo "================== PXA1928 SYSTEM SETTING  ================="
		echo
		cat /sys/kernel/debug/pxa1928_sysset/pxa1928_sysset
		echo
		echo "================== PXA1928 SYSTEM SETTING  ================="
		fi

		CUR_DATE=`date +%s`
	done
}

#==========================================================
# function 9: Generate Test result: wcc.xml
#==========================================================
gen_result()
{
	# collect error info in the main process
	if [ $TST_RET -ne 0 ];then
		TST_RST="FAIL"
	else
		TST_RST="PASS"
	fi

	# collect test result of each test component
	for logfile in $LOG_LIST
	do
		if [ -f $logfile ];then
			errno=`cat $logfile | awk -F ">" '/FAIL/{print $2}' | sed -n '1p' | awk -F "<" '{print $1}'`
			[ $errno -ne 0 ] && TST_RST="FAIL"
		fi
	done

	# generate wcc.xml based on each component's *.xml
	[ -f $RST_FILE ] && rm $RST_FILE
	touch $RST_FILE
	echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" >> $RST_FILE
	echo "<WCC_LOG>" >> $RST_FILE
	echo "<RESULT>$TST_RST</RESULT>" >> $RST_FILE
	for logfile in $LOG_LIST
	do
		if [ -f $logfile ];then
			cat $logfile >> $RST_FILE
		fi
	done
	echo "</WCC_LOG>" >> $RST_FILE
}

#==========================================================
# function 10: generate wcc.xml at regular intervals
#==========================================================
do_gen_rst()
{
	local interval=$1

	local CUR_DATE=`date +%s`
	local END_DATE=0
	let "END_DATE=$CUR_DATE+$TST_SEC"
	while [ $CUR_DATE -lt $END_DATE ]
	do
		sleep $interval
		gen_result
		CUR_DATE=`date +%s`
	done
}

#==========================================================
# function 11: Android APK install
#==========================================================
apk_install()
{
	APK_LIST=$1
	[ $# -ne 1 ] && return 1

	for APK_NAME in $APK_LIST
	do
		case "$APK_NAME" in
		"VivantePort3Activity.apk")
			APK_PATH="$TOP_DIR/gc3d"
			COM_NAME="com.marvell.vivanteport.tutorial3";;
		"3DMarkMobile07.apk")
			APK_PATH="$TOP_DIR/gc3d"
			COM_NAME="com.marvell.graphics.mm07";;
		*)
			echo "Error: invalid apk name"
			return 1
			;;
		esac

		/system/bin/sh -c "pm list packages" | grep "$COM_NAME" > /dev/null
		if [ $? -eq 0 ];then
			echo "$APK_NAME is already installed."
		else
			/system/bin/sh -c "pm install $APK_PATH/$APK_NAME"
			if [ $? -ne 0 ];then
				echo "install $APK_NAME failed."
				return 1
			fi
		fi
	done
}

#==========================================================
# function 12: get avaliable frequency list btw min and max
#==========================================================
CORE_FC_AVL="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
DDR_FC_AVL="/sys/class/devfreq/devfreq-ddr/available_frequencies"
GC3D_FC_AVL="/sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_available_freqs"
GC3DSH_FC_AVL="/sys/devices/platform/galcore/gpu/gpuSh/gpufreq/scaling_available_freqs"
GC2D_FC_AVL="/sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_available_freqs"
VPU_FC_AVL="/sys/class/devfreq/devfreq-vpu.0/available_freqs"
VPU_DEC_FC_AVL="/sys/class/devfreq/devfreq-vpu.0/available_frequencies"
VPU_ENC_FC_AVL="/sys/class/devfreq/devfreq-vpu.1/available_frequencies"

get_fc_index()
{
	local list=$1
	local element=$2
	local index=1
	local max_num=`echo $list | awk '{print NF}'`

	if [ "$element" -eq 0 ];then
		return 0;
	fi

	while [ $index -le $max_num ]
	do
		freq=`echo $list | awk '{print $'$index'}'`
		if [ "$element" = "$freq" ];then
			return $index
		fi
		index=$(($index+1))
	done

	echo "$element cannot be found from $list"
	return 255
}

FC_LIST=""
get_fc_list()
{
	local fc_comp=$1
	local min_freq=$2
	local max_freq=$3
	local GET_AVL_FREQS=""

	[ $# -ne 3 ] && return 1

	if [ "$min_freq" = "$max_freq" ];then
		FC_LIST=$min_freq
		echo "DEBUG: FC_LIST: $FC_LIST"
		return 0
	fi

	case $fc_comp in
		CORE)
			GET_AVL_FREQS="$CORE_FC_AVL"
			;;
		DDR)
			GET_AVL_FREQS="$DDR_FC_AVL"
			;;
		GC3D)
			GET_AVL_FREQS="$GC3D_FC_AVL"
			;;
		GC3D_SHADER)
			GET_AVL_FREQS="$GC3DSH_FC_AVL"
			;;
		GC2D)
			GET_AVL_FREQS="$GC2D_FC_AVL"
			;;
		VPU)
			GET_AVL_FREQS="$VPU_FC_AVL"
			;;
		VPU_ENC)
			GET_AVL_FREQS="$VPU_ENC_FC_AVL"
			;;
		VPU_DEC)
			GET_AVL_FREQS="$VPU_DEC_FC_AVL"
			;;
		*)
			echo "Error: invalid clock name for DFC"
			return 1
			;;
	esac

	avl_freqs=`cat $GET_AVL_FREQS`
	if [ -z "$avl_freqs" ];then
		echo "Error: failed to get available freqs for $fc_comp"
		return 1
	fi
	echo "DEBUG: [$fc_comp] avail_freq: $avl_freqs"
	get_fc_index "$avl_freqs" "$min_freq"
	MIN_FC_INDEX=$?
	get_fc_index "$avl_freqs" "$max_freq"
	MAX_FC_INDEX=$?
	echo "DEBUG: [$fc_comp] MIN_INDEX: $MIN_FC_INDEX, MAX_INDEX: $MAX_FC_INDEX"

	if [ "$MIN_FC_INDEX" -ne 255 -a "$MAX_FC_INDEX" -ne 255 -a "$MAX_FC_INDEX" -gt "$MIN_FC_INDEX" ];then
		# To select frequencies larger than Min and less/equal than/with Max --> (Min, Max]
		MIN_FC_INDEX=$(($MIN_FC_INDEX+1))
		FC_LIST=`echo $avl_freqs | $BUSYBOX cut -d " " -f "$MIN_FC_INDEX"-"$MAX_FC_INDEX"`
		echo "DEBUG: [$fc_comp] FC_LIST: $FC_LIST"
	fi
}

#==========================================================
# function 13: do DFC for CORE/DDR/GC3D/GC2D/VPU
#==========================================================
CORE_FC_SET="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"
CORE_FC_GET="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq"
DDR_FC_SET="/sys/class/devfreq/devfreq-ddr/device/ddr_freq"
GC3D_FC_SET="/sys/devices/platform/galcore/gpu/gpu0/gpufreq/userspace/customize_rate"
GC3D_FC_GET="/sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_freq"
GC3DSH_FC_SET="/sys/devices/platform/galcore/gpu/gpuSh/gpufreq/userspace/customize_rate"
GC3DSH_FC_GET="/sys/devices/platform/galcore/gpu/gpuSh/gpufreq/scaling_cur_freq"
GC2D_FC_SET="/sys/devices/platform/galcore/gpu/gpu1/gpufreq/userspace/customize_rate"
GC2D_FC_GET="/sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_freq"
if [ 1 -eq 0 ];then
VPU_FC_SET="/sys/devices/platform/simple_dvfc/simple_dvfc/vpu_fclk"
VPU_ENC_FC_SET="/sys/devices/platform/simple_dvfc/simple_dvfc/vpu_enc_fclk"
VPU_DEC_FC_SET="/sys/devices/platform/simple_dvfc/simple_dvfc/vpu_dec_fclk"
else
VPU_FC_SET="/sys/class/devfreq/devfreq-vpu.0/userspace/set_freq"
VPU_DEC_FC_SET="/sys/class/devfreq/devfreq-vpu.0/userspace/set_freq"
VPU_ENC_FC_SET="/sys/class/devfreq/devfreq-vpu.1/userspace/set_freq"
fi
VPU_FC_GET="/sys/class/devfreq/devfreq-vpu.0/cur_freq"
VPU_DEC_FC_GET="/sys/class/devfreq/devfreq-vpu.0/cur_freq"
VPU_ENC_FC_GET="/sys/class/devfreq/devfreq-vpu.1/cur_freq"
do_dfc()
{
	local dfc_comp=$1
	local freqs=$2
	local DFC_SET=""
	local DFC_GET=""
	[ $# -ne 2 ] && return 1

	local FREQ_NUM=`echo $freqs | awk -F " " '{print NF}'`
	echo "DEBUG: do_dfc: freq list is $freqs, number is $FREQ_NUM"

	case $dfc_comp in
		CORE)
			DFC_SET="$CORE_FC_SET"
			DFC_GET="$CORE_FC_GET"
			;;
		DDR)
			DFC_SET="$DDR_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		GC3D)
			DFC_SET="$GC3D_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		GC3D_SHADER)
			DFC_SET="$GC3DSH_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		GC2D)
			DFC_SET="$GC2D_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		VPU)
			DFC_SET="$VPU_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		VPU_ENC)
			DFC_SET="$VPU_ENC_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		VPU_DEC)
			DFC_SET="$VPU_DEC_FC_SET"
			DFC_GET="$DFC_SET"
			;;
		*)
			echo "Error: invalid clock name for DFC"
			return 1
			;;
	esac

	local CUR_DATE=`date +%s`
	local END_DATE=$(($CUR_DATE+$TST_SEC))
	while [ $CUR_DATE -lt $END_DATE ]
	do
		local index=1
		if [ "$RANDOM_FC" -eq 1 ];then
			local rand=$RANDOM
			index=`expr $rand % $FREQ_NUM + 1`
			set_freq=`echo $freqs | awk -F " " '{print $'$index'}'`
			echo "[$dfc_comp] set freq to  $set_freq"
			echo "$set_freq" > "$DFC_SET"
			cat "$DFC_GET"
		else
			while [ $index -le $FREQ_NUM ]
			do
				set_freq=`echo $freqs | awk -F " " '{print $'$index'}'`
				echo "[$dfc_comp] set freq to  $set_freq"
				echo "$set_freq" > "$DFC_SET"
				cat "$DFC_GET"
				index=$(($index+1))
			done
		fi
		CUR_DATE=`date +%s`
	done
}

switch_pp()
{
	local volt_level=$1
	[ $# -ne 1 ] && return 1

	for dvc_item in $DVC_COMP_LIST
	do
		setfreq=`cat $VL_TBL | grep "$dvc_item" | sed -n '1p' | awk -F "|" '{print $'$volt_level'}'`

		if [ -z "$setfreq" ];then
			echo "[$dvc_item] fail to get frequency for VL $volt_level"
			continue
		fi

		if [ "$setfreq" -eq 0 ];then
			COMP_NO_RUN="$dvc_item $COMP_NO_RUN"
			continue
		fi

		case $dvc_item in
		CORE)
			echo "$setfreq" > "$CORE_FC_SET"
			;;
		DDR)
			echo "$setfreq" > "$DDR_FC_SET"
			;;
		GC3D)
			echo "$setfreq" > "$GC3D_FC_SET"
			;;
		GC3D_SHADER)
			echo "$setfreq" > "$GC3DSH_FC_SET"
			;;
		GC2D)
			echo "$setfreq" > "$GC2D_FC_SET"
			;;
		VPU)
			echo "$setfreq" > "$VPU_FC_SET"
			;;
		VPU_ENC)
			echo "$setfreq" > "$VPU_ENC_FC_SET"
			;;
		VPU_DEC)
			echo "$setfreq" > "$VPU_DEC_FC_SET"
			;;
		*)
			echo "Error: invalid clock name for DFC"
			return 1
			;;
		esac
	done
}

#==================================================================
# function 14: Run table based DFC within a specific voltage level
#==================================================================
run_table_based_dfc()
{
	local DFC_COMP=$1
	local VL=$2

	[ $# -ne 2 ] && return 1

	MAX_FREQ=`cat $VL_TBL | grep "$DFC_COMP" | sed -n '1p' | awk -F "|" '{print $'$VL'}'`
	if [ -n "$MAX_FREQ" -a "$MAX_FREQ" != '0' ];then
		if [ "$VL" -gt 1 ];then
			VLL=$(($VL-1))
			MIN_FREQ=`cat $VL_TBL | grep "$DFC_COMP" | sed -n '1p' | awk -F "|" '{print $'$VLL'}'`
		else
			MIN_FREQ=0
		fi
		FC_LIST=""
		get_fc_list $DFC_COMP $MIN_FREQ $MAX_FREQ
		if [ -n "$FC_LIST" ];then
			echo "DEBUG: get_fc_list: $FC_LIST"
			do_dfc "$DFC_COMP" "$FC_LIST"
		else
			echo "FAIL to get FC_LIST for $DFC_COMP"
		fi
	fi
}

#==================================================================
# function 15: Run DFC based on current PP
#==================================================================
get_cur_freq()
{
	local comp_name=$1
	[ $# -ne 1 ] && return 1

	case $comp_name in
		CORE)
			cur_freq=`cat "$CORE_FC_GET"`
			;;
		DDR)
			cur_freq=`cat "$DDR_FC_SET" | awk -F ":" '{print $2}'`
			;;
		GC3D)
			cur_freq=`cat "$GC3D_FC_GET"`
			;;
		GC3D_SHADER)
			cur_freq=`cat "$GC3DSH_FC_GET"`
			;;
		GC2D)
			cur_freq=`cat "$GC2D_FC_GET"`
			;;
		VPU)
			cur_freq=`cat "$VPU_FC_GET"`
			;;
		VPU_ENC)
			cur_freq=`cat "$VPU_ENC_FC_GET"`
			;;
		VPU_DEC)
			cur_freq=`cat "$VPU_DEC_FC_GET"`
			;;
		*)
			echo "Error: invalid clock name [$comp_name] for DFC"
			return 1
			;;
	esac
}

get_vl_for_cur_pp()
{
	local vl_rqst=0
	for dvc_comp in $DVC_COMP_LIST
	do
		cur_freq=""
		get_cur_freq "$dvc_comp"
		if [ -z $cur_freq ];then
			echo "FAIL to get current frequency of $dvc_comp"
			return 0
		else
			echo "$dvc_comp: get current frequency is $cur_freq"
		fi

		# Get current VL request for current product point
		vl_index=1
		while [ $vl_index -le 4 ]
		do	
			VL_FREQ=`cat $VL_TBL | grep "$dvc_comp" | sed -n '1p' | awk -F "|" '{print $'$vl_index'}'`
			if [ $cur_freq -le $VL_FREQ ];then
				break
			fi
			vl_index=$(($vl_index+1))
		done
		echo "$dvc_comp: $cur_freq request VL $vl_index"
		if [ $vl_index -gt $vl_rqst ];then
			vl_rqst=$vl_index
		fi
	done

	if [ $vl_rqst -gt 0 ];then
		echo "Current Product Point will request VL $vl_rqst"
		return $vl_rqst
	else
		echo "FAIL to get current PP's voltage request"
		return 0
	fi
}

run_cur_freq_based_dfc()
{
	local DFC_COMP=$1
	local vl_rqst=$2

	[ $# -ne 2 ] && return 1

	# get current frequency of current component
	cur_freq=""
	get_cur_freq "$DFC_COMP"
	if [ -z $cur_freq ];then
		echo "FAIL to get current frequency of $DFC_COMP"
		return 1
	else
		echo "$DFC_COMP: get current frequency is $cur_freq"
	fi

	# Get available frequency list within current VL
	if [ "$vl_rqst" -gt 1 ];then
		vll_index=$(($vl_rqst-1))
		min_freq=`cat $VL_TBL | grep "$DFC_COMP" | sed -n '1p' | awk -F "|" '{print $'$vll_index'}'`
	else
		min_freq=0
	fi
	FC_LIST=""
	get_fc_list $DFC_COMP $min_freq $cur_freq
	if [ -n "$FC_LIST" ];then
		do_dfc "$DFC_COMP" "$FC_LIST"
	else
		echo "FAIL to get FC_LIST for $DFC_COMP"
	fi
}

#==========================================================
# function 16: Prepare DFC Vmin shmoo
#==========================================================
cpu_stay_online()
{
	echo 1 > /sys/devices/system/cpu/hotplug/lock
	N_CPU=`cat /sys/devices/system/cpu/present | awk -F "-" '{print $2}'`

	local CPUID=0
	while [ $CPUID -le $N_CPU ]
	do
		ON=`cat /sys/devices/system/cpu/cpu"$CPUID"/online`
		if [ $ON -eq 0 ];then
			echo 1 > /sys/devices/system/cpu/cpu"$CPUID"/online
		fi
		CPUID=$(($CPUID+1))
	done
}

TST_MODULE_NAME="simple_dvfc_mod"
module_install()
{
	if [ -f "$TOP_DIR"/"$TST_MODULE_NAME".ko ];then
		mod_exist=`lsmod | grep $TST_MODULE_NAME`
		if [ -z "$mod_exist" ];then
			insmod "$TOP_DIR"/"$TST_MODULE_NAME".ko
		else
			echo "Test Module: $TST_MODULE_NAME.ko was already installed!"
		fi
	else
		echo "[WARNNING] Test Module : $TOP_DIR/$TST_MODULE_NAME.ko NOT Found !!! [WARNNING]"
	fi
}


pre_dfc()
{
	cpu_stay_online
	echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo 0 > /sys/class/devfreq/devfreq-ddr/polling_interval
	echo 1 > /sys/class/devfreq/devfreq-ddr/device/disable_ddr_fc
	echo userspace > /sys/devices/platform/galcore/gpu/gpu0/gpufreq/scaling_cur_governor
	echo userspace > /sys/devices/platform/galcore/gpu/gpu1/gpufreq/scaling_cur_governor
	if [ "$ATD_HW_PF" = "HELAN_LTE" ];then
	echo userspace > /sys/devices/platform/galcore/gpu/gpuSh/gpufreq/scaling_cur_governor
	fi
	module_install
	/system/bin/sh -c "input keyevent 82"
	sleep 1
}

dfc_filter()
{
	local tst_item=$1

	[ $# -ne 1 ] && return 1

	if [ -n "$COMP_NO_RUN" ];then
		case $tst_item in
		CPU|NEON)
			stop=`echo $COMP_NO_RUN | grep CORE`
			;;
		VPU_DEC|VPU_ENC)
			stop=`echo $COMP_NO_RUN | grep VPU`
			;;
		CP|PS_CALL)
			stop=`echo $COMP_NO_RUN | grep CP`
			;;
		GC2D)
			stop=`echo $COMP_NO_RUN | grep GC2D`
			;;
		GC3D)
			stop=`echo $COMP_NO_RUN | grep GC3D`
			;;
		DDR)
			stop=`echo $COMP_NO_RUN | grep DDR`
			;;
		DXO)
			stop=`echo $COMP_NO_RUN | grep DXO`
			;;
		MMC)
			stop=`echo $COMP_NO_RUN | grep MMC`
			;;
		ISP)
			stop=`echo $COMP_NO_RUN | grep ISP`
			;;
		*)
			stop=""
			;;
		esac

		[ -n "$stop" ] && echo "$tst_item is filtered" && return 0
	fi

	return 1
}

add(){
	add1=$1
	add2=$2
	echo `awk ' { a='$add1' ; b='$add2' ; c=a+b ; printf ("%15d",c) } ' /data/awk_test`
}

div(){
	div1=$1
	div2=$2
	echo `awk ' { a='$div1' ; b='$div2' ; c=a/b ; printf ("%15d",c) } ' /data/awk_test`
}

get_max(){
	max1=$1
	max2=$2
	echo `awk ' { max3='$max1'>'$max2'?'$max1':'$max2' ; printf ("%15d",max3) } ' /data/awk_test`
}

get_min(){
	min1=$1
	min2=$2
	echo `awk ' { min3='$min1'<'$min2'?'$min1':'$min2' ; printf ("%15d",min3) } ' /data/awk_test`
}

get_max_min_avg()
{
	data_list=`cat $2`
	data_list=`echo $data_list`
	echo "$1: $data_list"

	num=`echo $data_list | awk -F " " '{print NF}'`
	max=`echo $data_list | awk '{print $1}'`
	min=`echo $data_list | awk '{print $1}'`
	sum=`echo $data_list | awk '{print $1}'`

	iter=2
	while [ $iter -le $num ]
	do
		value=`echo $data_list | awk '{print $'"$iter"'}'`
		MAX_DATA=`get_max $max $value`
		MIN_DATA=`get_min $min $value`
		sum=`add $sum $value`
		let iter=$iter+1
	done
	echo "SUM : $sum, num: $num"
	AVG_DATA=`div $sum $num`
}

print_thermal_temp()
{
	get_max_min_avg "CPU_TEMP" "$CPU_TEMP_FILE"
	echo "*****************************"
	echo "* Statical CPU Thermal Temp *"
	echo "*  -[AVG] $AVG_DATA         *"
	echo "*  -[MAX] $MAX_DATA         *"
	echo "*  -[MIN] $MIN_DATA         *"
	echo "*****************************"

	if [ "$ATD_HW_PF" = "EDEN" ];then
	get_max_min_avg "VPU_TEMP" "$VPU_TEMP_FILE"
	echo "*****************************"
	echo "* Statical VPU Thermal Temp *"
	echo "*  -[AVG] $AVG_DATA         *"
	echo "*  -[MAX] $MAX_DATA         *"
	echo "*  -[MIN] $MIN_DATA         *"
	echo "*****************************"
	fi
}

enable_dc_stat()
{
	if [ $ATD_HW_PF = "HELAN3" ]; then
	#	echo $1 > /sys/kernel/debug/pxa/stat/clst0_dc_stat
	#	echo $1 > /sys/kernel/debug/pxa/stat/clst1_dc_stat
		echo $1 > /sys/kernel/debug/pxa/stat/cpu_dc_stat
	else
		echo $1 > /sys/kernel/debug/pxa/stat/cpu_dc_stat
	fi
	echo $1 > /sys/kernel/debug/pxa/stat/ddr_dc_stat
	echo $1 > /sys/kernel/debug/pxa/stat/gc2d_core0_dc_stat
	echo $1 > /sys/kernel/debug/pxa/stat/gc3d_core0_dc_stat
	echo $1 > /sys/kernel/debug/pxa/stat/gcsh_core0_dc_stat
	
	if [ $ATD_HW_PF = "EDEN" ]; then
		echo $1 > /sys/kernel/debug/pxa/stat/vpu_enc_dc_stat
		echo $1 > /sys/kernel/debug/pxa/stat/vpu_dec_dc_stat
	else
		echo $1 > /sys/kernel/debug/pxa/stat/vpu_dc_stat
	fi
}

dump_dc_stat()
{
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		CPU Duty Cycle			*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
	#cat /sys/kernel/debug/pxa/stat/clst0_dc_stat
	cat /sys/kernel/debug/pxa/stat/cpu_dc_stat
	#cat /sys/kernel/debug/pxa/stat/clst1_dc_stat
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		DDR Duty Cycle			*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
	cat /sys/kernel/debug/pxa/stat/ddr_dc_stat
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		GC2D Duty Cycle			*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
	cat /sys/kernel/debug/pxa/stat/gc2d_core0_dc_stat
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		GC3D Duty Cycle			*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
	cat /sys/kernel/debug/pxa/stat/gc3d_core0_dc_stat
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		GCSH Duty Cycle			*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
	cat /sys/kernel/debug/pxa/stat/gcsh_core0_dc_stat
	if [ $ATD_HW_PF = "EDEN" ]; then
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		VPU Dec Duty Cycle		*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
		cat /sys/kernel/debug/pxa/stat/vpu_dec_dc_stat
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		VPU Enc Duty Cycle		*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
		cat /sys/kernel/debug/pxa/stat/vpu_enc_dc_stat
	else
	echo "******************************************"
	echo "*						*"
	echo "*						*"
	echo "*		VPU Duty Cycle		*"
	echo "*						*"
	echo "*						*"
	echo "******************************************"
		cat /sys/kernel/debug/pxa/stat/vpu_dc_stat
	fi
}


#===========================================================
# preparition:
#	1. create test directories
#	2. clean log files
#===========================================================
tst_setup
apk_install $APK_PACKAGE_LIST

#===========================================================
# Start statistic process :
#	1. print & record CPU0/1 usage
#	2. xxx
#===========================================================
./cpu_usage.sh $TST_SEC &
if [ $CHIP_TEMP_MONITOR -eq 1 ];then
	[ -f $CPU_TEMP_FILE ] && rm $CPU_TEMP_FILE
	[ -f $VPU_TEMP_FILE ] && rm $VPU_TEMP_FILE
	thermal_print 500000 &
fi
if [ $GC_MEM_MONITOR -eq 1 ];then
	gc_mem_print &
fi
if [ $ENA_CLK_DUMP -eq 1 ];then
	clk_dbg_print &
fi
if [ $DUMP_DC -eq 1 ];then
	enable_dc_stat 1
fi

###for wcc.sh easy debugging
trap "kill_process;$BUSYBOX pkill busybox" SIGINT

#===========================================================
# main(): Start Test
#===========================================================
# Run DFC
if [ "$TST_CFG" -gt 0 -a "$TST_CFG" -le $MAX_CFG_NUM ];then
	if [ -f "$VL_TBL" ];then
		# DFC preparation
		pre_dfc
		echo "[$DFC_CLK_LIST] is selected to do DFC"
		if [ "$TST_CFG" -eq 5 ];then
		# DFC Vmin shmoo based on configured PP's frequency
			# get current PP's VL request
			get_vl_for_cur_pp
			vl_request=$?
			if [ "$vl_request" -ge 1 ];then
				for clk in $DFC_CLK_LIST
				do
					run_cur_freq_based_dfc $clk $vl_request &
				done			
			else
				echo "Current PP requests VL $vl_request is not valid, should be [1, 2, 3, 4]"
			fi
		else
		# DFC Vmin shmoo based on voltage level table and input VL selection
			# switch to target product point before DFC test
			switch_pp $TST_CFG
			for clk in $DFC_CLK_LIST
			do
				run_table_based_dfc $clk $TST_CFG &
			done
		fi
	else
		echo "Voltage level table: $VL_TBL not found, only do static Vmin shmoo"
	fi
fi

EARLY_SUSPEND_STATE=0
for TST_ITEM in $TST_LIST
do
	# For DFC on VL0, some components (GC2D/GC3D/VPU) should be power off, no need to run workload
	if dfc_filter $TST_ITEM;then
		echo "*** [$TST_ITEM] *** is filtered by VL0 DFC, will not run workload"
		continue
	fi

	RUN=`cat $CONFIG_FILE | grep "\<$TST_ITEM\>" | awk '{print $2}'`
	CPUID_LIST=`cat $CONFIG_FILE | grep "\<$TST_ITEM\>" | awk '{print $3}'`
	COPIES=1

	# This part is used to parse Environment Variable set by Vmin host controller
	# In order to totally shutoff DVC component, the corresponding test load should not be launched
	# if environment variable is set to 0, it means this DVC component should be shutoff, so that we 
	# will bypass run_test of this component. If GC2D/GC3D is bypassed, we should call powerutil
	# to let Android enter early suspend to disable Android services' impact to wakeup GC2D/3D
	if [ $RUN -ge 1 ];then
		case $TST_ITEM in
			"CPU")
				clk_name="CORE_CLK"
				eval clk_name='$'$clk_name
				;;
			"DDR")
				clk_name="DDR_CLK"
				eval clk_name='$'$clk_name
				;;
			"GC3D")
				clk_name="GC3D_FCLK"
				eval clk_name='$'$clk_name
				;;
			"GC2D")
				clk_name="GC2D_FCLK"
				eval clk_name='$'$clk_name
				;;
			"VPU_ENC")
				clk_name="VPU_ENC_FCLK"
				eval clk_name='$'$clk_name
				;;
			"VPU_DEC")
				clk_name="VPU_DEC_FCLK"
				eval clk_name='$'$clk_name
				;;
			*)
				clk_name="$TST_ITEM""_CLK"
				eval clk_name='$'$clk_name
				;;
		esac
		# remove the test load if $COMP_CLK=0 variable is set
		if [ -n "$clk_name" -a "$clk_name" -eq 0 ];then
			echo "$TST_ITEM is bypassed *******************************"
			if [ "$TST_ITEM" = "GC2D" -o "$TST_ITEM" = "GC3D" ];then
				if [ "$EARLY_SUSPEND_STATE" -eq 0 ];then
					echo "System entering Early Suspend State ***************"
					./power_util 3
					EARLY_SUSPEND_STATE=1
				fi
			fi
			continue
		fi

		while [ $COPIES -le $RUN ]
		do
			CPUID=`echo $CPUID_LIST | awk -F "," '{print $'$COPIES'}'`
			run_test $TST_ITEM $CPUID
			COPIES=$(($COPIES+1))
		done
	fi
done

#===========================================================
# main thread to generate wcc.xml every 20s
#===========================================================
do_gen_rst 10

#===========================================================
# kill un-finished child processes when test time is up
#===========================================================
CUR_TIME=`date +%s`
if [ $CUR_TIME -lt $END_TIME ];then
	diff=$END_TIME-$CUR_TIME+5
	sleep $diff
fi
kill_process

echo "START:$START_TIME, CUR:$CUR_TIME"

if [ $DUMP_DC -eq 1 ];then
	enable_dc_stat 0
	dump_dc_stat
fi

if [ $CHIP_TEMP_MONITOR -eq 1 ];then
	echo "xxx" > /data/awk_test
	print_thermal_temp
fi
#===========================================================
# Generate Final Test Result: wcc.xml
#===========================================================
gen_result

# Test Stop
echo "########## Vmin Concurrency Test Stop  ############"
echo ""
############################################################
# Exit
exit $TST_RET
