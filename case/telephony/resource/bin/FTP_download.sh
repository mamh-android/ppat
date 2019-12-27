SRC_FTP_FILE=$1
DEST_BOARD_FILE=$2
OUT_LOG=$3

busybox ftpget -u ltetest -p zjtest123 211.140.3.250 "/sdcard/DKB_power_data/${DEST_BOARD_FILE}" "download(xia zai)/${SRC_FTP_FILE}" &
sleep 5
cd /sdcard/DKB_power_data
if [ ! -z ${OUT_LOG} ]; then
    rm -f ${OUT_LOG}
fi
echo "ftpget process infor: ">>${OUT_LOG}
ps | grep "busybox" | busybox sort -n -k 2 >>${OUT_LOG}
echo "begining size of the download file:">>${OUT_LOG}
ps | grep "busybox" | busybox sort -n -k 2 | busybox sed -n '1p' | busybox awk '{print $2}'>pid.txt
exit
