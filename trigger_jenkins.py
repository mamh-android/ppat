#!/usr/bin/python
import sys
import time
import os
sys.path.append("./")
import jenkins
import pprint
from optparse import OptionParser

url="http://10.38.120.30:8080"
username = "ppat"
password = "79fa7f655d56115da6fe7d707f63fd12"
j = jenkins.Jenkins(url, username, password)

def printcolor(msg):
    print "\033[1;32m[debug]\033[0m\033[1;31m%s\033[0m" % msg


def main():
    imagepath = options.imagepath
    branch = options.branch
    device = options.device.split(':')[0]
    blf = options.blf
    assigner = options.assigner
    testcase = options.testcase
    purpose = options.purpose
    mode = options.mode

    printcolor("options:\n%s" % options)

    osversion="lp5.0"
    if "lp5.0" in imagepath:
        osversion="lp5.0"
    elif "kk4.4" in imagepath:
        osversion="kk4.4"

    parameters = {
        'IMAGEPATH':imagepath,
        'BLF':blf,
        'ASSIGNER':assigner,
        'TESTCASE':testcase,
        'PURPOSE':purpose,
        'OS':osversion,
    }

    device_to_job={
            "pxa1928dkb_tz":[
                "PPAT_EDEN"
                ],
            "pxa1908dkb_tz":[
                "PPAT_ULC1",
                ],
            "pxa1936dkb_tz":[
                "PPAT_HELN3",
                ],
    }

    jobname_L = device_to_job.get(device, [])
    printcolor("job name = %s" % jobname_L)

    if not jobname_L:
        printcolor("job name is null. %s" % jobname_L)
        sys.exit(0)

    def get_willstartjobname():
        willstartjobname = ""
        info = j.get_info()
        jobs = info['jobs']
        for job in jobs:
            printcolor("job = %s" % job)
            for jobname in jobname_L:
                if job['name'] == jobname:
                    printcolor("Task name: %s" % job['name'])
                    printcolor("current state: %s" % job['color'])
                    printcolor("Jenkins url: %s" % job['url'])
                    if job['color'] == "disabled":
                        printcolor("%s is disabled" % (jobname))
                        time.sleep(120)
                    else:
                        if isbuilding(jobname):
                            printcolor("%s is building, let's wait..." % (jobname))
                            time.sleep(300)
                        elif os.path.exists("a"):
                            printcolor("pwd: %s" % os.getcwd())
                            printcolor("lock this job")
                            time.sleep(1000)
                        else:
                            willstartjobname = jobname
                            printcolor("will start build job: %s " % (willstartjobname))
                            return willstartjobname
    willstartjobname = ""
    while not willstartjobname:
        willstartjobname = get_willstartjobname()
        printcolor("willstartjobname = %s " % (willstartjobname))

    printcolor("will start build job: %s " % (willstartjobname))
    j.build_job(willstartjobname, parameters)

def isbuilding(jobname):
    jobinfo = j.get_job_info(jobname)
    lastbuildnumber = jobinfo['lastBuild']['number']
    currentbuild = j.get_build_info(jobname, lastbuildnumber)
    return currentbuild["building"]

parser = OptionParser()
parser.add_option("", "--imagepath",    dest="imagepath",   help="set image path for burn.", default="")
parser.add_option("", "--device",       dest="device",      help="set the device.",default="")
parser.add_option("", "--branch",       dest="branch",      help="set the branch.",default="")
parser.add_option("", "--blf",          dest="blf",         help="set the blf.",default="")
parser.add_option("", "--assigner",     dest="assigner",    help="set the assigner,  (e.g.) mamh@marvell.com",default="mamh@marvell.com")
parser.add_option("", "--testcase",     dest="testcase",    help="set the testcase.",default="")
parser.add_option("", "--purpose",      dest="purpose",     help="set the purpose.",default="")
parser.add_option("", "--mode",         dest="mode",        help="set the mode,manual",default="")
(options, args) = parser.parse_args()
if __name__== "__main__":
    sys.stdout = sys.stderr
    main()

