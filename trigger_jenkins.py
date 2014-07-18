#!/usr/bin/python
import sys,time
sys.path.append("./")
import jenkins
import pprint
from optparse import OptionParser

url="http://10.38.120.30:8080"
username = "ppat"
password = "79fa7f655d56115da6fe7d707f63fd12"
j = jenkins.Jenkins(url, username, password)

def main():
    imagepath = options.imagepath
    branch = options.branch
    device = options.device
    blf = options.blf
    assigner = options.assigner
    testcase = options.testcase
    purpose = options.purpose
    mode = options.mode

    parameters = {
        'IMAGEPATH':imagepath,
        'BRANCH':branch,
        'DEVICE':device,
        'BLF':blf,
        'ASSIGNER':assigner,
        'TESTCASE':testcase,
        'PURPOSE':purpose,
        'MODE':mode
    }

    device_to_job={
            "pxa1L88dkb_def:pxa1L88dkb":"PPAT_HELNLTE",
            "pxa1U88dkb_def:pxa1U88dkb":"PPAT_HELN2",
            "pxa1928dkb_tz:pxa1928dkb":"PPAT_EDEN"
    }

    jobname = device_to_job.get(device, "")

    isRunning = True
    while isRunning:
        info = j.get_info()
        jobs = info['jobs']
        for job in jobs:
            if job['name'] == jobname:
                print "Task name:",job['name'],"current state:",job['color'], "Jenkins url: ", job['url'] 
                if job['color'] == "disabled":
                    print "PPAT currently is disabled, let's wait..."
                    time.sleep(10)
                else:
                    if isbuilding(jobname):
                        print "PPAT currently is building, let's wait..."
                        time.sleep(10)
                    else:
                        isRunning = False

    j.build_job(jobname, parameters)

def isbuilding(jobname):
    jobinfo = j.get_job_info(jobname)
    lastbuildnumber = jobinfo['lastBuild']['number']
    currentbuild = j.get_build_info(jobname, lastbuildnumber)
    return currentbuild["building"]

parser = OptionParser()
parser.add_option("", "--imagepath",    dest="imagepath",   help="set image path for burn.", default="")
parser.add_option("", "--branch",       dest="branch",      help="set the branch.",default="")
parser.add_option("", "--device",       dest="device",      help="set the device. pxa1U88dkb_def:pxa1U88dkb\npxa1928dkb_tz:pxa1928dkb\npxa1L88dkb_def:pxa1L88dkb\n",default="")
parser.add_option("", "--blf",          dest="blf",         help="set the blf.",default="")
parser.add_option("", "--assigner",     dest="assigner",    help="set the assigner,  (e.g.) mamh@marvell.com",default="mamh@marvell.com")
parser.add_option("", "--testcase",     dest="testcase",    help="set the testcase.",default="")
parser.add_option("", "--purpose",      dest="purpose",     help="set the purpose.",default="")
parser.add_option("", "--mode",         dest="mode",        help="set the mode,manual, kk4.4, alpha2, kk_beta2, check.",default="")
(options, args) = parser.parse_args()
if __name__== "__main__":
    sys.stdout = sys.stderr
    main()

