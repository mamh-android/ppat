#!/data/bin/busybox sh

echo "--Creating symbolic link..."

ln -s /data/bin/busybox /data/bin/cut
ln -s /data/bin/busybox /data/bin/set
ln -s /data/bin/busybox /data/bin/hwclock
ln -s /data/bin/busybox /data/bin/tee
ln -s /data/bin/busybox /data/bin/grep
ln -s /data/bin/busybox /data/bin/sed
ln -s /data/bin/busybox /data/bin/mknod
ln -s /data/bin/busybox /data/bin/usleep
ln -s /data/bin/busybox /data/bin/top
ln -s /data/bin/busybox /data/bin/stty
ln -s /data/bin/busybox /data/bin/vi
ln -s /data/bin/busybox /data/bin/mount
ln -s /data/bin/busybox /data/bin/tail
ln -s /data/bin/busybox /data/bin/awk
ln -s /data/bin/busybox /data/bin/cp
ln -s /data/bin/busybox /data/bin/rm
ln -s /data/bin/busybox /data/bin/md5sum
ln -s /data/bin/busybox /data/bin/expr
ln -s /data/bin/busybox /data/bin/touch                             
ln -s /data/bin/busybox /data/bin/nohup
ln -s /data/bin/busybox /data/bin/ls
ln -s /data/bin/busybox /data/bin/head
ln -s /data/bin/busybox /data/bin/time
ln -s /data/bin/busybox /data/bin/free
ln -s /data/bin/busybox /data/bin/ifconfig
ln -s /data/bin/busybox /data/bin/clear
ln -s /data/bin/busybox /data/bin/uname
ln -s /data/bin/busybox /data/bin/update
ln -s /data/bin/busybox /data/bin/hostname
ln -s /data/bin/busybox /data/bin/wc

export PATH=/data/bin:$PATH

mkdir /data/test/









                             
