#!/data/bin/busybox sh

export PATH=/data/bin/:$PATH

insmod /lib/modules/hwmap.ko

A_SSP1_SSCR0=d42a0c00
A_SSP1_SSCR1=d42a0c04
A_SSP1_SSPSP=d42a0c2c
A_SSP1_SSTSA=d42a0c30
A_SSP1_SSRSA=d42a0c34

V_SSP1_SSCR0=0x41d000bf
V_SSP1_SSCR1=0x00f01dc0
V_SSP1_SSPSP=0x02100004
V_SSP1_SSTSA=0x00000000
V_SSP1_SSRSA=0x00000000

_READ_VAL=

TEST_RESULT=0

hifi_start_playback()
{
    AUDIO_PLAYBACK_FILE=$1
    sh -c "am start -n com.android.music/com.android.music.MediaPlaybackActivity -d $AUDIO_PLAYBACK_FILE"  
}

hifi_stop_playback()
{
    sh -c " am force-stop com.android.music"
}

hifi_start_capture()
{
    AUDIO_CAPTURE_FILE=$1
    [ -f /sdcard/*.3gpp ] && rm /sdcard/*.3gpp
    sh -c "am start -n com.android.soundrecorder/com.android.soundrecorder.SoundRecorder"
    sh -c "input keyevent 19"
    sh -c "input keyevent 66"
}

hifi_stop_capture()
{
    [ -f /sdcard/*.3gpp ] && cp /sdcard/*.3gpp $AUDIO_CAPTURE_FILE
    sh -c "am force-stop com.android.soundrecorder"
}

read_reg_val()
{
    REG_ADDR=$1
    _READ_VAL=`hwacc r $REG_ADDR | busybox grep "Value read" | busybox awk '{print $8'}`
}

judge_reg_result()
{
    echo "++++++++++++++ SSP1 REG DUMP ++++++++++++++++"
    read_reg_val $A_SSP1_SSCR0
    echo " SSCR0:   Ept($V_SSP1_SSCR0)   Act($_READ_VAL)"
    if [ "$_READ_VAL" != "$V_SSP1_SSCR0" ]; then
        echo "*** [FAIL] Invalid register! ***"
	TEST_RESULT=1
    fi
    read_reg_val $A_SSP1_SSCR1
    echo " SSCR1:   Ept($V_SSP1_SSCR1)   Act($_READ_VAL)"
    if [ "$_READ_VAL" != "$V_SSP1_SSCR1" ]; then
        echo "*** [FAIL] Invalid register! ***"
	TEST_RESULT=1
    fi
    read_reg_val $A_SSP1_SSPSP
    echo " SSPSP:   Ept($V_SSP1_SSPSP)   Act($_READ_VAL)"
    if [ "$_READ_VAL" != "$V_SSP1_SSPSP" ]; then
        echo "*** [FAIL] Invalid register! ***"
	TEST_RESUILT=1
    fi
    read_reg_val $A_SSP1_SSTSA
    echo " SSTSA:   Ept($V_SSP1_SSTSA)   Act($_READ_VAL)"
    if [ "$_READ_VAL" != "$V_SSP1_SSTSA" ]; then
        echo "*** [FAIL] Invalid register! ***"
	TEST_RESULT=1
    fi
    read_reg_val $A_SSP1_SSRSA
    echo " SSRSA:   Ept($V_SSP1_SSRSA)   Act($_READ_VAL)"
    if [ "$_READ_VAL" != "$V_SSP1_SSRSA" ]; then
        echo "*** [FAIL] Invalid register! ***"
	TEST_RESULT=1
    fi
    echo "+++++++++++++++++++++++++++++++++++++++++++++"
}

set_cpu_freq()
{
    ppd_cmd 5 manual
    echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo $1 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
    echo "Set core freq to: $1 "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
}


#if [ "$#" != "3" ]; then
#    echo "Usage: *.sh [playback] [capture] [duration]"
#    exit 1
#fi

PLAYBACK=0
CAPTURE=1
DURATION=55

#set_cpu_freq 312000


if [ "$PLAYBACK" == "1" ]; then
    hifi_start_playback ./stereo-long.wav
fi
if [ "$CAPTURE" == "1" ]; then

    busybox pkill com.android.soundrecorder

    hifi_start_capture ./RECORD.3gpp
fi

date_before=`date +%s`
let "date_after=date_before+DURATION"
while [ $date_before -le $date_after ]
do
    sleep 1
    judge_reg_result
    cat /sys/kernel/debug/pxa/dvfs/voltage
    echo ""
    date_before=`date +%s`

	if [ $TEST_RESULT -ne 0 ];then
		echo "SSP register is invalid,please check the logs!"
		break;
	fi

done

if [ "$PLAYBACK" == "1" ]; then
    hifi_stop_playback
fi
if [ "$CAPTURE" == "1" ]; then
    hifi_stop_capture
fi


exit $TEST_RESULT
