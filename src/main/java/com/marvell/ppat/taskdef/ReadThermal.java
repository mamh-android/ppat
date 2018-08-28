package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.util.ArrayList;

public class ReadThermal extends Task {

    private String flag;

    private static String THERMAL_PATH = "/sys/class/thermal/";

    public void setFlag(String flag) {
        this.flag = flag;
    }

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        AdbCmd read = new AdbCmd();
        read.setPrintStdErr(true);
        read.setPrintStdOut(true);
        read.setTimeout(15);
        read.setProject(this.getProject());
        CmdExecutionResult result;
        ArrayList<String> info;
        StringBuilder sb = new StringBuilder();
        read.execute("adb shell ls " + THERMAL_PATH + " | grep thermal_zone");

        try {
            result = read.getExeResult();
            info = result.stdout;
            for (String zone : info) {
                read.execute("adb shell cat " + THERMAL_PATH + zone + "/type");
                result = read.getExeResult();
                info = result.stdout;
                for (String type : info) {
                    sb.append(type).append(" temp: ");
                }

                read.execute("adb shell cat " + THERMAL_PATH + zone + "/temp");
                result = read.getExeResult();
                info = result.stdout;
                for (String temp : info) {
                    sb.append(temp).append("\n");
                }
            }
        } catch (Exception e) {

        }


        PPATProject.project.setProperty(flag, sb.toString());
    }
}
