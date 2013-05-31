#!/bin/bash
# launchPPAT.py -r [true/false] -p reason_for_test -d image_dest_dir -b branch_name -dev device -blf blf_name -assigner tasksubmitter -tc testcaselist_from_web_to_json
set -o pipefail
STD_LOG=/home/buildfarm/ppat/stdio.log
rm $STD_LOG
python /home/buildfarm/ppat/launchPPAT.py $* | tee -a $STD_LOG
