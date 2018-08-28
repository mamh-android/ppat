package com.marvell.ppat.taskdef;

import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class StayAwake extends Task {
    private String flag_ = "true";
    private String cmd = "svc power stayon ";

    public void setFlag(String flag) {
        this.flag_ = flag;
    }

    @Override
    public void execute() throws BuildException {
        System.out.println("stayawake");
        try {
            if (ResourceManager.getResource("adb") != null) {
                AdbCmd gcmd = new AdbCmd();
                gcmd.setProject(this.getProject());
                gcmd.execute("adb shell " + cmd + flag_);
            } else if (ResourceManager.getResource("serialport") != null) {
                SerialPortResource sr = (SerialPortResource) ResourceManager.getResource("serialport");
                sr.runCmd(cmd + flag_, null);
            }
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
