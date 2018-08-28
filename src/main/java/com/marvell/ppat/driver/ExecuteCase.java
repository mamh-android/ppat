package com.marvell.ppat.driver;

import com.marvell.ppat.logger.Logger;
import com.marvell.ppat.logmonitor.LogMonitor;
import com.marvell.ppat.logmonitor.LogMonitorFactory;
import com.marvell.ppat.taskdef.SerialPortCmd;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DefaultLogger;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Ant;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Move;
import org.apache.tools.ant.types.FileSet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class ExecuteCase extends Ant {

    private Project caseProject;
    private int repeatCount = 1;
    private String caseName;
    private String path;
    private String caseFile;
    private long timeout;

    private SimpleDateFormat sdf;
    private int MODE = 0;
    private long startTime;
    private long endTime;
    private int COUNT = 0;

    DefaultLogger logger = new Logger();

    @Override
    public void execute() throws BuildException {
        setRepeatCount(caseProject.getProperty("count"));
        final ExecutorService executor = Executors.newSingleThreadExecutor();
        TaskThread taskThread = new TaskThread();
        FutureTask<String> taskFuture = (FutureTask<String>) executor.submit((Callable<String>) taskThread);
        executor.execute(taskFuture);
        this.timeout = 12 * 60 * 60;
        try {
            String result = taskFuture.get(timeout, TimeUnit.SECONDS);
            if (result.equals("true")) {
                System.out.println("**********************" + caseName + " is finish! **********************");
                endTime = System.currentTimeMillis();
                PrintColor.printGreen("============== Finish running the case =====================");
                PPATProject.project.setProperty("tune", "");

                long duration = (endTime - startTime) / 1000;
                StringBuilder sb = new StringBuilder();
                if (duration >= 86400) {
                    long day = duration / 864000;
                    if (day > 0) {
                        sb.append(day + " Day ");
                    }
                    duration -= day * 86400;
                }
                if (duration >= 3600) {
                    long hour = duration / 3600;
                    if (hour > 0) {
                        sb.append(hour + " Hour ");
                    }
                    duration -= hour * 3600;
                }
                if (duration >= 60) {
                    long min = duration / 60;
                    if (min > 0) {
                        sb.append(min + " Min ");
                    }
                    duration -= min * 60;
                }
                PrintColor.printGreen("============================================================");
                PrintColor.printGreen("||                Duration:" + sb.toString() + duration + " Sec                ");
                PrintColor.printGreen("============================================================");
                if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
                    PrintColor.printwhite("skip logcat");
                } else {
                    if (this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")) {
                        System.out.println("Start to shut down the service!");
                        executor.shutdown();
                        System.out.println("Shut down service finished!");
                        System.out.println("Start to set the result and clean the enviroment!");
                        new Thread(new Runnable() {

                            @Override
                            public void run() {
                                // TODO Auto-generated method stub
                                List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(PPATProject.project.getProperty("os"));
                                if (!logMonitorList.isEmpty()) {
                                    for (int i = 0; i < logMonitorList.size(); i++) {
                                        System.out.println("Stop the " + i + "logMonitor " + logMonitorList.get(i));
                                        logMonitorList.get(i).stopMonitor();
                                    }
                                }

                                LogMonitorFactory.clearLogMonitor();
                            }
                        }).start();

                        try {
                            Thread.sleep(5000);
                        } catch (InterruptedException e1) {
                            // TODO Auto-generated catch block
                            e1.printStackTrace();
                        }
                    }
                }

            }
        } catch (InterruptedException e) {
            taskFuture.cancel(true);
        } catch (ExecutionException e) {
            taskFuture.cancel(true);
            throw new BuildException(e.getMessage());
        } catch (TimeoutException e) {
            PrintColor.printRed(e.getMessage());
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public void setCaseProject(Project proj) {
        this.caseProject = proj;
    }

    public void setCaseFile(String file) {
        this.caseFile = file;
    }

    public void setCaseName(String name) {
        this.caseName = name;
    }

    public void setRepeatCount(String count) {
        if (count == null) {
        } else {
            this.repeatCount = Integer.valueOf(count);
            if (repeatCount > 1) {
                MODE = 1;
            }
        }
    }

    class TaskThread implements Future<String>, Callable<String> {

        @Override
        public String call() throws Exception {
            RunCase rc = new RunCase();
            rc.setProject(caseProject);
            rc.execute();
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
            return null;
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

    class RunCase extends Ant {
        @Override
        public void execute() throws BuildException {
            sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            PrintColor.printGreen("=============== Start to run the case ======================");
            /* prepare work */
            prepare();
            /* execution */
            switch (MODE) {
                case 0:
                    myExecute(0);
                    break;
                case 1:
                    for (int count = 1; count <= repeatCount; count++) {
                        try {
                            PrintColor.printGreen("=============== Start Run " + count + " time        ===============");
                            myExecute(count);
                            PrintColor.printGreen("=============== Run the " + count + " time passed!! ===============");
                        } catch (BuildException e) {
                            PrintColor.printGreen("=============== Run the " + count + " time failed!! ===============");
                            throw e;
                        }
//					if(!myExecute(count)){
//						break;
//					}
                    }
                    break;
            }

        }
    }

    private void myExecute() throws BuildException {
        /* prepare log monitor */
        setup();
        try {
            SerialPortCmd serial = new SerialPortCmd();
            serial.setProject(this.getProject());
            serial.execute("start run " + caseName);
            caseProject.executeTarget(caseProject.getDefaultTarget());
            serial.execute("finish run " + caseName);
        } catch (BuildException e) {
            caseProject.executeTarget(caseProject.getDefaultTarget());
        }
    }

    private void myExecute(int count) throws BuildException {
        COUNT++;
        File subCaseFolder = new File(path + "/" + COUNT);
        if (subCaseFolder.exists()) {
            subCaseFolder = new File(path + "/" + (++COUNT));
            this.getProject().setProperty("subcase_root", path + "/" + (COUNT));// update run case folder
        } else {
            subCaseFolder.mkdirs();
            this.getProject().setProperty("subcase_root", path + "/" + COUNT);// update run case folder
        }
        PPATProject.project.setProperty("case_subdir", "" + COUNT);

        myExecute();

        /*just move log to right place*/
        Move moveLog = new Move();
        moveLog.setProject(this.getProject());
        moveLog.setTodir(new File(this.getProject().getProperty("subcase_root")));
        FileSet fl = new FileSet();
        fl.setDir(new File(this.getProject().getProperty("case_root")));
        fl.setIncludes("*.log");
        moveLog.addFileset(fl);
        moveLog.execute();

        /* copy for remote visit */
        if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
            PrintColor.printRed(this, "in local PPAT, skip copy remote");
        } else {
            Copy copy = new Copy();
            copy.setProject(this.getProject());
            copy.setTaskName("copy");
            FileSet fs = new FileSet();
            fs.setDir(new File(this.getProject().getProperty("root") + "/result/" + this.getProject().getProperty("run_time")));
            copy.addFileset(fs);
            copy.setTodir(new File(this.getProject().getProperty("backup_remote") + "/result/" + this.getProject().getProperty("run_time"))); // to runtime folder
            try {
                copy.execute();
            } catch (BuildException e) {

            }

        }
    }


    protected void setup() {
        File outfile = new File(path + "/" + caseName + ".log");
        try {
            PrintStream out = new PrintStream(new FileOutputStream(outfile));
            out = new PrintStream(new FileOutputStream(outfile));

            logger.setMessageOutputLevel(Project.MSG_INFO);
            logger.setOutputPrintStream(out);
            logger.setErrorPrintStream(out);
            this.getProject().addBuildListener(logger);
//	        PPATProject.project.addBuildListener(logger);
        } catch (IOException ex) {
            log("Ant: Can't set output to ");
        }

        PrintColor.printwhite(this, "[COUNTER] current is executing NO." + COUNT);
        PrintColor.printGreen("============================================================");
        PrintColor.printGreen("||                " + caseName + " is start!                ");
        PrintColor.printGreen("============================================================");

        /*record start time*/
        startTime = System.currentTimeMillis();
        caseProject.setProperty("case_starttime", String.valueOf(startTime));


    }

    protected void prepare() {
        path = PPATProject.project.getProperty("result_root") + caseName;
        caseProject.setProperty("case_root", path);//runtime case result folder
        caseProject.setProperty("subcase_root", path);//default equals to case_root, change when count increase
        caseProject.setProperty("case_name", caseName);
        caseProject.setProperty("case_result_dir", caseProject.getProperty("log_path")
                + "result\\" + caseProject.getProperty("run_time") + "\\" + caseName);
        PPATProject.project.setProperty("case_root", path);//runtime case result folder
        PPATProject.project.setProperty("case_path", caseProject.getProperty("basedir"));
        PPATProject.project.setProperty("subcase_root", path);//default equals to case_root, change when count increase
        PPATProject.project.setProperty("case_name", caseName);
        PPATProject.project.setProperty("case_result_dir", this.getProject().getProperty("log_path")
                + "result\\" + this.getProject().getProperty("run_time") + "\\" + caseName);


        /* create runtime folder */
        File caseFolder = new File(path);
        caseFolder.mkdirs();

        /* copy.atf.xml */
        Copy copy = new Copy();
        copy.setProject(this.getProject());
        copy.setTaskName("copy");
        copy.setFile(new File(caseFile));
        copy.setTodir(caseFolder); // to runtime folder
        copy.execute();
        System.out.println("COPY ANT file DONE!!!!");

        if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
            PrintColor.printwhite("skip logcat");
        } else {
            if (this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")) {
                /*start monitor log*/
                new Thread(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(PPATProject.project.getProperty("os"));
                        if (!logMonitorList.isEmpty()) {
                            for (int i = 0; i < logMonitorList.size(); i++) {
                                System.out.println("Ready to start the " + i + " logcat monitor " + logMonitorList.get(i));

                                logMonitorList.get(i).startMonitor();
                            }
                        }
                    }
                }).start();

            }
        }
    }

}
