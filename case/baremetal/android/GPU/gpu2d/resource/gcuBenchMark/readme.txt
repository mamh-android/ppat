The gcuBenchMark application test the normal BLT operation and normal usage, 
such as 720p=>WVGA BLT with rotation, etc.

You can get the detailed information from the HLD_gcuBenchMark.doc.

If you want to use this application to get the performance data of libGCU,
you can read below information.

How to build this application?
1. check out the gcuBenchMark application into your build environment.
	$cd <android_dir>
	$. build/envsetup.sh
	$chooseproduct <your_product_name>
	$choosevariant <the same as what you chose previously>
	$mmm -B ../proj/android  or mmm -B ../proj/marvell_gnueabi (the directory you save the Android.mk)
	Note:
	If you want to build gcuBenchmark for full test, you can use above commands.	
    If you want to build gcuBenchmark for 2D Blit KPI test, you need to modify Android.mk firstly. 
	Just change "GCUBENCHMARK_KPI := false" to "GCUBENCHMARK_KPI := true", save the makefile and type "mmm -B ../proj/android  or mmm -B ../proj/marvell_gnueabi" again.
	 
How to run this application?
1. If you want to test the libGCU performance on linux platform, please do the following
    setps:
    A. Copy the testcode/libgcu/gcubenchmark/bin/linux folder to your linux platform.
    B. Run ./gcubenchmark in shell.
    C. Then, you can get the information printed by COM and also a Perf_result.csv
        file which recording the performance data below the result_log folder.
        
2. If you want to test the libGCU performance on Android platform, please do the following
    setps:
    A. Copy the testapp/android/gcuBenchMark folder to your Android platform. 
    B. Run "perl gcubench.pl" at your linux PC. 
	C. You need to select the test scope : "1" for all gcu benchmark test, "2" for 2D Blit KPI test.
    D. Then, you can get the information printed by COM,  test_log.txt, Perf_result_mmu.csv and Perf_result.csv
        file which recording the performance data below the gcuBenchmark_result folder.
        
If you have any questions and any requirements, please contact me with liling@marvell.com

