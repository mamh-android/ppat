#!/bin/sh
target_ftp_file=$1
subcase_root=$2
out_log=$3

echo "">>${subcase_root}/${out_log}
date>>${subcase_root}/${out_log}
ftp -ni <<!
open 211.140.3.250
user ltetest zjtest123
bin
cd "upload(shang chuan)"
ls ${target_ftp_file} "temp.log"
bye
!

if [ -e temp.log ]; then
    cat temp.log>>${subcase_root}/${out_log}
    rm -f temp.log
fi
exit
