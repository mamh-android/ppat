import sys, os, json, time, xml.etree.cElementTree as ET,re,shlex,pprint
from optparse import OptionParser

def main():
    print "options is:",options
    imagepath = options.imagepath
    branch = options.branch
    device = options.device
    blf = options.blf
    assigner = options.assigner
    testcase = options.testcase
    purpose = options.purpose
    mode = options.mode

    print "mode is ",mode
    if mode == 'manual':
        manual_run_ppat(imagepath, branch, device, blf, assigner, testcase, purpose)
    elif mode == 'kk4.4':#daily build
        print "device: ",device
        if device == 'pxa1928dkb_tz:pxa1928dkb':
            ret = os.system("bash /home/buildfarm/eden/ATF_daily.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

        if device == 'pxa1L88dkb_def:pxa1L88dkb':
            ret = os.system("bash /home/buildfarm/helanLTE/ATF_daily.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

        if device == 'pxa1U88dkb_def:pxa1U88dkb':
            ret = os.system("bash /home/buildfarm/helan2/ATF_daily.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

    elif mode == 'alpha2':#daily build
        if device == 'pxa1928dkb_tz:pxa1928dkb':
            ret = os.system("/home/buildfarm/eden/ATF_alpha2.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

    elif mode == 'beta1':#daily build
        if device == 'pxa1928dkb_tz:pxa1928dkb':
            ret = os.system("/home/buildfarm/eden/ATF_beta1.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)
    elif mode == 'kk_beta2':#daily build
        if device == 'pxa1L88dkb_def:pxa1L88dkb':
            ret = os.system("bash /home/buildfarm/helanLTE/ATF_daily_kk_beta2.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

    elif mode == 'kk_beta1':#daily build
        if device == 'pxa1L88dkb_def:pxa1L88dkb':
            ret = os.system("bash /home/buildfarm/helanLTE/ATF_daily_kk_beta1.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

    elif mode == 'jb4.3_beta1':#daily build
        if device == 'pxa1L88dkb_def:pxa1L88dkb':
            ret = os.system("bash /home/buildfarm/helanLTE/ATF_daily_beta1.sh")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

    elif mode == 'check':#check by manual, this will chdir pat home and run ./ATF check.xml
        if device == 'pxa1L88dkb_def:pxa1L88dkb':
            os.chdir("/home/buildfarm/helanLTE/PAT")
            print "pwd:",os.getcwd()
            ret = os.system("./launch_ppat.sh check.xml")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

        if device == 'pxa1928dkb_tz:pxa1928dkb':
            os.chdir("/home/buildfarm/eden/PAT")
            print "pwd:",os.getcwd()
            ret = os.system("./launch_ppat.sh check.xml")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)

        if device == 'pxa1U88dkb_def:pxa1U88dkb':
            os.chdir("/home/buildfarm/helan2/PAT")
            print "pwd:",os.getcwd()
            ret = os.system("./launch_ppat.sh check.xml")
            print "result: ",ret
            if ret != 0:
                sys.exit(1)
    else:
        print "mode is invalid exit(1)"
        sys.exit(1)

def manual_run_ppat(imagepath, branch, device, blf, assigner, testcase, purpose):
    print "device: ",device
    if device:
        board = device.split(':')[0].split('_')[0]
        print "board: ",board
        if board == 'pxa1928dkb':
            os.chdir("/home/buildfarm/eden/PAT")
            print "start cp testcase pwd:",os.getcwd()
            os.system("sudo cp /PPAT_test/testcase/*.atf.xml case/android/PowerConsumption/atf/")
            
            if imagepath.find("pxa1928-kk4.4") > 0:
                print "git pull origin eden-kk4.4"
                os.system("git fetch origin eden-kk4.4")
                os.system("git checkout origin/eden-kk4.4")

        elif board == 'pxa1U88dkb':
            os.chdir("/home/buildfarm/helan2/PAT")
            print "start cp testcase pwd:",os.getcwd()
            os.system("sudo cp /PPAT_test/testcase/*.atf.xml case/android/PowerConsumption/atf/")

            if imagepath.find("pxa988-kk4.4"):
                print "git pull origin pxa1U88dkb-kk4.4"
                os.system("git fetch origin pxa1U88-kk4.4")
                os.system("git checkout origin/pxa1U88-kk4.4")
                os.system("git checkout case/android/PowerConsumption/atf")

        elif board == 'pxa1L88dkb':
            os.chdir("/home/buildfarm/helanLTE/PAT")
            print "start cp testcase pwd:",os.getcwd()
            os.system("sudo cp /PPAT_test/testcase/*.atf.xml case/android/PowerConsumption/atf/")

            if imagepath.find("pxa988-kk4.4") > 0:
                print "git pull origin pxa1L88dkb-kk4.4"
                os.system("git fetch origin pxa1L88dkb-kk4.4")
                os.system("git checkout origin/pxa1L88dkb-kk4.4")
                os.system("git checkout case/android/PowerConsumption/atf")

            if imagepath.find("pxa988-jb4.3") > 0:
                print "git pull origin pxa1L88dkb-jb4.3"
                os.system("git fetch origin pxa1L88dkb-jb4.3")
                os.system("git checkout origin/pxa1L88dkb-jb4.3")
                os.system("git checkout case/android/PowerConsumption/atf")

        else:
            print "Can't support PPAT for %s" % (device)
            sys.exit(1)


    fileName = "list.xml"
    tree = ET.ElementTree(ET.parse(fileName).getroot())

    apmFile = "auto_pm_ppat.xml"
    treeAPM = ET.ElementTree(ET.parse(apmFile).getroot())

    if imagepath:
        updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_image_path\"]", imagepath)
        version = imagepath.split('-')[-1] #/autobuild/android/pxa988/2014-06-10_pxa988-kk4.4/
        if version.endswith("/"):
            updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_os_version\"]", version[:-1])
        else:
            updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_os_version\"]", version)
    else:
        print "Arg is wrong: image_path"
        sys.exit(1)

    if purpose:
        print "purpose: ",purpose
        updateXML(tree,"list.xml", "Arg/Property[@name=\"Purpose\"]", purpose)
    else:
        updateXML(tree,"list.xml", "Arg/Property[@name=\"Purpose\"]", "purpose:"+device)

    if device:
        board = device.split('_')[0]
        updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_board\"]", board)

        if board.find("1L88") > 0:
            updateXML(tree, "list.xml", "Arg/Property[@name=\"atf_platform\"]", "HELNLTE")
        if board.find("1U88") > 0:
            updateXML(tree, "list.xml", "Arg/Property[@name=\"atf_platform\"]", "HELN2")
        if board.find("1928") > 0:
            updateXML(tree, "list.xml", "Arg/Property[@name=\"atf_platform\"]", "EDEN")

    else:
        print "Arg is wrong: device"
        sys.exit(1)

    if testcase:
        addTestCaseList(tree, "list.xml", "TestCaseList", testcase, purpose, blf, assigner, imagepath, 0)
        addAPMParam(treeAPM, "auto_pm_ppat.xml", testcase, assigner)
    else:
        print "Arg is wrong: testcase"
        sys.exit(1)

    ret = os.system("./launch_ppat.sh ATD_config.xml")
    print "result: ",ret
    if ret != 0:
        sys.exit(1)

def addTestCaseList(tree, fileName, elementName, testcases, purpose, blf, assigner, image_path, build_num):
    jsonStr = json.loads(testcases)
    if jsonStr.has_key("inputs"):
        for input in jsonStr["inputs"]:
            desc = input["description"]
            commands = input["commands"]
            for tc in jsonStr["TestCaseList"]:
                for elem in tree.iterfind(elementName):
                    child = ET.SubElement(elem, "TestCase")
                    name = ET.SubElement(child, "Name")
                    name.text=tc["Name"]
                    timeout = ET.SubElement(child, "timeout")
                    timeout.text="6000000"

                    category = ET.SubElement(child, "category")
                    category.text = ";Functionality Test;"

                    taskId = ET.SubElement(child, "taskname")
                    taskId.text = build_num

                    if tc.has_key("count"):
                        count = ET.SubElement(child, "Count")
                        count.text = tc["count"]

                    ass = ET.SubElement(child, "assigner")
                    ass.text = assigner

                    blf_b = ET.SubElement(child, "blf")
                    blf_b.text = blf

                    description = ET.SubElement(child, "description")
                    description.text = desc

                    cmds = ET.SubElement(child, "cmds")
                    cmds.text = commands

                    if tc.has_key("Property"):
                        for name,value in tc["Property"].items():
                            prop = ET.SubElement(child, "Property")
                            prop.attrib["name"] = name
                            prop.text = value

                    if jsonStr.has_key("TuneParam"):
                        tune = ET.SubElement(child, "Tune")
                        for param,v in jsonStr["TuneParam"].items():
                            if param.find("gpu") == 0 or param.find("vpu") == 0:
                                comp = ET.SubElement(tune, param[0:3])
                                unit = ET.SubElement(comp,"unit")
                                unit.attrib["id"]=param[3]
                                for compkey,compvalue in v.items():
                                    compParam = ET.SubElement(unit,compkey)
                                    compParam.text = compvalue
                            else:
                                comp = ET.SubElement(tune, param)
                                for compkey,compvalue in v.items():
                                    compParam = ET.SubElement(comp, compkey)
                                    compParam.text = compvalue
    else:
        for tc in jsonStr["TestCaseList"]:
            for elem in tree.iterfind(elementName):
                child = ET.SubElement(elem, "TestCase")
                name = ET.SubElement(child, "Name")
                name.text=tc["Name"]
                timeout = ET.SubElement(child, "timeout")
                timeout.text="6000000"

                category = ET.SubElement(child, "category")
                category.text = ";Functionality Test;"

                taskId = ET.SubElement(child, "taskname")
                taskId.text = build_num
                
                if tc.has_key("count"):
                    count = ET.SubElement(child, "Count")
                    count.text = tc["count"]

                ass = ET.SubElement(child, "assigner")
                ass.text = assigner

                blf_b = ET.SubElement(child, "blf")
                blf_b.text = blf

                if jsonStr.has_key("TuneParam"):
                    tune = ET.SubElement(child, "Tune")
                    for param,v in jsonStr["TuneParam"].items():
                        if param.find("gpu") == 0 or param.find("vpu") == 0:
                            comp = ET.SubElement(tune, param[0:3])
                            unit = ET.SubElement(comp,"unit")
                            unit.attrib["id"]=param[3]
                            for compkey,compvalue in v.items():
                                compParam = ET.SubElement(unit,compkey)
                                compParam.text = compvalue
                        else:
                            comp = ET.SubElement(tune, param)
                            for compkey,compvalue in v.items():
                                compParam = ET.SubElement(comp, compkey)
                                compParam.text = compvalue
                if tc.has_key("Property"):
                    for name,value in tc["Property"].items():
                        prop = ET.SubElement(child, "Property")
                        prop.attrib["name"] = name
                        prop.text = value

    if jsonStr.has_key("bareParam"):
        Arg = tree.find("Arg")
        for param,val in jsonStr["bareParam"].items():
            prop = ET.Element("Property", {"name": param})
            prop.text = val
            Arg.append(prop)
    if jsonStr.has_key("stream"):
        for stream in jsonStr["stream"]:
            va = stream["CaseName"]
            if va == "1080p":
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_1080p\"]", stream["Stream"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_1080p_sleep\"]", stream["Duration"])
            elif va == "720p":
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_720p\"]", stream["Stream"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_720p_sleep\"]", stream["Duration"])
            elif va == "VGA":
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_low_resolution\"]", stream["Stream"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_video_low_resolution_sleep\"]", stream["Duration"])
            else:
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_audio_sleep\"]", stream["Duration"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_audio1\"]", stream["Stream"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_audio2\"]", stream["Stream"])
                updateXML(tree, "list.xml", "Arg/Property[@name=\"power_audio3\"]", stream["Stream"])

    tree.write("ATD_config.xml", encoding="utf-8")
    
def addAPMParam(treeAPM, fileName,jsonStr,assigner):
    print ""

def updateXML(tree, fileName, elementName, textValue):
    for elem in tree.iterfind(elementName):
        elem.text = textValue
    tree.write("ATD_config.xml", encoding="utf-8")

def updateAPMXML(treeAPM, fileName, elementName, textValue):
    for elem in treeAPM.iterfind(elementName):
        elem.text = textValue
    treeAPM.write("auto_pm.xml", encoding="utf-8")

def print_usage():
    print "Please use \'launch_ppat.py -r true -p reason_for_test -d image_dest_dir -b branch_name -dev device -blf blf_name -assigner tasksubmitter -bn build_number -tc testcaselist_from_web_to_json\'"

#parse the arguments.
parser = OptionParser()
parser.add_option("", "--imagepath",    dest="imagepath",   help="set image path for burn.", default="")
parser.add_option("", "--branch",       dest="branch",      help="set the branch.",default="")
parser.add_option("", "--device",       dest="device",      help="set the device.",default="")
parser.add_option("", "--blf",          dest="blf",         help="set the blf.",default="")
parser.add_option("", "--assigner",     dest="assigner",    help="set the assigner,  (e.g.) mamh@marvell.com",default="mamh@marvell.com")
parser.add_option("", "--testcase",     dest="testcase",    help="set the testcase.",default="")
parser.add_option("", "--purpose",      dest="purpose",     help="set the purpose.",default="")
parser.add_option("", "--mode",         dest="mode",        help="set the mode,daily or kk4.4, alpha2,.",default="")
(options, args) = parser.parse_args()
if __name__ == "__main__":
    sys.stdout = sys.stderr
    main()
