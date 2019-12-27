#! /bin/bash
######## Configuration ########
LOG_FILE="browser_scroll_after_zoom"
TEMP_LOG=$1
DEVICE=$2
##############################

# import public utils
cd $(dirname $0)
. ../../utils/UI_utils.sh $DEVICE

# start log
echo "===========browser scroll after zoom start==========="
sleep 2
RESULT=`date +%F-%H-%M-%S`
start_log ${RESULT}_${LOG_FILE}
sleep 2

# log parser
echo "===========parse log begin==========="
. ../../utils/log_parser_browser.sh ../../log/${RESULT}_${LOG_FILE}.log ../../result/${RESULT}_${LOG_FILE}.txt scroll
echo "===========parse log end============="
echo ""

echo "===========end==========="
echo ""
echo ""
cat ../../result/${RESULT}_${LOG_FILE}.txt | awk '{ if($1 == "AVERAGE:"){print "'${LOG_FILE}'", int($2),$3 }}' >  $TEMP_LOG
