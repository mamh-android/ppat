SRC_BOARD_FILE=$1
DEST_FTP_FILE=$2

busybox ftpput -u ltetest -p zjtest123 211.140.3.250 "upload(shang chuan)/${DEST_FTP_FILE}" "/sdcard/DKB_power_data/${SRC_BOARD_FILE}" &
sleep 2
cd /sdcard/DKB_power_data/
ps | grep "busybox" | busybox sort -n -k 2 | busybox sed -n '1p' | busybox awk '{print $2}'>pid.txt
exit
