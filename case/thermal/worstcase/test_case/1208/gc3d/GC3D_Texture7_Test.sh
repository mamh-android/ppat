#!/data/bin/busybox sh

. ../wcc_util.sh

TST_SEC=$1
CPUID=$2

if [ ! -d /sdcard/vivante_data ];then
	cp -r sdcard/* /sdcard
fi



if [ ! -d /tmp/12 ];then
	mkdir /tmp/12
	cp -r /sdcard/vivante_data /tmp/12
	chmod 777 /tmp/12
	chmod 777 /tmp/12/vivante_data/
	chmod 777 /tmp/12/vivante_data/*
	chmod 777 /tmp/12/vivante_data/es2_tutorial3/*
fi


echo "***********  Start GC3D Texture7 test *************" 

/system/bin/sh -c "am start -n com.marvell.vivanteport.tutorial3/com.marvell.vivanteport.tutorial3.VivantePort3Activity"
#/system/bin/sh -c "am start -n com.marvell.vivanteport.tutorial4/com.marvell.vivanteport.tutorial4.VivantePort4Activity"

CPID=`ps | grep com.marvell.vivanteport.tutorial3 | awk '{print $2}'`
echo "GC3D PID : $CPID"

__loop=0
while [ -n $CPID ];do
	CPID=`ps | grep com.marvell.vivanteport.tutorial3 | awk '{print $2}'`
	if [ $__loop -gt 100 ];then
		echo "GC3D luanch failed,cannot find its process id!"
		RT_ERR=1
		get_result "GC3D" $CPUID
		break;
 	fi
	let __loopid=$__loopid+1
done

if [ $CPUID != "SCHD" ];then
		bind $CPID $CPUID
fi

sleep $TST_SEC

/system/bin/sh -c "input keyevent 4"
/system/bin/sh -c "input keyevent 4"
