package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class SystemSetting extends Task {
    private String type = null;
    private String method = null;
    private String extraKey = null;
    private String extraValue = null;
    //	private boolean bvalue = false;
    private int ivalue = 0;
    private String cmd = cmd_prefix;
    private static String cmd_prefix = "am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER" +
            " -n com.marvell.ssv.pat/.PATEntryActivity";


    public void execute() throws BuildException {
        SerialPortCmd execmd = new SerialPortCmd();
        execmd.setProject(this.getProject());

        this.cmd = this.cmd + " -e method " + this.method;

        if (type.equalsIgnoreCase("string")) {
            this.cmd = this.cmd + " -e " + extraKey + " " + extraValue;
        } else if (type.equalsIgnoreCase("boolean")) {
            this.cmd = this.cmd + " --ez " + extraKey + " " + extraValue;
        } else if (type.equalsIgnoreCase("int")) {
            this.cmd = this.cmd + " --ei " + extraKey + " " + extraValue;
        }
        execmd.execute(cmd);
    }


    public void setMethod(String method) {
        this.method = method;
    }

    public void setValueType(String type) {
        this.type = type;
    }

    public void setExtraValue(String extraValue) {
        this.extraValue = extraValue;
    }

    public void setExtraKey(String key) {
        this.extraKey = key;
    }
}
