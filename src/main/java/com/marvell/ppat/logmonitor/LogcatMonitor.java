package com.marvell.ppat.logmonitor;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.Utils;
import com.marvell.ppat.listener.LogListener;
import com.marvell.ppat.listener.OutputListenerManager;
import com.marvell.ppat.resource.AdbResource;

import org.apache.tools.ant.BuildException;

import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.HashMap;

public class LogcatMonitor extends Thread implements LogMonitor {

    private OutputListenerManager listenerManager = null;
    private AdbResource lr;
    private boolean monitorFlag = false;
    private boolean runFlag = true;
    private String type;
    private String logcatCmd = "adb logcat -b";
    private String jobmonitorFlag = " ";
    private HashMap<String, LogListener> listenerMap = new HashMap<String, LogListener>();

    private LineNumberReader logInput = null;
    private Process process = null;

    public LogcatMonitor(AdbResource lr, boolean flag, String type) {
        this.listenerManager = lr.listenerManager;
        this.lr = lr;
        this.type = type;
    }

    public void run() {
        if (PPATProject.project.getProperty("multi_device").equalsIgnoreCase("true")) {
            logcatCmd = "adb -s " + PPATProject.project.getProperty("adb_device_id") + " " + logcatCmd.split("adb ")[1];
            jobmonitorFlag = "_" + PPATProject.project.getProperty("adb_device_id") + " ";
        }

        try {
            /* Here ehance for the default system logcat logs */
            process = Runtime.getRuntime().exec(PPATProject.project.getProperty("user.dir") + "/" + PPATProject.project.getProperty("jobmonitor")
                    + " -t 900 -n logcat_" + this.type + jobmonitorFlag + logcatCmd + " " + this.type + " -v threadtime");
            logInput = new LineNumberReader(new InputStreamReader(process.getInputStream()));

            while (monitorFlag) {
                if (runFlag) {
                    String str = null;
                    str = logInput.readLine();
                    if (str != null) {
                        listenerMap.get(this.type).process(str);
                    }

                } else {
                    logInput.readLine();
                }
            }

            Thread.sleep(2000);

        } catch (Exception e) {
            e.printStackTrace();
            throw new BuildException();
        }
    }

    public void startMonitor() {
        System.out.println("Start logcat monitor!!monitorFlag = " + monitorFlag);
        if (!monitorFlag) {
            System.out.println("Start logcat monitor!!");
            listenerManager = new OutputListenerManager(null);

            if (PPATProject.project.getProperty("case_name") != null) {
                LogListener ll = new LogListener(PPATProject.project.getProperty("case_root") + "/"
                        + PPATProject.project.getProperty("case_name")
                        + "_" + this.type + ".log");
                System.out.println("start log: " + PPATProject.project.getProperty("case_root") + "/"
                        + PPATProject.project.getProperty("case_name")
                        + "_" + this.type + ".log");
                listenerMap.put(this.type, ll);
                listenerManager.addListener(ll);

                monitorFlag = true;
                this.start();
            }
        }

    }


    public void stopMonitor() {
        if (monitorFlag) {
            System.out.println("Stop the monitor!!!" + this);
            monitorFlag = false;

            try {
                Utils.processExeCmd(PPATProject.project.getProperty("jobmonitor")
                        + " -k logcat_" + this.type + jobmonitorFlag);
                Thread.sleep(1000);

                if (process != null) {
                    process.destroy();
                }

                if (logInput != null) {
                    logInput.close();
                }

            } catch (IOException e) {
                // TODO Auto-generated catch block
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            listenerManager.cleanup();

            System.out.println("Start to wait thread finish.");
            System.out.println("Finish sync with the thread.");
        }
    }

    public void backupLog() {
        System.out.println("backup the logs!!!!");

        String fp = PPATProject.project.getProperty("case_root") + "/"
                + PPATProject.project.getProperty("case_name")
                + "_" + this.type + ".log";
        String fd = fp + "." + backupFileName(fp);
        File fl = new File(fp);

        if (fl.exists()) {
            if (fl.renameTo(new File(fd))) {
                System.out.println("Rename file " + fp + " to " + fd + " PASSED!!!");
            } else {
                System.out.println("Rename file " + fp + " to " + fd + " FAILED!!!");
            }
        } else {
            System.out.println("The log " + fp + " does not exist!");
        }

    }

    private String backupFileName(String fileName) {

        int num = 1;
        while (true) {
            if (new File(fileName + "." + num).exists()) {
                num++;
            } else {
                return num + "";
            }
        }
    }

    public void setRunFlag(boolean flag) {
        runFlag = flag;
    }

    public void setMonitorFlag(boolean flag) {
        monitorFlag = flag;
    }
}

