package com.marvell.ppat.driver;

import com.marvell.ppat.resource.AdbResource;
import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.RelayResource;
import com.marvell.ppat.resource.SerialPortResource;
import com.marvell.ppat.taskdef.PowerCtrlUSB;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class CreateResource extends Task {

    private String name_ = ""; // unique ID in ATF

    /* must give default value */
    private String port_ = null;
    private String rate_ = "115200";
    private String remoteip_ = null;
    private String user_ = null;
    private String pw_ = null;
    private boolean getDeviceInfoFlag = false;

    public void execute() throws BuildException {
        name_ = name_.toLowerCase();

        if (name_.equalsIgnoreCase("adb")) {
            if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
                PrintColor.printRed(this, "Run PPAT with local mode, skip init adb");
            } else {
                new AdbResource(name_);
            }
        } else if (name_.equalsIgnoreCase("serialport")) {
            if (getDeviceInfoFlag) {
                String port = PPATProject.project.getProperty("serial_port");
                if (!port.contains("/dev/tty")) {
                    port = "/dev/tty" + port;
                }
                String rate = "115200";
                new SerialPortResource(port, Integer.valueOf(rate), name_, getDeviceInfoFlag);
            } else {
                String port = PPATProject.project.getProperty("serial_port");
                if (!port.contains("/dev/tty")) {
                    port = "/dev/tty" + port;
                }
                String rate = "115200";
                new SerialPortResource(port, Integer.valueOf(rate), name_);
            }
        } else if (name_.equalsIgnoreCase("relay")) {
            //new SerialPortResource(port_, 9600, name_);
            if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
                PrintColor.printRed(this, "Run PPAT with local mode, skip init relay");
            } else {
                new RelayResource(port_, Integer.valueOf(rate_), name_, user_);
                if (!this.getProject().getProperty("usb_port").equalsIgnoreCase("None")) {
                    PPATProject.project.setProperty("relay_usb", this.getProject().getProperty("usb_port"));
                }
                if (!this.getProject().getProperty("reset_port").equalsIgnoreCase("None")) {
                    PPATProject.project.setProperty("relay_reset", this.getProject().getProperty("reset_port"));
                }
                if (!this.getProject().getProperty("back_port").equalsIgnoreCase("None")) {
                    PPATProject.project.setProperty("relay_back", this.getProject().getProperty("back_port"));
                }
                PowerCtrlUSB ctrlUSB = new PowerCtrlUSB();
                ctrlUSB.setProject(getProject());
                ctrlUSB.setFlag("on");
                ctrlUSB.execute();
            }

        } else if (name_.equalsIgnoreCase("ltk")) {
            new LTKResource("ltk");
        }
    }

    public void setName(String name) {
        this.name_ = name;
    }

    public void setPort(String port) {
        this.port_ = port;
    }

    public void setRate(String rate) {
        this.rate_ = rate;
    }

    public void setRemoteip(String remoteip) {
        this.remoteip_ = remoteip;
    }

    public void setUser(String user) {
        this.user_ = user;
    }

    public void setPw(String pw) {
        this.pw_ = pw;
    }

    public void setSpecFlag(boolean flag) {
        this.getDeviceInfoFlag = flag;
    }

    public String getResourceName() {
        return this.name_;
    }
}
