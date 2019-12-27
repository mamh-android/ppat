#!/bin/bash
########################################################################################
########################################################################################
#variables
GIT_DIR=/git/dev_code/mrvl-3.10				##git dir for kernel source
GIT_BRANCH=helan2_vmin_0208				## kernel branch for vmin
GIT_DIR_WC=/git/ATD_testsuite/				##git dir for worst case
REL_DIR_BASE=/share/vmin/1u88/
TOOL_CHAIN_DIR=~/bin/arm-eabi-4.7/bin
UBOOT_GIT_DIR=/git/dev_code/uboot/uboot			#uboot git
UBOOT_GIT_BRANCH=helan2_vmin_0331			#uboot branch
########################################################################################
__SCRIPT_VERSION="2.1.0"
########################################################################################
export PATH=$TOOL_CHAIN_DIR:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-eabi-
########################################################################################
check_code_base()
{
	TODAY=`date +%m%d`
	_GIT_DIR=$1
	_GIT_BRANCH=$2

	if [ -f $_GIT_DIR/git.base ];then
		BASE_COMMIT_DESC=`cat $_GIT_DIR/git.base`
		read BASE_COMMIT < $_GIT_DIR/git.base
		BASE_COMMIT=`echo $BASE_COMMIT | cut -d ' ' -f 2`
	else
		echo "ERROR: no git base infomation, exited now"
		return 1
	fi

	cd $_GIT_DIR && git checkout $_GIT_BRANCH && cd -
	if [ $? -ne 0 ];then
		echo "cannot checkout branch $_GIT_BRANCH";
		return 1
	fi
}
########################################################################################
banner()
{
echo "
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Marvell Vmin correlation test image builder script $__SCRIPT_VERSION          
%
%			For Helan2(PXA1U88) only 
%	
%		Kernel:  $GIT_DIR	$GIT_BRANCH
%		Uboot :  $UBOOT_GIT_DIR $UBOOT_GIT_BRANCH 
%	supported commands and usage:
%		1) bk	build kernel, and copy image to $REL_DIR_BASE/test_img/xxx
%		2) bu	build uboot, and copy image to $REL_DIR_BASE/test_img/xxx/uboot
%		3) bwc  build worst case, and copy test case to $REL_DIR_BASE/test_case/xxx
%		4) iwc  [case version] [adb serial id] install worst case to board
%
%	created and maintained by chengwei@marvell.com, 2014/3/31 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"
}
########################################################################################
make_build_folder()
{
	BUILD_ID=1;
	
	TODAY=`date +%m%d`
	if [ $1 = "WC" ];then
		REL_DIR=$REL_DIR_BASE/test_case/$TODAY;
	else
		REL_DIR=$REL_DIR_BASE/test_img/$TODAY;
	fi

	echo $REL_DIR	
	echo $BUILD_TYPE
	
	if [ $1 = "UBOOT" ];then
		echo aaa $BUILD_TYPE
		REL_DIR="$REL_DIR/uboot"
	fi
	echo $REL_DIR
	
	while [ 1 ] ;do
		if [ -d $REL_DIR ];then
			
			echo "$REL_DIR build exist, do you want to continue,Y/y to remove the build and contiue, N/n to exit,A/a to add additional build?";
			read input;
			if [ $input == "Y" -o $input == "y" ];then
				if [ $1 = "KERNEL" ];then
					rm -fr $REL_DIR/*.patch;
					rm -fr $REL_DIR/*.log;
					rm -fr $REL_DIR/readme;
					rm -fr $REL_DIR/vmlinux;
					rm -fr $REL_DIR/uImage;
					rm -fr $REL_DIR/boot.img; 
				else
					rm -fr $REL_DIR/*
				fi
				break;
			 fi

			 if [ $input == "N" -o $input == "n" ];then
			 	exit
			fi

   			  if [ $input == "A" -o $input == "a" ];then
				  REL_DIR="${REL_DIR}_${BUILD_ID}/"
				  let BUILD_ID=$BUILD_ID+1
			  fi
		  else
			  echo "release dir: $REL_DIR"
			  mkdir $REL_DIR
		  break
	  fi
     done

     BUILD_LOG=$REL_DIR/build.log
     README=$REL_DIR/readme 
}
########################################################################################
build_uimage()
{
	rm -fr $GIT_DIR/arch/arm/boot/uImage 2>&1 >/dev/null
	cd $GIT_DIR && make pxa1U88_defconfig && make uImage | tee -a $BUILD_LOG && cd -

	if [ ! -f "$GIT_DIR/arch/arm/boot/uImage" ];then
		echo "uImage build failed"
	else
		echo -e -n "mrvl-3.10 git, master branch, base commit id=$BASE_COMMIT\n\n\n $BASE_COMMIT_DESC\n" > $README
		cp $GIT_DIR/arch/arm/boot/uImage $REL_DIR/
		cp $GIT_DIR/vmlinux $REL_DIR/

		echo -e "\nPatch list:\n" >> $README
		cd $GIT_DIR && git format-patch $BASE_COMMIT -o $REL_DIR/ | tee -a $README && cd -
		cd $GIT_DIR && git diff > $REL_DIR/un-submit-changes.patch && cd -
	fi 
}
########################################################################################
##build simple_dvfc_mod.ko
build_simple_dvfc_mod()
{
	echo "make simple_dvfc_mod.ko ..."
	cd $GIT_DIR_WC/vmin/worst_case/src/ && rm -fr simple_dvfc_mod.ko && make simple_dvfc_mod_k310.ko \
	&& cp ./simple_dvfc_mod.ko $REL_DIR/ && cd -
}

########################################################################################
##build boot.img
create_boot_img()
{
	echo "Generating boot.img ..."
	mkbootimg --kernel $REL_DIR/uImage --ramdisk  $REL_DIR_BASE/test_img/android/ramdisk.img -o $REL_DIR/boot.img
	cp $REL_DIR_BASE/test_img/android/ramdisk.img $REL_DIR/
}
########################################################################################
add_info()
{
	echo "Please input additional infomation for this image:"
	echo "--------------------------------------" >> $README
	echo "change description:">> $README
	echo -e -n "input build info here>>"
	read add_info
	echo $add_info >> $README
}
########################################################################################
build_uboot()
{
	echo "Uboot build enter ... "
	#make the uboot
	cd $UBOOT_GIT_DIR && make helan2_dkb_config && make helan2_dkb  | tee -a $BUILD_LOG && cd -
	if [ $? -ne 0 ];then
		echo "uboot build failed!"
		return 
	fi

	mkdir -p $REL_DIR >/dev/null 2>&1
	cp $UBOOT_GIT_DIR/u-boot.bin $REL_DIR/


	echo -e "\nPatch list:\n" >> $README
	cd $UBOOT_GIT_DIR && git format-patch $BASE_COMMIT -o $REL_DIR/ | tee -a $README && cd -
	cd $UBOOT_GIT_DIR && git diff > $REL_DIR/un-submit-changes.patch	 && cd -

	echo "Uboot build done, leaving ..."	
}
########################################################################################
build_worst_case()
{
	echo "Worst case build enter ..."
	cd $GIT_DIR_WC/vmin/worst_case/src/ && make install | tee -a $BUILD_LOG && cd -
	
	cp -r $GIT_DIR_WC/result/vmin/worst_case/* $REL_DIR/

	echo "Worst case build done, leaving ..."	
}
########################################################################################
end()
{
	echo -e -n "\n--------------\n auto-generated by image build script $__SCRIPT_VERSION `date`\n" >> $README
	echo "done"
}
########################################################################################
bk()
{
	echo "kernel building, pls wait ... "
	banner
	check_code_base $GIT_DIR $GIT_BRANCH
	make_build_folder KERNEL
	build_uimage
	build_simple_dvfc_mod
	create_boot_img
	add_info
	end
}
bu()
{
	echo "uboot building, pls wait ..."
	banner
	check_code_base	$UBOOT_GIT_DIR $UBOOT_GIT_BRANCH
	make_build_folder UBOOT
	build_uboot
	add_info
	end	
}
bwc()
{
	echo "worst case building, pls wait ..."	
	banner
	make_build_folder WC
	build_worst_case
	end
}
iwc()
{
	echo "worst case install, pls wait ..."

	if [ $# -eq 2 ];then
		ADB_SERIAL="-s $2"
		echo "Your ADB device id: $1"
	else	 
		ADB_SERIAL=""
	fi


	wc_dir=$REL_DIR_BASE/test_case/$1
	data_dir=$REL_DIR_BASE/test_case/data/ 
	
	adb $ADB_SERIAL root

	echo "Now waiting for adb $ADB_SERIAL device ... "
	adb $ADB_SERIAL wait-for-device


	echo "install busybox ..."
	adb $ADB_SERIAL shell mkdir /data/bin/
	adb $ADB_SERIAL push $REL_DIR_BASE/test_env/busybox /data/bin/
	adb $ADB_SERIAL push $REL_DIR_BASE/test_env/env.sh /data/bin/

	adb $ADB_SERIAL shell /data/bin/env.sh
	adb $ADB_SERIAL push $REL_DIR_BASE/test_env/p.sh /data/bin/

	echo "remove power daemon && set power hinter service ..."
	adb $ADB_SERIAL remount
	adb $ADB_SERIAL shell mv /system/bin/powerdaemon /system/bin/powerdaemon.bak
	adb $ADB_SERIAL shell phs_cmd 5 manual


	echo "install worst case ..."
	adb $ADB_SERIAL shell mkdir /data/worst_case/
	adb $ADB_SERIAL push  $wc_dir/  /data/worst_case/
	adb $ADB_SERIAL shell chmod -R 777 /data/worst_case/*

	echo "install data ..."
	adb $ADB_SERIAL push $data_dir  /data/worst_case/
	adb $ADB_SERIAL push $data_dir/gc3d/sdcard /sdcard

	adb $ADB_SERIAL install  $wc_dir/gc3d/VivantePort3Activity_KK4.4_hacked.apk

	adb $ADB_SERIAL push ./readme.txt /data/worst_case/
}
########################################################################################
banner
