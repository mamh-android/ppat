import sys, os, json, time, xml.etree.cElementTree as ET,re,shlex,pprint
from optparse import OptionParser

pat_home = os.path.abspath(os.path.dirname(sys.argv[0]))
ppat_script = "${PAT_HOME}/tools/jdk1.6.0_45/bin/java -cp ${PAT_HOME}/lib/ant-nodeps-1.8.1.jar:${PAT_HOME}/lib/org.json.jar:{PAT_HOME}/lib/commons-logging-1.1.1.jar:${PAT_HOME}/lib/libthrift-0.9.0.jar:${PAT_HOME}/lib/log4j-1.2.17.jar:${PAT_HOME}/lib/log4j-over-slf4j-1.7.2.jar:${PAT_HOME}/lib/slf4j-api-1.7.2.jar:${PAT_HOME}/lib/slf4j-log4j12-1.7.2.jar:${PAT_HOME}/lib/jxl.jar:${PAT_HOME}/lib/mysql-connector-java-5.1.22-bin.jar:${PAT_HOME}/lib/ant-contrib-1.0b3.jar:${PAT_HOME}/lib/ppat.jar:${PAT_HOME}/lib/dom4j-1.6.1.jar:${PAT_HOME}/lib/jaxen-1.1.1.jar:${PAT_HOME}/lib/commons-net-3.3.jar:${PAT_HOME}/lib/RXTXcomm.jar:${PAT_HOME}/lib/ant.jar:${PAT_HOME}/lib/ant-launcher.jar org.apache.tools.ant.launch.Launcher -f ${PAT_HOME}/driver.xml -logger com.marvell.ppat.logger.Logger"

def list_all():
    platform = options.platform
    command = "PAT_HOME='%s';%s -Dplatform=%s  -Dbuild=build/classes listall" % (pat_home, ppat_script, platform)
    #print command
    os.system(command)

def do_prepare():
    platform = options.platform
    tc_list = options.tc_list
    ser_port = options.ser_port
    command = "PAT_HOME='%s';%s -Dplatform=%s -Dwith_precondition=true -Dtc_list=%s -Dserial_port=%s -Dmode=power -Dbuild=build/classes prepare" % (pat_home, ppat_script, platform, tc_list, ser_port)
    os.system(command)

def main():
    listall = options.listall
    prepare = options.prepare
    platform = options.platform
    autoburn = options.autoburn
    os_ver = options.os_ver
    rls_ver = options.rls_ver
    burn_mod = options.burn_mod
    tc_list = options.tc_list
    purpose=options.purpose
    assigner = options.assigner
    pm_port = options.pm_port
    ser_port = options.ser_port
    blf = options.blf
    ppat_mod = options.ppat_mod
    img_path = options.img_path
    prec = options.prec
    spc_prec = options.spc_prec
    db_name = options.db_name
    adb_id = options.adb_id
    ltk_id = options.ltk_id
    loc_img = options.loc_img
    usb_port = options.usb_port
    rst_port = options.rst_port
    bak_port = options.bak_port
    lcd_res = options.lcd_res
    device = options.device
    input_dev = options.input_dev

    if listall == True:
        list_all()
    elif prepare == True:
        do_prepare()
    else:
        command = "PAT_HOME='%s';%s -Dplatform=%s -Dautoburn=%s -Dos_version=%s \
                -Drelease_version=%s -Dburn_mode=%s -Dmode=%s -Dtc_list=%s -Dblf=%s \
                -Dpurpose=%s -Dimage_path=%s -Dassigner=%s -Dpower_port=%s -Dserial_port=%s \
                -Dwith_precondition=%s -Dwith_spc_precondition=%s -Ddb_name=%s \
                -Dadb_device_id=%s -Dltk_device_id=%s -Dlocal_image_path=%s\
                -Dusb_port=%s -Dreset_port=%s -Dback_port=%s -Dresolution=%s -Ddevice=%s -Dinput_device_name=%s\
                -Dbuild=build/classes remotebackup" % (
                        pat_home, ppat_script, platform, autoburn,os_ver,
                        rls_ver, burn_mod, ppat_mod, "'" + tc_list + "'", blf,
                        "'" + purpose + "'", img_path, assigner, pm_port, ser_port, prec,
                        spc_prec, db_name, adb_id, ltk_id, loc_img, usb_port, rst_port, bak_port, lcd_res, device, input_dev )
        os.chdir(pat_home)
        os.system("git fetch origin")
        os.system("git checkout origin/rls")
        ret = os.system(command)
        if ret != 0:
            sys.exit(1)

#parse the arguments.
parser = OptionParser()
parser.add_option("", "--platform",
        dest="platform",   help="platform: eden, ulc1, hln2", default="default")
parser.add_option("", "--os-ver",
        dest="os_ver",   help="set os version (default is kk4.4)", default="kk4.4")
parser.add_option("", "--rls-ver",
        dest="rls_ver",   help="set release version\n", default="")

parser.add_option("", "--img-path",
        dest="img_path",   help="image path", default="")
parser.add_option("", "--autoburn",
        dest="autoburn",   help="autoburn: true or false (default is false)", default="false")
parser.add_option("", "--burn-mod",
        dest="burn_mod",   help="burn mode: lastest,specific (default is specific)", default="specific")
parser.add_option("", "--blf",
        dest="blf",   help="blf", default="blf")
parser.add_option("", "--loc-img",
        dest="loc_img",   help="path to save copyed image files for auto burn", default="")

parser.add_option("", "--ppat-mod",
        dest="ppat_mod",   help="ppat mode: power,local (default is local)", default="local")

parser.add_option("", "--tc-list",
        dest="tc_list",   help="set testcase list, 1,2,3 or home,standby,mp3", default="")
parser.add_option("", "--db-name",
        dest="db_name",   help="write db name", default="ondemand")

parser.add_option("", "--purpose",
        dest="purpose",   help="set purpose", default="")
parser.add_option("", "--assigner",
        dest="assigner",   help="set assigner", default="mamh@marvell.com")
parser.add_option("", "--pm-port",

        dest="pm_port",   help="set power monitor port", default="")
parser.add_option("", "--ser-port",
        dest="ser_port", action="store", help="set serial port,default is USB0", default="USB0")
parser.add_option("", "--prec",
        dest="prec",    help="run with default precondition(precondition.xml), default is true", default="true")
parser.add_option("", "--spc-prec",
        dest="spc_prec", help="run with default and specific precondition, default is true", default="true")

parser.add_option("", "--usb-port",
        dest="usb_port", help="set relay usb port, like 1")
parser.add_option("", "--rst-port",
        dest="rst_port", help="set relay reset port,like 2")
parser.add_option("", "--bak-port",
        dest="bak_port", help="set relay back port,like 3")
parser.add_option("", "--lcd-res",
        dest="lcd_res", help="set LCD resolution(1080p, 720p, VGA)")
parser.add_option("", "--device",
        dest="device", help="set device name *_tz, *_dsds")
parser.add_option("", "--input-dev",
        dest="input_dev", help="set input touch device name")
parser.add_option("", "--adb-id",
        dest="adb_id",   help="set adb device id, default is 0123456789ABCDEF\n", default="0123456789ABCDEF")
parser.add_option("", "--ltk-id",
        dest="ltk_id",   help="set ltk device id, default is 0123456789ABCDEF\n", default="0123456789ABCDEF")
parser.add_option("", "--listall",
        dest="listall",  action="store_true", help="list all the testcase", default="listall")
parser.add_option("", "--prepare",
        dest="prepare",  action="store_true", help="prepare for run test case", default="prepare")
(options, args) = parser.parse_args()
if __name__ == "__main__":
    sys.stdout = sys.stderr
    main()
