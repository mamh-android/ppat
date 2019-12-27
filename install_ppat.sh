#!/bin/bash
function printcolor(){
    printf "\033[1;32m[install]\033[0m\033[1;31m$1\n\033[0m"
}

function main(){
    printcolor "install jdk jdk-6u45-linux-i586 to ./tools/"
    cd ./tools/ && chmod 755 ./jdk-6u45-linux-i586.bin && ./jdk-6u45-linux-i586.bin && cd ..
    printcolor "install jdk done"
    sleep 1
    printcolor "install lib/RXTX/32bit_PC/librxtxSerial.so"
    sudo cp -rfv ./lib/RXTX/32bit_PC/librxtxSerial.so /usr/lib/librxtxSerial.so
    printcolor "install librxtxSerial.so done"
    sleep 1

    printcolor "uncompress swdl_utils.tar.gz"
    cd ./tools/ && tar -xvzf swdl_utils.tar.gz && cd ..
    printcolor "uncompress done"
    sleep 1

    if [ ! -x "/usr/local/bin/" ];then
        printcolor "/usr/local/bin/ no such dir,then will create this dir."
        sudo mkdir -p /usr/local/bin/
        sudo cp -rvf ./tools/sendmail.py /usr/local/bin/
    else
        printcolor "copy file to /usr/local/bin/"
        sudo cp -rvf ./tools/sendmail.py /usr/local/bin/
    fi
}

main $*
