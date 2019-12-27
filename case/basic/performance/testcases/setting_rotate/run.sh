######## operation ########
while [ $OPERATION_LOOP -gt 0 ]
do
    adb shell input rotationevent 1
    sleep $OPERATION_INTERVAL
    adb shell input rotationevent 0
    sleep $OPERATION_INTERVAL

    OPERATION_LOOP=$(($OPERATION_LOOP-1))
done
sleep 3
echo "================================================"
echo ""
###########################
