package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Pattern;

public class ParseLogcat extends ParseCommon {

    private String tag = null;
    private String ringBuffer = null;

    public void parseResult() throws BuildException {
        AdbCmd adbcmd = new AdbCmd();
        adbcmd.setProject(this.getProject());
        adbcmd.setPrintStdOut(false);
        adbcmd.execute("adb logcat -d " + tag + " " + ringBuffer);
        if (adbcmd.getExeResult().stdout.isEmpty()) {
            throw new BuildException("logcat output is empty");
        }

        int hits = 0;
        boolean matched = true;
        /*use cmp file to match*/
        if (rexFile != null) {
            BufferedReader matchbr;
            try {
                matchbr = new BufferedReader(new InputStreamReader(new FileInputStream(rexFile)));
                String cmp = "";
                for (String line : adbcmd.getExeResult().stdout) {
                    if (matched && (cmp = matchbr.readLine()) == null) {
                        if (hits != 0) {
                            System.out.println("cmp file is over, all items are matched! ");
                            setTempResult("PASS");
                            System.out.println("set result [PASS] in html file");
                            break;
                        }
                        System.out.println("RexFile is empty, please have a check!");
                        setTempResult("FAIL");
                    }
                    if (Pattern.compile(cmp).matcher(line).find()) {
                        hits++;
                        matched = true;
                    } else {
                        matched = false;
                    }
                }
                matchbr.close();
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        }
        /*use check string to match*/
        else {
            for (String line : adbcmd.getExeResult().stdout) {
                if (Pattern.compile(checkString).matcher(line).find()) {
                    hits++;
                }
                if (hits >= matchNum) {
                    System.out.println("check string [" + checkString + "] match, set result [true] in attribute ${atf_parse_result}");
                    setTempResult("PASS");
                    break;
                }
            }
            System.out.println("check string [" + checkString + "] match " + hits + " times!");

        }
    }

    public void parseResultDetail() throws BuildException {
        String resultDetail = "";
        AdbCmd adbcmd = new AdbCmd();
        adbcmd.setProject(this.getProject());
        adbcmd.setPrintStdOut(false);
        adbcmd.execute("adb logcat -d -s atf_result_detail");
        if (!adbcmd.getExeResult().stdout.isEmpty()) {
            for (String detail : adbcmd.getExeResult().stdout) {
                if (!detail.contains("beginning of")) {
                    resultDetail += detail + "; ";
                }
            }
        }
        setTempDetail(resultDetail);
//		adbcmd.execute("adb logcat -c");  //avoid same log be parsed twice!!
    }


    public void setParseTag(String tag) {
        if (!tag.equalsIgnoreCase("")) {
            this.tag = " -s " + tag;
        }
    }

    public void setParseRingBuffer(String buffer) {
        if (buffer.equalsIgnoreCase("radio")) {
            this.ringBuffer = " -b radio";
        } else if (buffer.equalsIgnoreCase("events")) {
            this.ringBuffer = " -b events";
        }
    }
}

