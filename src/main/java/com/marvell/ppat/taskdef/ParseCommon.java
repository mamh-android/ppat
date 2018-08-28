package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.util.HashMap;

public abstract class ParseCommon extends Task implements Parser {

    protected boolean reverse = false;
    protected String checkString = null;
    protected int matchNum = 1;
    protected String rexFile = null;
    protected String tempResultKey = "atf_tmp_result";
    protected String tempDetailKey = "atf_tmp_detail";
    protected String dependsTempResult = null;
    protected StringBuffer extDataBuffer = new StringBuffer();

    protected HashMap<String, String> extKeyValue = new HashMap<String, String>();// add by lizhen for support more parsing string

    public void execute() throws BuildException {
        try {
            if (dependsTempResult == null) {  //this null is set after judge already
                setTempResult("FAIL");
                setTempDetail("N/A");
                parseResult();
                parseResultDetail();
            } else {
                setTempResult("FAIL");
                this.getProject().setProperty(tempDetailKey, "set tmp result to [FAIL] due to the depends!");
            }
        } catch (BuildException e) {
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * template method should overwrite by subclass
     */
    public abstract void parseResult() throws BuildException;

    public abstract void parseResultDetail() throws BuildException;


    protected String getDependsTempResult(String depends) {
        return this.getProject().getProperty(depends);
    }

    protected void setTempResult(String tmpResult) {
        if (dependsTempResult == null && reverse) {
            if (tmpResult.equalsIgnoreCase("PASS")) {  //means found error info in log
                tmpResult = "FAIL";
            } else {
                tmpResult = "PASS";
            }
        }
        this.getProject().setProperty(tempResultKey, tmpResult);
    }

    protected String getTempResult() {
        return this.getProject().getProperty(tempResultKey);
    }

    protected void setTempDetail(String tmpDetail) {
        this.getProject().setProperty(tempDetailKey, tmpDetail);
    }

    protected String getTempDetail() {
        return this.getProject().getProperty(tempDetailKey);
    }

    protected StringBuffer getTempExtData() {
        return extDataBuffer;
    }

    protected void addTempExtData(String extdata) {
        extDataBuffer.append(extdata);
    }


    /* interface for user */
    public void setCheckString(String checkString) {
        this.checkString = checkString;
    }

    public void setValue(String key, String value) {
        extKeyValue.put(key, value);
    }

    public String getValue(String key) {
        return extKeyValue.get(key);
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

    /**
     * tmp result will be save in this property *
     *
     * @param resultkey
     */
    public void setTempResultProperty(String resultkey) {
        this.tempResultKey = resultkey;
    }

    /**
     * tmp detail will be save in this property *
     *
     * @param detailkey
     */
    public void setTempDetailProperty(String detailkey) {
        this.tempDetailKey = detailkey;
    }

    public void setDependsTempResult(String dependsTempResult) {
        if (!this.getDependsTempResult(dependsTempResult).equalsIgnoreCase("PASS")) {
            this.dependsTempResult = dependsTempResult;
        }

    }
}
