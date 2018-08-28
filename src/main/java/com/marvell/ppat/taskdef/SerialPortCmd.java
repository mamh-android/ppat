package com.marvell.ppat.taskdef;

import com.marvell.ppat.listener.ConsoleListener;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;

import org.apache.tools.ant.BuildException;

public class SerialPortCmd extends HostCmd {

    private String cmd = null;
    private String check = null;
    private int maxLine = 100;
    private boolean result = true;
    private SerialPortResource sr = (SerialPortResource) ResourceManager.getResource("serialport");

    @Override
    public void execute() throws BuildException {
        if (sr == null) {
            AdbCmd adb = new AdbCmd();
            adb.setProject(getProject());
            if (!cmd.equalsIgnoreCase("su")) {
                adb.setCmd("adb shell " + cmd);
                adb.execute();
            }
            System.out.println("Serialport not exist, use AdbCmd instead");
        } else {
            if (this.getProject().getProperty("LPM").equalsIgnoreCase("true")) {
                sr.runCmd("fkcmd", null); //for skip LPM first cmd missing
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            if (check != null) {
                result = sr.runCmd(cmd, check, maxLine);
            } else {
                result = sr.runCmd(cmd, null);
            }
        }
    }

    public void execute(String execmd) throws BuildException {
        setCmd(execmd);
        execute();
    }

    public void execute(String[] cmds) throws BuildException {
        for (int i = 0; i < cmds.length; i++) {
            setCmd(cmds[i]);
            execute();
        }
    }

    public void setCmd(String Cmd) {
        this.cmd = Cmd;
    }

    public void setCheckString(String check) {
        this.check = check;
    }

    public void setMaxLine(int num) {
        this.maxLine = num;
    }

    public void setPrintTag(String tag) {
        if (sr != null) {
            sr.addListener(new ConsoleListener(tag));
        }
    }

}
