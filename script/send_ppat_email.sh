#!/bin/bash

GERRIT_PATCH=
MANIFEST_XML=
MANIFEST_BRANCH=
DEST_DIR=
PLATFORM_ANDROID_VARIANT=
ABS_BUILD_DEVICES=
USEREMAIL=
BUILDTYPE=
build_maintainer="zhoulz@marvell.com"
STD_LOG=/home/buildfarm/ppat/stdio.log
EMAIL_REPORT=$( awk -F"<result-form>|</result-form>" ' /<result-form>/ { print $2 $3 $4 } ' $STD_LOG )
DEV_TEAM="APSE-SE1"

help() {
  if [ -n "$1" ]; then
    echo "Error: $1"
    echo
  fi
  echo "HELP!!!!"
  echo "-e [useremail] -t [build type]"
  echo "-e -t"
  exit 1
}

validate_parameters() {
  if [ $# -lt 1 ]; then
    help
  fi
  while [ $# -gt 0 ];
  do
    case "$1" in
      "-e")
        if [ -z "$2" ]; then
          help "Please give a valid useremail."
        fi
        USEREMAIL=$2
        ;;
      "-t")
        if [ -z "$2" ]; then
          help "Please give a valid build type."
        fi
        BUILDTYPE=$2
#        shift 1
#        continue
        ;;
    esac
    shift 1
  done
}

generate_error_notification_email() {
cat <<-EOF

This is an automated email from the autobuild script. It was
generated because an error encountered while $BUILDTYPE.
Please check the build log below and fix the error.

Last part of build log is followed:
=========================== Build LOG =====================

$(tail -100 $STD_LOG 2>/dev/null)

===========================================================

Complete Time: $(date)
Build Host: $(hostname)

---
Team of $DEV_TEAM
EOF
}

generate_success_notification_email() {
echo $EMAIL_REPORT
}

send_error_notification() {
  echo "generating error notification email"
  generate_error_notification_email  | /usr/bin/sendemail -f $build_maintainer -t $USEREMAIL -cc $build_maintainer -s smtp.marvell.com -u "$BUILDTYPE is failed" -m   
}

send_success_notification() {
  generate_success_notification_email | /usr/bin/sendemail -f $build_maintainer -t $USEREMAIL -cc $build_maintainer -s smtp.marvell.com -u "$BUILDTYPE is done" -o message-content-type=html -m  
}

validate_parameters $*

result=`grep ">PASS<" $STD_LOG`
if [ -n "$result" ]; then
  send_success_notification
  exit 0
else
  send_error_notification
  exit 0
fi
