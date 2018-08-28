package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.listener.OutputListener;
import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.RelayResource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;
import com.marvell.ppat.taskdef.power.MeasurePower;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.util.regex.Pattern;


public class EnterUboot extends Task {
    private String type = "hw"; // default

    private class SerialPortOutListener implements OutputListener {
        private final static String PARSE_STRING_1 = "Net:   usb_ether";
        private final static String PARSE_STRING_2 = "Detect RAMDUMP signature.*";

        @Override
        public void process(String line) {
            // TODO Auto-generated method stub
            //start measure power
            if (Pattern.compile(PARSE_STRING_1).matcher(line).find()) {
                //whether need to input uboot commands
                runserialportCmd("enter", null, 0);
                runserialportCmd("enter", null, 0);
            }
            if (Pattern.compile(PARSE_STRING_2).matcher(line).find()) {
                //whether need to input uboot commands
                System.out.println("find " + PARSE_STRING_2 + ", reset again!!!!");
                reset();
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

    private void runserialportCmd(String cmd, String checkstring, int maxline)
            throws BuildException {
        SerialPortCmd spc = new SerialPortCmd();
        spc.setProject(this.getProject());
        spc.setCheckString(checkstring);
        if (maxline != 0) {
            spc.setMaxLine(maxline);
        }
        spc.execute(cmd);
    }

    private void reset() {
        RelayResource relay = (RelayResource) ResourceManager
                .getResource("relay");
        LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");
        if (ltk == null) {
            if (relay == null) {
                throw new BuildException("no realy resource");
            }
            String resetPort = "";
            if (this.getProject().getProperty("relay_reset") != null) {
                System.out
                        .println("this.getProject().getProperty(relay_reset)="
                                + PPATProject.project.getProperty(
                                "relay_reset"));
                resetPort = PPATProject.project.getProperty(
                        "relay_reset");
            }

            if (resetPort.equalsIgnoreCase("")) {
                throw new BuildException(
                        "Relay port user setting error, DKB reset didn't set relay port!!");
            } else {
                try {
                    if (this.getProject().getProperty("platform").contains("ulc1ff")) {
                        MeasurePower power = new MeasurePower();
                        power.setProject(getProject());
                        power.setSample_t("2");
                        String port = this.getProject().getProperty("power_port");
                        power.setSave_f("power_" + port);
                        power.setServer(this.getProject().getProperty("power_server"));
                        power.setPort(port);
                        power.setVoltage("0");
                        power.execute();

                        Thread.sleep(5000);
                        power.setVoltage("4");
                        power.execute();
                        Thread.sleep(5000);
                    }
                    HostCmd gc = new HostCmd();
                    gc.setProject(this.getProject());
                    System.out
                            .println("The relay reset reboot command is "
                                    + " tools/relay "
                                    + resetPort
                                    + " 1");
                    gc.execute("./tools/relay " + resetPort + " 1");
                    Thread.sleep(5000);
                    System.out
                            .println("The relay reset reboot command is "
                                    + " tools/relay "
                                    + resetPort
                                    + " 0");
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

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        SerialPortResource sr = (SerialPortResource) ResourceManager
                .getResource("serialport");
        if (sr != null) {
            sr.addListener(new SerialPortOutListener());
        }

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        reset();

        try {
            Thread.sleep(15000);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}
