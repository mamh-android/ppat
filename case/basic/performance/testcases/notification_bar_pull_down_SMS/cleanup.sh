#! /bin/bash
######## Configuration ########
LOG_FILE="notification_bar_pull_down_SMS"
TEMP_LOG=$1
DEVICE=$2
##############################

# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE

# start log
echo "===========gallery flick portrait start==========="
sleep 2
RESULT=`date +%F-%H-%M-%S`
start_log ${RESULT}_${LOG_FILE}
sleep 2


# log parser
echo "===========parse log begin==========="
. ../../utils/log_parser_gc.sh ../../log/${RESULT}_${LOG_FILE}.log ../../result/${RESULT}_${LOG_FILE}.txt
echo "===========parse log end============="
echo ""

$ADB shell input keyevent 4
sleep 2
$ADB shell input keyevent 4
sleep 2
echo "===========end==========="
echo ""
echo ""
cat ../../result/${RESULT}_${LOG_FILE}.txt | awk '{ if($1 == "AVERAGE:"){print "'${LOG_FILE}'", int($2),$3 }}' >  $TEMP_LOG
