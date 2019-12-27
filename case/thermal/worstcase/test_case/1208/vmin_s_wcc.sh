#!/data/bin/busybox sh
############################################################
#	Wrapper of Vmin worst concurrency case for LTK
# 	Copyright (c)  2013 Marvell Corporation
############################################################

WCC_DATA_PATH="vmin"
TST_DIR=${PWD}
TST_MODULE_NAME="simple_dvfc_mod"
TST_DATA_LIST="gc2d/result_log gc3d/sdcard neon_mpeg4_mplayer/Avatar_Blu-ray__DVD_Spot_640_360.mp4 vpu_duplex/720p.yuv vpu_duplex/1080p.h264, vpu_duplex/1080p_50f.yuv"

# Global Variable of Specific SoC Platform
if [ -z $ATD_HW_PF ];then
	echo "******* NOTICE: Set ATD_HW_PF to EMEI by default *******"
	export ATD_HW_PF="EMEI"
fi

# Global Variable of SD Card Mount Point
if [ -z $UTF_DATA_PATH ];then
	echo "******* NOTICE: Set UTF_DATA_PATH to /mnt/external_sdcard by default *******"
	export UTF_DATA_PATH="/mnt/external_sdcard"
fi

# Check existence of worst case test data
data_not_exist()
{
	need_update=0

	for data_file in $TST_DATA_LIST
	do
		if [ ! -e $TST_DIR/$data_file ];then
			need_update=1
			break
		fi
	done

	if [ $need_update -eq 1 ];then
		echo "Test data not existed, need install"
		return 0
	else
		echo "Test data already existed"
		return 1
	fi
}

# Install worst case test data
data_install()
{
	if [ -d $UTF_DATA_PATH ];then
		if [ -d $UTF_DATA_PATH/$WCC_DATA_PATH ];then
			echo "Copying test data from [$UTF_DATA_PATH/$WCC_DATA_PATH] to [$TST_DIR] ......"
			cp -r $UTF_DATA_PATH/$WCC_DATA_PATH/* $TST_DIR
			if [ $? -ne 0 ];then
				echo "<ERROR> Failed to copy test data from [$UTF_DATA_PATH/$WCC_DATA_PATH] to [$TST_DIR] <ERROR>"
				exit 1
			fi
			echo "... ... Test Data Copy Finished!"
		else
			echo "<ERROR> Worst Case Test Data Path $UTF_DATA_PATH/$WCC_DATA_PATH NOT FOUND <ERROR>"
			echo "[WARNING] Please confirm whether SD card with bsp_test_data was installed !!!"
			exit 1
		fi
	else
		echo "<ERROR> SD CARD Mount Point $UTF_DATA_PATH NOT found <ERROR>"
		echo "[WARNNING] Please confirm whether SD card with bsp_test_data was installed !!!"
		exit 1
	fi
}

# Configure all CPUs online
cpu_stay_online()
{
	echo 1 > /sys/devices/system/cpu/hotplug/lock
	N_CPU=`cat /sys/devices/system/cpu/present | awk -F "-" '{print $2}'`

	CPUID=0
	while [ $CPUID -le $N_CPU ]
	do
		ON=`cat /sys/devices/system/cpu/cpu"$CPUID"/online`
		if [ $ON -eq 0 ];then
			echo 1 > /sys/devices/system/cpu/cpu"$CPUID"/online
		fi
		CPUID=$(($CPUID+1))
	done
}

# install test module
module_install()
{
	if [ -f "$TST_DIR"/"$TST_MODULE_NAME".ko ];then
		mod_exist=`lsmod | grep $TST_MODULE_NAME`
		if [ -z "$mod_exist" ];then
			insmod "$TST_DIR"/"$TST_MODULE_NAME".ko
		else
			echo "Test Module: $TST_MODULE_NAME.ko was already installed!"
		fi
	else
		echo "[WARNNING] Test Module : $TST_DIR/$TST_MODULE_NAME.ko NOT Found !!! [WARNNING]"
	fi
}

# Preparing Test Environment for worst case
if data_not_exist;then
	data_install
fi
module_install
cpu_stay_online

# Call wcc.sh
./wcc.sh $1
