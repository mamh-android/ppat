#! /bin/bash
######## Configuration ########
LOG_FILE="app_launch_contact"
TEMP_LOG=$1
DEVICE=$2
TESTAPP="contacts"
##############################

# import public function
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE

# start log
echo "===========app launch contacts start==========="
sleep 2
RESULT=`date +%F-%H-%M-%S`
start_log ${RESULT}_${LOG_FILE}

# log parser
echo "===========parse log begin==========="
. ../../utils/log_parser_app_launch_contact.sh ../../log/${RESULT}_${LOG_FILE}.log ../../result/${RESULT}_${LOG_FILE}.txt $TESTAPP
echo "===========parse log end============="
echo ""

$ADB shell input keyevent 4
sleep 1
$ADB shell input keyevent 4
sleep 1
echo "===========end==========="
echo ""
echo ""
cat ../../result/${RESULT}_${LOG_FILE}.txt | awk '{ if($1 == "AVERAGE:"){print "'${LOG_FILE}'", int($2) }}' >  $TEMP_LOG
