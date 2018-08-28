package com.marvell.ppat.driver;

import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.RelayResource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.taskdef.AdbCmd;
import com.marvell.ppat.taskdef.HostCmd;
import com.marvell.ppat.taskdef.LTKCmd;
import com.marvell.ppat.taskdef.PowerCtrlUSB;
import com.marvell.ppat.taskdef.Reboot;
import com.marvell.ppat.taskdef.power.MeasurePower;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.LineNumberReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.regex.Pattern;

public class AutoBurnSwd extends Task {

    private static boolean SWDL_RUNNING = true;

    class BurnException extends BuildException {

        /**
         *
         */
        private static final long serialVersionUID = 1L;

        private String message = null;

        public BurnException(String msg) {
            this.message = msg;
        }

        public String getMessage() {
            return this.message;
        }
    }

    @Override
    public void execute() throws BuildException {
        String isAutoburn = this.getProject().getProperty("autoburn");
        if (isAutoburn.equals("false")) {
            return;
        } else {
            // first verify whether need burn image
            BurnInfo burnInfo = new BurnInfo(getProject());

            // prepare burn image, first copy image file
            prepareBurn(burnInfo);

            // start to burn image
            System.out
                    .println("===================================================================");
            System.out
                    .println("||                   begin to burn on board!                     ||");
            System.out
                    .println("===================================================================");

            PowerCtrlUSB usb = new PowerCtrlUSB();
            usb.setProject(PPATProject.project);
            usb.setFlag("on");
            usb.execute();

            try {
                burnWithSWDownloader(burnInfo);
            } catch (BurnException e) {
                try {
                    burnWithSWDownloader(burnInfo);
                } catch (BurnException ex) {
                    PPATExceptionHandler.handleException(ex.getMessage());
                }
            }


            Reboot reboot = new Reboot();
            reboot.setProject(getProject());
            reboot.execute();

            /* create burn log */
            try {
                OutputStreamWriter out = new OutputStreamWriter(
                        new FileOutputStream(BurnInfo.LOCAL_IMAGE_PATH
                                + "autoburn.log"));
                out.write(burnInfo.getImagePath());

                Thread.sleep(3000);
                out.close();
                pushDataIntoBoard();
            } catch (Exception e) {
                e.printStackTrace();
                throw new BuildException("file opreation error!");
            }
        }
    }

    private void pushDataIntoBoard() {
        AdbCmd cmd = new AdbCmd();
        cmd.setProject(this.getProject());
        cmd.setWorkingDirectory(BurnInfo.LOCAL_IMAGE_PATH);
        try {
            cmd.execute("adb push " + BurnInfo.LOCAL_IMAGE_PATH + "/autoburn.log /data");
        } catch (BuildException e) {
            PrintColor.printRed("Failed to push autoburn.log to board");
        }

        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        System.out
                .println("push ***************************************** successful");
    }

    private boolean findString(ArrayList<String> arr, String str) {
        for (String out : arr) {
            if (out.contains("you can't run it again")) {
                return true;
            }
        }
        return false;
    }

    public void burnWithSWDownloader(final BurnInfo info) throws BurnException {
        System.out.println("Start to auto burn image by SoftwareDownloader...");
        // execute burn command
        System.out.println("Start execute SoftwareDownloader shell script...");
        String SWDL_PID = "";
        try {
            Thread t = new Thread() {
                public void run() {
                    HostCmd gc = new HostCmd();
                    HostCmd gc2 = new HostCmd();
                    try {
                        gc.setProject(PPATProject.project);
                        gc.setPrintStdErr(true);
                        gc.setPrintStdOut(false);
                        gc.setWorkingDirectory(BurnInfo.LOCAL_IMAGE_PATH
                                + "Software_Downloader");
                        gc.setCheckString("Burn Successfully");
                        gc.setTimeout(10800);

                        // get the user choosed blf file
                        String blf = getProject().getProperty("blf");
                        System.out.println("===============================");
                        System.out.println(blf);
                        System.out.println("===============================");

                        System.out.println("===============================");
                        System.out.println("freee memory for swdl");
                        gc2.setProject(PPATProject.project);
                        gc2.setPrintStdErr(true);
                        gc2.setPrintStdOut(false);
                        gc2.setWorkingDirectory(PPATProject.project.getBaseDir().toString());
                        gc2.execute("./tools/free.sh");
                        System.out.println("free memory done");
                        System.out.println("===============================");
                        if (!blf.equals("")) {
                            String burnCmd = getProject().getProperty("burn_cmd");
                            int cmd_s = burnCmd.lastIndexOf("/");
                            int cmd_e = burnCmd.lastIndexOf("blf");
                            if (blf.contains("blf")) {
                                burnCmd = burnCmd.substring(0, cmd_s + 1) + blf
                                        + burnCmd.substring(cmd_e + 3);

                            } else {
                                burnCmd = burnCmd.substring(0, cmd_s + 1) + blf
                                        + burnCmd.substring(cmd_e - 1);
                            }
                            gc.setCmd(burnCmd);
                        } else {
                            gc.setCmd(getProject().getProperty("burn_cmd"));
                        }
                        SWDL_RUNNING = true;
                        gc.execute();

                    } catch (BuildException e) {
                        if (e.getMessage().equalsIgnoreCase("NOT found check string") && !findString(gc.getExeResult().stdout, "you can't run it again")) {
                            PPATExceptionHandler.handleException("Failed to burn image with SWDL");
                        }

                        boolean swdlRunning = true;
                        while (swdlRunning) {
                            try {
                                ArrayList<String> stdOut = gc.getExeResult().stdout;
                                if (findString(stdOut, "you can't run it again")) {
                                    try {
                                        Thread.sleep(60 * 1000);
                                    } catch (InterruptedException ex) {
                                        // TODO Auto-generated catch block
                                        ex.printStackTrace();
                                    }
                                    SWDL_RUNNING = true;
                                    gc.execute();
                                } else {
                                    swdlRunning = false;
                                }

                            } catch (BuildException ee) {
                                SWDL_RUNNING = false;
                                swdlRunning = true;

                                if (ee.getMessage().equalsIgnoreCase("NOT found check string") && !findString(gc.getExeResult().stdout, "you can't run it again")) {
                                    PPATExceptionHandler.handleException("Failed to burn image with SWDL");
                                }

                                System.out.println("Still need wait swdl finished.");
                            }
                        }
                    }
                }
            };
            t.start();

            Thread.sleep(120000);
            while (!SWDL_RUNNING) {
                Thread.sleep(10000);
            }
            Thread.sleep(120000);
            HostCmd gc = new HostCmd();
            gc.setProject(PPATProject.project);
            gc.setWorkingDirectory(PPATProject.project.getProperty("root"));

            LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");
            RelayResource relay = (RelayResource) ResourceManager
                    .getResource("relay");
            if (ltk == null) {
                if (relay == null) {
                    throw new BuildException("no realy resource");
                }
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
                    System.out.println("##### power off device ######");
                    Thread.sleep(5000);


                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_usb")
                            + " 0");
                    Thread.sleep(5000);

                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_reset")
                            + " 1");
                    Thread.sleep(8000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_back")
                            + " 1");
                    Thread.sleep(1000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_back")
                            + " 0");
                    Thread.sleep(1000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_reset")
                            + " 0");

                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_usb")
                            + " 1");
                    Thread.sleep(5000);

                    System.out.println("##### power on device ######");
                    power.setVoltage("4");
                    power.execute();
                } else {
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_back")
                            + " 1");
                    Thread.sleep(8000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_reset")
                            + " 1");
                    Thread.sleep(1000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_reset")
                            + " 0");
                    Thread.sleep(1000);
                    gc.execute("./tools/relay "
                            + this.getProject().getProperty("relay_back")
                            + " 0");

                }
            } else {
                LTKCmd cmd = new LTKCmd();
//				cmd.setCmd("dkSWD");
                cmd.setCmd("debug pinl&nbsp;A");
                cmd.execute();
                cmd.setCmd("reset");
                cmd.execute();
                Thread.sleep(15000);
                cmd.setCmd("debug pinh&nbsp;A");
                cmd.execute();
            }

            System.out.println("Starting to burn image...");
            gc.execute("./tools/get_swdl_pid.sh");
            if (gc.getExeResult().stdout.size() > 1) {
                SWDL_PID = gc.getExeResult().stdout.get(0);
            }
            Thread.sleep(350000);
            // t.interrupt();
        } catch (Exception e) {
            throw new BuildException(
                    "Auto burn failed in calling relay for enterning into recover mode!!!");
        }

        System.out.println("Auto burn by software_Downloader done");

        System.out.println("Start to reboot after auto burn...");
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // kill software downloader
        HostCmd gc = new HostCmd();
        gc.setProject(PPATProject.project);
        gc.setWorkingDirectory(PPATProject.project.getProperty("root"));
        gc.execute("./tools/kill_swdl.sh " + SWDL_PID);
    }

    private void prepareBurn(BurnInfo burnInfo) {
        /* remove local image file in autoburn folder */
        HostCmd cmd = new HostCmd();
        cmd.setProject(getProject());
        cmd.execute("sudo rm -r " + BurnInfo.LOCAL_IMAGE_PATH);

        /* make a new dir */
        cmd.execute("mkdir " + BurnInfo.LOCAL_IMAGE_PATH);

        cmd.setWorkingDirectory(BurnInfo.LOCAL_IMAGE_PATH);

        // copy image
        String remoteImagePath = burnInfo.getImagePath();
        cmd.execute("cp " + remoteImagePath + "/" + "Software_Downloader.zip .");

        cmd.execute("unzip Software_Downloader.zip");

        String platform = getProject().getProperty("platform");
        String branch = PPATProject.project.getProperty("os_version") + "_" + PPATProject.project.getProperty("release_version");

        if (!platform.contains("eden")) {
            cmd.execute("mkdir Software_Downloader");
            cmd.execute("mv swdl_linux Software_Downloader");
            if (platform.equalsIgnoreCase("ulc1") && branch.equalsIgnoreCase("kk4.4_beta1")) {
                PrintColor.printYellow(this, " replace swdl_linux");
                cmd.execute("cp /home/buildfarm/swdl_linux Software_Downloader");
            }
        } else {
            cmd.execute("mkdir Software_Downloader");
//			cmd.execute("cp /home/buildfarm/swdl_linux Software_Downloader");
            cmd.execute("mv swdl_linux Software_Downloader");
        }
        cmd.execute("sudo chmod 777 -R Software_Downloader");
        System.out.println("Finished downloading Software_Downloader!!!");

        String blf = getProject().getProperty("blf");
        cmd.setWorkingDirectory(BurnInfo.LOCAL_IMAGE_PATH
                + "Software_Downloader");
        cmd.execute("mkdir "
                + platform.toUpperCase() + "_DKB");

        // find blf file folder
        String blfFilePath = Utils.findFiles(burnInfo.getImagePath()
                + "/" + getProject().getProperty("device"), blf, true);

        if (blfFilePath == null) {
            PPATExceptionHandler.handleException("Not Found BLF file: " + blf);
        }

        //copy blf file
        cmd.execute("cp " + blfFilePath.toString() + " " + platform.toUpperCase() + "_DKB");

        // parse blf file to generate image file list
        LineNumberReader reader = null;
        try {
            reader = new LineNumberReader(new FileReader(
                    BurnInfo.LOCAL_IMAGE_PATH
                            + "Software_Downloader/"
                            + getProject().getProperty("platform")
                            .toUpperCase() + "_DKB/" + blf));
            String line = null;
            while ((line = reader.readLine()) != null) {
                if (Pattern.compile(".Image_Path.*").matcher(line).find()) {
                    String f;
                    if (getProject().getProperty("platform").contains("eden")) {
                        f = line.split("\\s+")[2].substring(3);
                    } else {
                        f = line.split("\\s+")[2];
                    }
                    burnInfo.addImageFile(f);
                    System.out.println("Img: " + f);
                }
            }
        } catch (FileNotFoundException e) {
            PrintColor.printRed("Not Found BLF file: " + blf);
            PPATExceptionHandler.handleException("Not Found BLF file: " + blf);

        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }

        // copy image
        System.out.println(cmd.getWorkingDirectory());

        for (String img : burnInfo.getImageList()) {
            String imageFile = Utils.findFiles(burnInfo.getImagePath()
                    + "/" + getProject().getProperty("device"), img, true);
            if (imageFile == null) {
                PrintColor.printYellow("[Exception] Can't find " + img);
            } else {
                if (platform.contains("eden")) {
                    cmd.execute("cp " + imageFile + " .");
                } else {
                    if (imageFile.contains("3rd-party-app-system-img")) {
                        PrintColor.printYellow(this, " replace 3rd-party-app-system-img");
                        imageFile = imageFile.replaceAll("3rd-party-app-system-img", "");
                        PrintColor.printYellow(this, imageFile);
                    }
                    cmd.execute("cp " + imageFile + " " + platform.toUpperCase() + "_DKB");
                }
            }
        }

        //use ftp to get image files in case use upload them
        String jsonStr = PPATProject.project.getProperty("tc_list");
        if (jsonStr == null) {
            return;
        } else {
            try {
                JSONObject json = new JSONObject(jsonStr);
                String fileFolder = json.getString("folder");
                String[] image_files = json.getString("image_files").split(",");
                for (String file : image_files) {
                    if (file.trim() != "") {
                        System.out.println("copy " + file + " to " + cmd.getWorkingDirectory() + "/" + platform.toUpperCase() + "_DKB");
                        FTPDriver.download(fileFolder, file, cmd.getWorkingDirectory() + "/" + platform.toUpperCase() + "_DKB");
                    }
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                System.out.println("No specific image files to download");
            }
        }

        //temp use 12-18 wtm for hln3 lp5.0
//		if(PPATProject.project.getProperty("device").equalsIgnoreCase("pxa1936dkb_tz")){
//			PrintColor.printYellow(this, " replace Skylark_LTG_V15.bin to Skylark_LTG_V13.bin");
//			String  wtmFile = "/home/buildfarm/Skylark_LTG_V13.bin";
//			cmd.execute("cp " + wtmFile + " " + platform.toUpperCase() + "_DKB/Skylark_LTG_V15.bin");
//		}
    }

    private boolean noNeedToBurn(BurnInfo burnInfo) {
        AdbCmd cmd = new AdbCmd();
        cmd.setProject(getProject());
        try {
            cmd.execute("adb shell cat /data/autoburn.log");
            CmdExecutionResult result;
            result = cmd.getExeResult();
            ArrayList<String> out = result.stdout;
            for (String line : out) {
                if (line.equalsIgnoreCase(burnInfo.getImagePath())) {
                    return true;
                }
            }
        } catch (BuildException e) {
            return false;
        }

        return false;
    }
}
