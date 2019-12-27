#!/bin/bash
cd $HOME
wget ftp://10.38.164.23/Daily_Build/Cloud_Test/Auto_Burn/wtptp_driver.zip
unzip wtptp_driver.zip
sleep 1
#ltk
sudo apt-get install libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 libasound2:i386 libasound2-plugins:i386 gstreamer0.10-pulseaudio:i386 gstreamer0.10-plugins-base:i386 gstreamer0.10-plugins-good:i386 lib32z1 lib32ncurses5 lib32bz2-1.0 lib32z1-dev

#常用的软件
sudo apt-get install vim git vsftpd samba zsh ssh cifs-utils ctags minicom putty terminator guake chromium-browser

sleep 1
rsync -rlpv mamh@10.38.32.174:~/.vimrc $HOME
rsync -rlpv mamh@10.38.32.174:~/.vim $HOME
rsync -rlpv mamh@10.38.32.174:~/.zshrc $HOME
rsync -rlpv mamh@10.38.32.174:~/bin $HOME
rsync -rlpv mamh@10.38.32.174:~/ltk_cloud_client.bin $HOME
sudo rsync -rlpv mamh@10.38.32.174:/opt/ /opt/

