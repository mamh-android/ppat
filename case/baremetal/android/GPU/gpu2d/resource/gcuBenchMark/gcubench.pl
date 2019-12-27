###############################################################################################################
########             Get the real path which are used to store files for the certain test suites
###############################################################################################################
system "adb devices";
$TOP_DIR = $ENV{'PWD'};
print "current dir: $TOP_DIR\n";

system "svn --username=autotest --password=  export http://sh4-dt-020.marvell.com:8080/svn/qa_repo/trunk/testapp/android/gcuBenchMark";
system "mv gcuBenchMark/* ./; rm -r gcuBenchMark";
system "chmod -R 777 *";

my $DIR = "/data/gcubenchmark";
system "adb shell  mkdir $DIR";
system "adb shell 'cd $DIR; mkdir result_log'";

$BIN_DIR = 0;

print "--------------------------------------------------------------------------------------------------------\n";
print "Which test suite do you want to test(You can have only one choice, you can type 1 or 2\n";

print "1. full benchmark test\n";
print "2. 2D Blit KPI test\n";

$flag = <STDIN>;
chomp $flag;
if ($flag=~m/1/)
{
	print "run gcuBenchmark full test\n";
	$BIN_DIR = $TOP_DIR;
}
elsif ($flag=~m/2/)
{
	print "run gcuBenchmark 2D Blit KPI\n";
	$BIN_DIR = "$TOP_DIR/bin_KPI";
}
else
{
	print "Please choose one of 1/2, it is very important\nYou can have another try from the beginning\n\n";
	exit(0);
}

system "adb push $BIN_DIR/gcubenchmark_android $DIR";

system "adb shell 'cd $DIR; ./gcubenchmark_android'";
system "adb pull $DIR/result_log ./result_log";

system "adb shell rm -r $DIR";

#system "cd $TOP_DIR"
#system "ls | grep -v ^result | xargs rm -r"
