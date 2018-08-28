package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.text.SimpleDateFormat;
import java.util.Date;


public abstract class CommonResult extends Task implements Parser {

    protected String result = "FAIL";
    protected String resultDetail = "N/A";
    protected boolean reverse = false;
    protected String checkString = "OK";
    protected int matchNum = 1;
    protected String rexFile = null;

    protected String extendData = "";

    protected String caseName;
    protected String folder;
    protected String jobid;


    protected SimpleDateFormat df;
    protected String finishTime;
    protected String startTime;

    @Override
    public void execute() throws BuildException {
        try {
            /* prepare case result info */
            caseName = this.getProject().getProperty("case_name");
            folder = this.getProject().getProperty("subcase_root");

            df = new SimpleDateFormat("HH:mm:ss");
            finishTime = df.format(new Date(System.currentTimeMillis()));
            startTime = df.format(Long.valueOf(this.getProject().getProperty(
                    "case_starttime")));


            generateResult();
            generateReport();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public abstract void generateResult() throws Exception;

    public abstract void generateReport() throws BuildException;

    protected void addTempExtData(String extData) {
        extendData = extendData + extData;
    }

    /*interface for user*/
    public void setCheckString(String checkString) {
        this.checkString = checkString;
    }

    public void setMatchNum(int matchNum) {
        this.matchNum = matchNum;
    }

    public void setRexFile(String rexFile) {
        this.rexFile = rexFile;
    }

    public void setReverse(boolean reverse) {
        this.reverse = reverse;
    }
}
