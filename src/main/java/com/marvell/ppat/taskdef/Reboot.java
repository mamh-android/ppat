package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.PPATExceptionHandler;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.listener.OutputListener;
import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.RelayResource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Reboot extends Task {

    private String rebootPSString = "^1$";// "com.android.deskclock";
    private String type = "hw"; // default
    private boolean handleEx = true;
    private static int BOOTUP_CHECK_COUNT = 100;
    // final private int waitTime = 60000;
    private String scriptPath = "autoburn/script/";
    private boolean withoutPrepareBoard = false; // default need prepare the
    // board after boot up
    private boolean bootUp = true; // default need check the board boot up

    private class SerialPortOutListener implements OutputListener {
        private final static String PARSE_STRING_1 = "Detect RAMDUMP signature.*";

        @Override
        public void process(String line) {
            // TODO Auto-generated method stub
            // start measure power
            if (Pattern.compile(PARSE_STRING_1).matcher(line).find()) {
                // whether need to input uboot commands
                System.out.println("find " + PARSE_STRING_1
                        + ", reset again!!!!");
                resetInUboot();
            }
        }

        @Override
        public boolean getResult() {
            // TODO Auto-generated method stub
            return false;
        }

        @Override
        public void cleanup() {
            // TODO Auto-generated method stub

        }
    }

    private void resetInUboot() {
        RelayResource relay = (RelayResource) ResourceManager
                .getResource("relay");
        LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");
        if (ltk == null) {
            if (relay == null) {
                throw new BuildException("no realy resource");
            }
            String port = relay.getPort(); // resource serial port
            // number
            String resetPort = "";
            if (this.getProject().getProperty("relay_reset") != null) {
                System.out
                        .println("this.getProject().getProperty(relay_reset)="
                                + PPATProject.project
                                .getProperty("relay_reset"));
                resetPort = PPATProject.project.getProperty("relay_reset");
            }

            if (resetPort.equalsIgnoreCase("")) {
                throw new BuildException(
                        "Relay port user setting error, DKB reset didn't set relay port!!");
            } else {
                try {
                    HostCmd gc = new HostCmd();
                    gc.setProject(PPATProject.project);
                    System.out.println("The relay reset reboot command is "
                            + " tools/relay " + resetPort + " 1");
                    gc.execute("./tools/relay " + resetPort + " 1");
                    Thread.sleep(1000);
                    System.out.println("The relay reset reboot command is "
                            + " tools/relay " + resetPort + " 0");
                    gc.execute("./tools/relay " + resetPort + " 0");
                } catch (Exception ee) {
                    throw new BuildException(
                            "Relay reboot in reboot task FAILED!!");
                }
            }
        } else {
            LTKCmd ltkcmd = new LTKCmd();
            ltkcmd.setCmd("reset");
            ltkcmd.execute();
        }
    }

    private void reset(RelayResource relay, LTKResource ltk) {
        if (this.type == null) {
            if (relay == null) {
                this.type = "adb";
            } else {
                this.type = "hw";
            }

        }
        if (type.equalsIgnoreCase("adb")) {
            log("Reboot the device from adb!!", 2);
            AdbCmd gcmd = new AdbCmd();
            gcmd.setProject(this.getProject());
            gcmd.execute("adb reboot");

            if (ltk != null) {
                LTKCmd ltkcmd = new LTKCmd();

                ltkcmd.setCmd("vbus 0");
                ltkcmd.execute();
            }
        } else if (type.equalsIgnoreCase("hw")) {
            log("Reboot the device from hw!!", 2);
            /* send reboot cmd from relay */
            // RelayResource relay = (RelayResource)
            // ResourceManager.getResource("relay");
            PowerCtrlUSB ctrlUSB = new PowerCtrlUSB();
            ctrlUSB.setProject(getProject());
            ctrlUSB.setFlag("off");
            ctrlUSB.execute();

            EnterUboot enter = new EnterUboot();
            enter.setProject(getProject());
            enter.execute();

            try {
                Thread.sleep(30000);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            SerialPortCmd serial = new SerialPortCmd();
            serial.setProject(getProject());
            System.out.println("setenv in uboot...");
            if (this.getProject().getProperty("platform").contains("eden")) {
                serial.execute("setenv bootargs ${bootargs} etm_trace=0x0");
                serial.execute("saveenv");
                serial.execute("boot");
            }

            try {
                Thread.sleep(10000);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            ctrlUSB.setFlag("on");
            ctrlUSB.execute();
        }
    }

    private boolean isBootCompleted(SerialPortResource sr) {
        for (int i = 0; i <= BOOTUP_CHECK_COUNT; i++) {
            if (ResourceManager.getResource("serialport") != null) {
                if (sr.runCmd("getprop sys.boot_completed", rebootPSString,
                        3, true)) {
                    System.out.println("Reboot device succeed!!");
                    System.out
                            .println("This is the "
                                    + i
                                    + " times to get the status of the device after reboot!!");
                    break;
                } else if (i == BOOTUP_CHECK_COUNT) {
                    log("reboot device failed!!", 2);
                    return false;
                } else {
                    sr.runCmd("boot", "start", 3);
                    try {
                        Thread.sleep(3500);
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
                System.out
                        .println("Retry to check reboot completed or not "
                                + i + " times");
            } else {
                AdbCmd adb = new AdbCmd();
                adb.setProject(getProject());
                adb.setCmd("adb shell getprop sys.boot_completed");
                adb.execute();

                ArrayList<String> out = adb.getExeResult().stdout;
                Pattern pattern = Pattern.compile(rebootPSString);
                boolean is_boot_cmp = false;
                for (String bc : out) {
                    Matcher matcher = pattern.matcher(bc);
                    if (matcher.find()) {
                        is_boot_cmp = true;
                    }
                }

                if (is_boot_cmp) {
                    break;
                } else if (i == BOOTUP_CHECK_COUNT) {
                    return false;
                }

                System.out
                        .println("Retry to check reboot completed or not "
                                + i + " times");
            }

        }
        return true;
    }

    @Override
    public void execute() throws BuildException {
        try {
            SerialPortResource sr = (SerialPortResource) ResourceManager
                    .getResource("serialport");
            RelayResource relay = (RelayResource) ResourceManager
                    .getResource("relay");
            LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");

            if (sr != null) {
                sr.addListener(new SerialPortOutListener());
            }

            System.out.println("Rebooting ......");
            reset(relay, ltk);

            /* sleep sometime then check the reboot device status */
            Thread.sleep(15000);

            if (this.getProject().getProperty("bootUpChk") != null && this.getProject().getProperty("bootUpChk") == "false") {
                System.out.println("Reboot device without wait the device boot up!!");
                return;
            }

            if (this.getProject().getProperty("platform").contains("hln3")) {
                LTKCmd ltkcmd = new LTKCmd();

                ltkcmd.setCmd("onkey");
                ltkcmd.execute();
            }

            // start to check reboot completed or not
            log("Start to check reboot completed or not by serial prot...",
                    Project.MSG_INFO);

            if (!isBootCompleted(sr)) {
                //try again
                reset(relay, ltk);
                Thread.sleep(15000);
                if (!isBootCompleted(sr)) {
                    PPATExceptionHandler.handleException("After reboot device, can't boot up!! ");
                }
            }

            if (withoutPrepareBoard) {
                System.out.println("Reboot the device without prepare board!");
                return;
            }

            if (ltk != null) {
                LTKCmd ltkcmd = new LTKCmd();

                ltkcmd.setCmd("vbus 1");
                ltkcmd.execute();
            }
            if (this.getProject().getProperty("platform").contains("ulc1ff")) {
                HostCmd gc = new HostCmd();
                gc.setProject(PPATProject.project);
                String usbPort = PPATProject.project.getProperty("relay_usb");
                System.out.println("The relay reset reboot command is "
                        + " tools/relay " + usbPort + " 1");
                gc.execute("./tools/relay " + usbPort + " 1");
            }

            PrepareBoard pb = new PrepareBoard();
            pb.setProject(this.getProject());
            pb.execute();

            this.getProject().setProperty("reboot_completed", "true");
        } catch (Exception ex) {
            ex.printStackTrace();
            if (handleEx) {
                throw new BuildException(ex);
            }
        }
    }

    public void setCheckBootUp(String check) {
        this.bootUp = Boolean.getBoolean(check);
    }

    public void setType(String type) {
        this.type = type;
    }
}
