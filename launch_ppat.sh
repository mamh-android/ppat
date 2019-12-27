#! /bin/bash
PAT_HOME=.
driverfile="driver.xml" 	
PPAT_SCRIPT="java -cp ${PAT_HOME}/lib/org.json.jar:${PAT_HOME}/lib/poi-3.9-20121203.jar:${PAT_HOME}/lib/poi-ooxml-3.9-20121203.jar:${PAT_HOME}/lib/poi-ooxml-schemas-3.9-20121203.jar:${PAT_HOME}/lib/stax-api-1.0.1.jar:${PAT_HOME}/lib/xmlbeans-2.3.0.jar:${PAT_HOME}/lib/dsn.jar:v${PAT_HOME}/lib/imap.jar:${PAT_HOME}/lib/mailapi.jar:${PAT_HOME}/lib/pop3.jar:${PAT_HOME}/lib/smtp.jar:commons-net-2.0.jar:${PAT_HOME}/lib/commons-logging-1.1.1.jar:${PAT_HOME}/lib/httpclient-4.1.2.jar:${PAT_HOME}/lib/httpclient-cache-4.1.2.jar:${PAT_HOME}/lib/httpcore-4.1.2.jar:${PAT_HOME}/lib/httpmime-4.1.2.jar:${PAT_HOME}/lib/mail.jar:${PAT_HOME}/lib/dsn.jar:${PAT_HOME}/lib/imap.jar:${PAT_HOME}/lib/mailapi.jar:${PAT_HOME}/lib/smtp.jar:${PAT_HOME}/lib/pop3.jar:${PAT_HOME}/lib/libthrift-0.9.0.jar:${PAT_HOME}/lib/log4j-1.2.17.jar:${PAT_HOME}/lib/log4j-over-slf4j-1.7.2.jar:${PAT_HOME}/lib/slf4j-api-1.7.2.jar:${PAT_HOME}/lib/slf4j-log4j12-1.7.2.jar:${PAT_HOME}/lib/jxl.jar:${PAT_HOME}/lib/mysql-connector-java-5.1.22-bin.jar:${PAT_HOME}/lib/ant-contrib-1.0b3.jar:${PAT_HOME}/lib/ppat.jar:${PAT_HOME}/lib/jcifs-1.3.15.jar:${PAT_HOME}/lib/dom4j-1.6.1.jar:${PAT_HOME}/lib/jaxen-1.1.1.jar:${PAT_HOME}/lib/commons-net-2.0.jar:${PAT_HOME}/lib/RXTXcomm.jar:${PAT_HOME}/lib/ant.jar:${PAT_HOME}/lib/ant-launcher.jar org.apache.tools.ant.launch.Launcher"
CASE_LIST=""
function listall(){
    $PPAT_SCRIPT -f $driverfile -Dplatform=$PLATFORM -Dbuild=build/classes listall
}

function selectcase(){
    CASE_LIST=$1
}

function chooseplatform(){
    PLATFORM=$1
}
function choosemode(){
    MODE=$1
}

function chooseimagepath(){
    IMAGE_PATH=$1
}

function chooseosversion(){
    OS_VERSION=$1
}

function choosepurpose(){
    PURPOSE=$1
}

function choosejsoncase(){
    JSON_CASE_LIST=$1
}

function chooseblf(){
    BLF=$1
}

function chooselsversion(){
    RLS_VERSION=$1
}

function chooseburnmode(){
    BURN_MODE=$1
}

function chooseassigner(){
    ASSIGNER=$1
}

function chooseautoburn(){
    AUTOBURN=$1
}

function choosepowerport(){
    POWER_PORT=$1
}
function chooseserialport(){
    SERIAL_PORT=$1
}

function run(){
    echo $CASE_LIST
    if [ $CASE_LIST -eq ""]
    then
        $PPAT_SCRIPT -f $driverfile -Dplatform=$PLATFORM -Dautoburn=$AUTOBURN -Dos_version=$OS_VERSION -Drelease_version=$RLS_VERSION -Dburn_mode=$BURN_MODE -Dmode=$MODE -Dtc_json_str=$JSON_CASE_LIST -Dblf=$BLF -Dpurpose=$PURPOSE -Dimage_path=$IMAGE_PATH -Dassigner=$ASSIGNER -Dpower_port=$POWER_PORT -Dserial_port=$SERIAL_PORT -Dwith_precondition="false" -Dwith-spc-predition="false"-Dbuild=build/classes exe
    else
        $PPAT_SCRIPT -f $driverfile -Dplatform=$PLATFORM -Dautoburn=$AUTOBURN -Dos_version=$OS_VERSION -Drelease_version=$RLS_VERSION -Dburn_mode=$BURN_MODE -Dmode=$MODE -Dtc_str=$CASE_LIST -Dblf=$BLF -Dpurpose=$PURPOSE -Dimage_path=$IMAGE_PATH -Dassigner=$ASSIGNER -Dpower_port=$POWER_PORT -Dserial_port=$SERIAL_PORT -Dwith_precondition="false" -Dwith-spc-predition="false" -Dbuild=build/classes exe
    fi

}
