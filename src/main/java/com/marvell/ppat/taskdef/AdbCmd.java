package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.resource.AdbResource;
import com.marvell.ppat.resource.ResourceManager;

import org.apache.tools.ant.BuildException;

import java.util.ArrayList;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.regex.Pattern;

public class AdbCmd extends HostCmd {
    protected String showCmd = "";
    protected boolean showFlag = false;
    protected String parseString = "";
    protected String tempResultProperty = "";

    public void setParseString(String parseString) {
        this.parseString = parseString;
    }

    public void setTempResultProperty(String tempResultProperty) {
        this.tempResultProperty = tempResultProperty;
    }

    class TaskThread implements Future<String>, Callable<String> {
        public String call() throws BuildException {
            exeAdbCmd();
            return "true";
        }

        @Override
        public boolean cancel(boolean arg0) {
            // TODO Auto-generated method stub
            return false;
        }

        @Override
        public String get() throws InterruptedException, ExecutionException {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public String get(long arg0, TimeUnit arg1)
                throws InterruptedException, ExecutionException,
                TimeoutException {
            // TODO Auto-generated method stub
            return "true";
        }

        @Override
        public boolean isCancelled() {
            // TODO Auto-generated method stub
            return false;
        }

        @Override
        public boolean isDone() {
            // TODO Auto-generated method stub
            return false;
        }
    }

    public void exeAdbCmd() throws BuildException {
        if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
            PrintColor.printRed("in local PPAT, not execute adb cmd: " + showCmd);
        } else {
            AdbResource lr = (AdbResource) ResourceManager
                    .getResource("adb");// check adb resource
            if (lr == null) {
                throw new BuildException("no adb resource found!");
            }
            for (int i = 1; i <= 5; i++) {
                try {
                    super.execute();
                    CmdExecutionResult result;
                    result = this.getExeResult();
                    ArrayList<String> chkStr = result.stdout;
                    for (String str : chkStr) {
                        if (Pattern.compile(parseString).matcher(str)
                                .find()) {
                            this.getProject().setProperty(
                                    tempResultProperty, str);
                        }
                    }
                    if (getExeResult().stderr.toString().contains(
                            "error: device not found")
                            || getExeResult().stdout.toString().contains(
                            "error: device not found")) {
                        PrintColor.printRed("Adb can not work while executing adb command!!");
                        PowerCtrlUSB usb_off = new PowerCtrlUSB();
                        usb_off.setProject(PPATProject.project);
                        usb_off.setFlag("on");
                        usb_off.execute();
                        throw new BuildException("Found an adb exception!!");
                    }
                    break;
                } catch (BuildException e) {
                    if (i == 5) {
                        PrintColor.printYellow("Adb exception still exist after retry 5 times");
                        throw e;
                    }

                    PowerCtrlUSB usb = new PowerCtrlUSB();
                    usb.setProject(PPATProject.project);
                    usb.setFlag("on");
                    usb.execute();

                    try {
                        Thread.sleep(3 * 1000);
                    } catch (InterruptedException ex) {
                        // TODO Auto-generated catch block
                        ex.printStackTrace();
                    }

                    HostCmd hostCmd = new HostCmd();
                    hostCmd.setProject(PPATProject.project);
                    hostCmd.execute("adb devices");
                    CmdExecutionResult result;
                    result = hostCmd.getExeResult();
                    String device_id = PPATProject.project.getProperty("adb_device_id");
                    ArrayList<String> devices = result.stdout;
                    boolean find_device = false;
                    for (String str : devices) {
                        if (!str.contains("List of devices attached")) {
                            if (device_id != null && str.contains(device_id)) {
                                find_device = true;
                            }
                        }
                    }
                    if (find_device) {
                        PPATProject.project.setProperty("multi_device", "true");
                        if (this.getProject().getProperty("multi_device") != null && this.getProject().getProperty("multi_device")
                                .equalsIgnoreCase("true")) {
                            cmd = "adb -s " + this.getProject().getProperty("adb_device_id")
                                    + " " + cmd.split("adb ")[1];
                        }
                        super.setCmd(cmd);
                    }

                    if (getExeResult().stderr.toString().contains(
                            "error: device not found")
                            || getExeResult().stdout.toString().equals(
                            "[unknown]")) {
                        try {
                            Thread.sleep(3000);
                        } catch (InterruptedException e1) {
                            // TODO Auto-generated catch block
                            e1.printStackTrace();
                        }
                    } else {
                        throw e;
                    }
                }

            }
        }
    }

    @Override
    public void execute() throws BuildException {
        final ExecutorService executor = Executors.newSingleThreadExecutor();
        TaskThread taskThread = new TaskThread();
        FutureTask<String> taskFuture = (FutureTask<String>) executor
                .submit((Callable<String>) taskThread);
        try {
            executor.execute(taskFuture);
            String result = taskFuture.get(timeout, TimeUnit.SECONDS);
            if (result.equals("true")) {
                // do nothing
            }
        } catch (InterruptedException e) {
            taskFuture.cancel(true);
        } catch (ExecutionException e) {
            taskFuture.cancel(true);
            throw new BuildException(e.getMessage());
        } catch (TimeoutException e) {
            PrintColor.printRed(this, "Execute adb command timeout!!! This executing will be canceled!");
            taskFuture.cancel(true);
            throw new BuildException(e.getMessage());
        }
    }

    public void execute(String execmd) throws BuildException {
        setCmd(execmd);
        execute();
    }

    public void setCmd(String cmd) {
        if (this.getProject().getProperty("multi_device") != null && this.getProject().getProperty("multi_device")
                .equalsIgnoreCase("true")) {
            cmd = "adb -s " + this.getProject().getProperty("adb_device_id")
                    + " " + cmd.split("adb ")[1];
        }
        this.showCmd = cmd;
        super.setWorkingDirectory(this.getProject().getBaseDir().toString());
        super.setCmd(cmd);
    }

    public void setShowFlag(boolean showFlag) {
        this.showFlag = showFlag;
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

}
