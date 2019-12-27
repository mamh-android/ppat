#!/data/bin/busybox sh

export PATH=/data/bin:$PATH

[ $# -ne 1 ] && exit 1
OP=$1
DUMP_FILE="/data/register.dump"
TMP_FILE="/tmp/.tmp_dump"
REG_LIST="PLL3CR APB_Spare3_reg PLL2CR APB_Spare2_reg FCCR PMU_CC_AP PMU_CC2_AP PMU_GC_CLK_RES_CTRL PMU_vpu_CLK_RES_CTRL PMU_CC_CP MCCR"

if [ "$ATD_HW_PF" = "HELAN" -o "$ATD_HW_PF" = "HELAN-LTE" -o "$ATD_HW_PF" = "HELAN2" ];then
REG_LIST="PLL3CR PLL2CR FCCR PMU_CC_AP PMU_CC2_AP PMU_GC_CLK_RES_CTRL PMU_GC_2D_CLK_RES_CTRL PMU_vpu_CLK_RES_CTRL PMU_CC_CP MCCR"
fi

if [ "$ATD_HW_PF" = "EDEN" ];then
REG_LIST="FCCR PMU_CC_AP PMU_GC_CLK_RES_CTRL PMU_GC_2D_CLK_RES_CTRL PMU_vpu_CLK_RES_CTRL PLL2CR PLL3CR PLL5CR COREAPSS_CLKCTRL COREAPSS_CFG APSS_MEM_CTRL MC_MEM_CTRL ISLD_VPU_CTRL ISLD_GC_CTRL ISLD_USB_CTRL ISLD_ISP_CTRL ISLD_AU_CTRL ISLD_LCD_CTRL ISLD_SP_CTRL MCCR"
fi

[ -f $TMP_FILE ] && rm $TMP_FILE

record_reg_name()
{
	for reg_name in $REG_LIST
	do
		echo -n "," >> $DUMP_FILE
		echo -n $reg_name >> $DUMP_FILE
	done
	# end this line with comma
	echo "," >> $DUMP_FILE
}

record_reg_value()
{
	echo 1 > /sys/simple_dvfc/reg_dump
	cat /sys/simple_dvfc/reg_dump > $TMP_FILE
	echo 0 > /sys/simple_dvfc/reg_dump

	for reg_name in $REG_LIST
	do
		reg_val=`cat $TMP_FILE | grep $reg_name | awk -F ":" '{print $2}' | awk -F " " '{print $1}'`
		echo -n "," >> $DUMP_FILE
		echo -n $reg_val >> $DUMP_FILE
	done
	# end this line with comma
	echo "," >> $DUMP_FILE
}

if [ $OP -eq 0 ];then
	[ -f $DUMP_FILE ] && rm $DUMP_FILE
	record_reg_name
	record_reg_value
elif [ $OP -eq 1 ];then
	record_reg_value
else
	echo "*ERROR* wrong parameter"
	echo "Usage: $0 < 0 | 1 >"
	echo "   - 0 : First time excute reg_dump, record both reg name and reg value"
	echo "   - 1 : Append reg value to same dump file for multiple-time dumps"
fi
#cat $DUMP_FILE
