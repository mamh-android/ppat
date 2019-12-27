#!/usr/bin/python
#coding:utf-8
import os
import time
import smtplib
from email.mime.text import MIMEText
from optparse import OptionParser

def send_mail(to_list, sub, content):
    mail_host="smtp.marvell.com"
    mail_to_list=["mamh@marvell.com"]
    me="PPAT"
    msg=MIMEText(content, _subtype='html', _charset='utf-8')
    msg['Subject'] = sub
    msg['From'] = me
    msg['To'] = ";".join(to_list)
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.sendmail(me, to_list, msg.as_string())
        s.close()
        return True
    except Exception, e:
        print str(e)
        return False

def main():
    logfile=options.logfile
    mailto=options.mailto
    sub=options.sub
    msg = ""
    if not os.path.exists(logfile):
        return 0
    f = open(logfile, 'r')
    try:
        for line in f:
            msg += line
    except IOError:
        print "No such file"
    finally:
        f.close()

    to_list = ["mamh@marvell.com", "zhoulz@marvell.com"]
    to_list.append(mailto)
    send_mail(to_list, sub, msg)

parser = OptionParser()
parser.add_option("-l", "--logfile", dest="logfile", help="set file to sendmail.", default="")
parser.add_option("-t", "--mailto", dest="mailto", help="set file to sendmail.", default="")
parser.add_option("-s", "--subject", dest="sub", help="set subject of sendmail.", default="[ppat is done]")
(options, args) = parser.parse_args()
if __name__ == "__main__":
    main()
