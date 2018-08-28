package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.PPATProject;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.util.ArrayList;

public class StatDutyCycle extends Task {

    public static String DC_PREFIX = "/sys/kernel/debug/pxa/stat/";
    public static ArrayList<String> DC_STAT_NODES;

    public StatDutyCycle() {
        super();
        DC_STAT_NODES = new ArrayList<String>();
        DC_STAT_NODES.add(DC_PREFIX + "cpu_dc_stat");
        DC_STAT_NODES.add(DC_PREFIX + "axi_dc_stat");
        DC_STAT_NODES.add(DC_PREFIX + "ddr_dc_stat");
        DC_STAT_NODES.add(DC_PREFIX + "gc2d_core0_dc_stat");
        DC_STAT_NODES.add(DC_PREFIX + "gc3d_core0_dc_stat");
        DC_STAT_NODES.add(DC_PREFIX + "gcsh_core0_dc_stat");
        if (PPATProject.project.getProperty("platform").contains("eden")) {
            DC_STAT_NODES.add(DC_PREFIX + "vpu_dec_dc_stat");
            DC_STAT_NODES.add(DC_PREFIX + "vpu_enc_dc_stat");
        } else {//helan*
            DC_STAT_NODES.add(DC_PREFIX + "vpu_dc_stat");
        }
        DC_STAT_NODES.add("/sys/kernel/debug/pxa/vlstat/vol_dc_stat");
    }

    protected String state = "0";
    protected String sleep = "";
    protected String type = "serialport";

    public void setState(String state) {
        this.state = state;
    }

    public void setSleep(String sec) {
        this.sleep = sec;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        SerialPortCmd sc = new SerialPortCmd();
        sc.setProject(this.getProject());
        AdbCmd adb = new AdbCmd();
        adb.setProject(getProject());

        if (state.equals("0")) {
            for (String dcnode : DC_STAT_NODES) {
                if (sleep != "") {
                    sc.setCmd("sleep " + sleep + " && echo 0 > " + dcnode + " &");
                    sc.execute();
                } else {
                    if (type.equalsIgnoreCase("serialport")) {
                        sc.setCmd("echo 0 > " + dcnode);
                        sc.execute();
                    } else {
                        adb.setCmd("adb shell  " + "echo 0 > " + dcnode);
                        adb.execute();
                    }
                }
            }
        } else {
            for (String dcnode : DC_STAT_NODES) {
                if (sleep != "") {
                    sc.setCmd("sleep " + sleep + " && echo 1 > " + dcnode + " &");
                    sc.execute();
                } else {
                    if (type.equalsIgnoreCase("serialport")) {
                        sc.setCmd("echo 1 > " + dcnode);
                        sc.execute();
                    } else {
                        adb.setCmd("adb shell  " + "echo 1 > " + dcnode);
                        adb.execute();
                    }
                }
            }
        }
    }
}
