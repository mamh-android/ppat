#! /bin/bash
######## Configuration ########
LOG_FILE="browser_zoom_portrait"
TEMP_LOG=$1
DEVICE=$2
##############################

# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE

# start log
echo "===========browser flick portrait start==========="
sleep 2
RESULT=`date +%F-%H-%M-%S`
start_log ${RESULT}_${LOG_FILE}
sleep 2

# log parser
echo "===========parse log begin==========="
. ../../utils/log_parser_browser.sh ../../log/${RESULT}_${LOG_FILE}.log ../../result/${RESULT}_${LOG_FILE}.txt zoom 
echo "===========parse log end============="
echo ""

adb -s $DEVICE shell am force-stop com.android.browser
echo "===========end==========="
echo ""
echo ""
cat ../../result/${RESULT}_${LOG_FILE}.txt | awk '{ if($1 == "AVERAGE:"){print "'${LOG_FILE}'", int($2),$3 }}' >  $TEMP_LOG
