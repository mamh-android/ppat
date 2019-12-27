#!/data/bin/busybox sh
############################################################
#	Wrapper of utilities used by other shells
# 	Copyright (c)  2012 Marvell Corporation
############################################################

BUSYBOX="/data/bin/busybox"

# result
TST_LOOP=0
RT_ERR=0
MD5_ERR=0
LOG_ERR=0
FPS_MIN=999
FPS_MAX=0
FPS_AVG=0
FPS_DATA=""
DC=0

# DEBUG global varibles
DBG_DUMP=0
DBG_DUMP_ONCE=0
DBG_DUMP_DIR=/data

# TEST ENV
VMIN=0
PCLK=0
DCLK=0
GCFCLK=0
GCACLK=0
VPUFCLK=0
VPUACLK=0

#==========================================================
# function 1: bind process to specific core
#==========================================================
bind()
{
	local PID=$1
	local CPUID=$2

	$TOP_DIR/bind_core $PID $CPUID
	if [ $? -ne 0 ];then
		echo "[FAIL]: bind pid $PID to CPU $CPUID failed"
		return 1
	fi

	return 0
}

get_min_max_fps()
{
	if [ `echo "$1 $FPS_MAX" | awk '{if($1>$2) {print 0} else {print 1}}'` -eq 0 ];then
		FPS_MAX=$1
	fi
	if [ `echo "$1 $FPS_MIN" | awk '{if($1<$2) {print 0} else {print 1}}'` -eq 0 ];then
		FPS_MIN=$1
	fi
}

get_avg_fps()
{
	[ -z "$FPS_DATA" ] && return 1

	local SUM=0
	local NUM=0
	for i in $FPS_DATA
	do
		SUM=`echo "$SUM $i" | awk '{print $1+$2}'`
		let "NUM=$NUM+1"
	done

	FPS_AVG=`echo "$SUM $NUM" | awk '{print $1/$2}'`
}

get_duty_cycle()
{
	return 0
}

md5sums_check()
{
	[ $# -ne 2 ] && return 1
	local md5_src_file=$1
	local md5_dst_file=$2
	local lineno=1
	local err_cnt=0

	local tot_line=`$BUSYBOX wc -l $md5_src_file | $BUSYBOX awk '{print $1}'`
	while [ $lineno -le $tot_line ]
	do
		src_md5=`$BUSYBOX sed -n "$lineno""p" $md5_src_file`
		dst_md5=`$BUSYBOX sed -n "$lineno""p" $md5_dst_file`
		if [ "$src_md5" != "$dst_md5" ];then
			err_cnt=$(($err_cnt+1))
		fi
		lineno=$(($lineno+1))
	done

	if [ "$err_cnt" -eq 0 ];then
		echo "[***** PASS *****] NEON H264 decode MD5 checksum verified OK !"
		return 0
	else
		echo "[***** FAIL *****] NEON H264 decode MD5 checksum verified failed !"
		return 1	
	fi
}

md5sums_check2()
{
	[ $# -ne 2 ] && return 1
	local md5_src_file=$1
	local md5_dst_file=$2

	src_md5=`$BUSYBOX md5sum $md5_src_file | $BUSYBOX awk '{print $1}'`
	dst_md5=`$BUSYBOX md5sum $md5_dst_file | $BUSYBOX awk '{print $1}'`

	
	
	if [ "$src_md5" = "$dst_md5" ];then
		echo "[***** PASS *****] [CPU$CPUID]NEON H264 decode MD5 checksum verified OK !"
		return 0
	else
		echo "[***** FAIL *****] [CPU$CPUID]NEON H264 decode MD5 checksum verified failed !"
		echo "src=$src_md5"
		echo "dst=$dst_md5"
		return 1	
	fi
	
}


md5_checksum()
{
	[ $# -ne 3 ] && return 1
	local md5_file=$1
	local obj_file=$2
	local tst_obj=$3

	local SRC_MD5_VALUE=`$BUSYBOX cat $md5_file`
	[ -z "$SRC_MD5_VALUE" ] && echo "[***** FAIL *****] can't find md5 value in $md5_file" && return 1

	local DST_MD5_VALUE=`$BUSYBOX md5sum $obj_file | $BUSYBOX awk '{print $1}'`
	[ -z "$DST_MD5_VALUE" ] && echo "[***** FAIL *****] can't generate md5 value for $obj_file" && return 1

	if [ "$SRC_MD5_VALUE" = "$DST_MD5_VALUE" ];then
		echo "[***** PASS *****] $tst_obj : MD5 checksum verified OK !"
		return 0
	else
		echo "[***** FAIL *****] $tst_obj : MD5 checksum verified failed !"
		echo "MD5 value: $DST_MD5_VALUE, should be: $SRC_MD5_VALUE"
		return 1
	fi
}

reg_dump()
{
	echo 1 > /sys/simple_dvfc/reg_dump
	cat /sys/simple_dvfc/reg_dump
	echo 0 > /sys/simple_dvfc/reg_dump
}

# usage: get_result <module name> <cpu id>
# xmlgen usage:
# ./xmlgen -m <tst_module> -l <tst_loop> -e <err_type> <err_times> -fps <min> <max> <avg> -dc <duty_cycle> -cpu <core_id>
get_result()
{
	get_avg_fps
	if [ $# -eq 1 ];then
		# use CPUID 100 to indicate not bind special core
		$TOP_DIR/xmlgen -m $1 -l $TST_LOOP -e 0 $RT_ERR -e 1 $MD5_ERR -e 2 $LOG_ERR -fps $FPS_MIN $FPS_MAX $FPS_AVG -dc $DC -cpu 100
	elif [ $# -eq 2 ];then
		$TOP_DIR/xmlgen -m $1 -l $TST_LOOP -e 0 $RT_ERR -e 1 $MD5_ERR -e 2 $LOG_ERR -fps $FPS_MIN $FPS_MAX $FPS_AVG -dc $DC -cpu $2
	fi
}

# generate XML at regular interval
gen_xml()
{
	local TEST_SEC=$1
	local TEST_INT=$2
	local TEST_NAME=$3
	local CPUID=$4

	local CUR_DATE=`date +%s`
	local END_DATE=0
	let "END_DATE=$CUR_DATE+$TEST_SEC"
	while [ $CUR_DATE -lt $END_DATE ]
	do
		sleep $TEST_INT
		get_result $TEST_NAME $CPUID
		CUR_DATE=`date +%s`
	done
}

get_cur_tst_env()
{
	VMIN=`cat /sys/devices/platform/simple_dvfc/simple_dvfc/vcc_core | $BUSYBOX awk '{print $2}'`
	PCLK=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
	DCLK=`cat /sys/devices/platform/devfreq-ddr/ddr_freq | $BUSYBOX awk '{print $5}'`
	GCFCLK=`cat /sys/devices/platform/simple_dvfc/simple_dvfc/gc_fclk | $BUSYBOX awk '{print $3}'`
	GCACLK=`cat /sys/devices/platform/simple_dvfc/simple_dvfc/gc_aclk | $BUSYBOX awk '{print $3}'`
	VPUFCLK=`cat /sys/devices/platform/simple_dvfc/simple_dvfc/vpu_fclk | $BUSYBOX awk '{print $3}'`
	VPUACLK=`cat /sys/devices/platform/simple_dvfc/simple_dvfc/vpu_aclk | $BUSYBOX awk '{print $3}'`
}

# debug dump file
dbg_dump_file()
{
	local NAME=$1
	local DUMP_FILE=$2

	if [ $DBG_DUMP -eq 1 -a $DBG_DUMP_ONCE -eq 0 ];then
		get_cur_tst_env
		NOW=`date +%s`
		case $NAME in
		"VPU_ENC")
			cp -r $DUMP_FILE $DBG_DUMP_DIR/enc_720p_VMIN_"$VMIN"_PCLK_"$PCLK"_DCLK_"$DCLK"_GCFCLK_"$GCFCLK"_GCACLK_"$GCACLK"_VPUFCLK_"$VPUFCLK"_VPUACLK_"$VPUACLK"_"$NOW".h264
			;;
		"VPU_DEC")
			cp -r $DUMP_FILE $DBG_DUMP_DIR/dec_1080p_dump_VMIN_"$VMIN"_PCLK_"$PCLK"_DCLK_"$DCLK"_GCFCLK_"$GCFCLK"_GCACLK_"$GCACLK"_VPUFCLK_"$VPUFCLK"_VPUACLK_"$VPUACLK"_"$NOW".yuv
			;;
		"NEON")
			cp -r $DUMP_FILE $DBG_DUMP_DIR/neon_decode_dump_VMIN_"$VMIN"_PCLK_"$PCLK"_DCLK_"$DCLK"_GCFCLK_"$GCFCLK"_GCACLK_"$GCACLK"_VPUFCLK_"$VPUFCLK"_VPUACLK_"$VPUACLK"_"$NOW".yuv
			;;
		*)
			echo "dbg_dump_file: error test component to dump -- $NAME"
			;;
		esac
		DBG_DUMP_ONCE=1
	fi
}
