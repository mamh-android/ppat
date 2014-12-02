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


    device_to_job={
            "pxa1L88dkb_def:pxa1L88dkb":"PPAT_HELNLTE",
            "pxa1U88dkb_def:pxa1U88dkb":"PPAT_HELN2",
            "pxa1928dkb_tz:pxa1928dkb":"PPAT_EDEN"
    }

    device_to_gcjob ={
            "pxa1908dkb_tz:pxa1908dkb":"PPAT_GC_ULC1",
            "pxa1928dkb_tz:pxa1928dkb":"PPAT_GC_EDEN"
    }

    #ondemand trigger ppat test.
    if mode == "manual":
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
        j.build_job("PPAT", parameters)

    #this is for gc power test
    elif mode == "gc":
        parameters = {
            'IMAGEPATH':imagepath,
            'ASSIGNER':assigner,
            'PURPOSE':purpose
        }

        jobname = device_to_gcjob.get(device,"")

        if not jobname:
            print "[debug] jobname is null!"
            pprint.pprint(device_to_gcjob)
            return 1

        print "[debug] jobname is %s" % (jobname)
        j.build_job(jobname, parameters)
    else:
        print "[debug] unknown mode: %s" % (mode)
        return 1

parser = OptionParser()
parser.add_option("", "--imagepath",    dest="imagepath",   help="set image path for burn.", default="")
parser.add_option("", "--branch",       dest="branch",      help="set the branch.",default="")
parser.add_option("", "--device",       dest="device",      help="set the device.",default="")
parser.add_option("", "--blf",          dest="blf",         help="set the blf.",default="")
parser.add_option("", "--assigner",     dest="assigner",    help="set the assigner,  (e.g.) mamh@marvell.com",default="mamh@marvell.com")
parser.add_option("", "--testcase",     dest="testcase",    help="set the testcase.",default="")
parser.add_option("", "--purpose",      dest="purpose",     help="set the purpose.",default="")
parser.add_option("", "--mode",         dest="mode",        help="set the mode.",default="")
(options, args) = parser.parse_args()
if __name__== "__main__":
    sys.stdout = sys.stderr
    main()

