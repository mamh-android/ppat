package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;

import org.apache.tools.ant.BuildException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.regex.Pattern;

/**
 * parse duty cycle and fps info
 *
 * @author zhoulz
 */
public class ParseInfo extends ParseCommon {

    private static String PARSE_DUTY_CYCLE = ".*duty cycle.*";
    private static String PARSE_DUTY_CYCLE_2 = ".*rt ratio.*";
    private static String PARSE_DUTY_CYCLE_3 = ".*\\d+.*\\d+%.*";
    private static String PARSE_DUTY_CYCLE_4 = ".*gc_fps_stats.*";
    private static String PARSE_DUTY_CYCLE_5 = ".*operating point list.*";
    private static String PARSE_DUTY_CYCLE_6 = ".*ratio.*time.*count.*";
    private static String SKIP_STRING_1 = ".*setprop.*";
    private static String SKIP_STRING_2 = "D/dalvikvm.*";
    private static String SKIP_STRING_3 = "D/CameraParams.*";
    private static String PARSE_DOWNLOAD = ".*FTP download speed.*";
    private static String PARSE_UPLOAD = ".*FTP upload speed.*";

    private static String GC_FPS = ".*FPS.*";
    private static String RECORD_FPS = ".*Video fps::fps=.*";
    private static String PREVIEW_FPS = ".*preview fps::fps=.*";
    private static String PLAYBACK_FPS = ".*playback::fps.*";
    private static String CODEC_FPS = ".*Codec level fps.*";

    private static String MDCP_COMMOND = "memcpy";
    private static DecimalFormat mDf = new DecimalFormat("#.##");

    private static int count = 0;
    private static boolean find_ddr = false;
    private static boolean find_cpu = false;
    private static boolean find_mdcp = false;
    private String stat_d;
    private String path;

    public ParseInfo(String stat_d) {
        this.stat_d = stat_d;
        String folder = PPATProject.project.getProperty("case_root");
        File file = new File(folder);
        path = file.getParent();
    }

    public ParseInfo() {
        this.stat_d = "true";
        String folder = PPATProject.project.getProperty("case_root");
        File file = new File(folder);
        path = file.getParent();
    }

    @Override
    public void parseResult() throws BuildException {

        float busy_rt_sum = 0, data_rt_sum = 0;
        float test_count = 0;
        BufferedReader br;
        try {
            br = new BufferedReader(new InputStreamReader(
                    new FileInputStream(path + "/" + "serialport.log")));
            LineNumberReader reader = new LineNumberReader(br);

            int num = 0;
            try {
                num = Integer.parseInt(PPATProject.project.getProperty("log_num"));
            } catch (Exception e) {
                num = 0;
            }

            String line = null;

            int count = 0;
            while (count < num) {
                reader.readLine();
                count++;
            }

            StringBuilder sb = new StringBuilder();
            StringBuilder fps = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                try {
                    if (Pattern.compile(PARSE_DUTY_CYCLE).matcher(line).find()
                            || Pattern.compile(PARSE_DUTY_CYCLE_2).matcher(line)
                            .find()
                            || Pattern.compile(PARSE_DUTY_CYCLE_3).matcher(line)
                            .find()
                            || Pattern.compile(PARSE_DUTY_CYCLE_4).matcher(line)
                            .find()
                            || Pattern.compile(PARSE_DOWNLOAD).matcher(line).find()
                            || Pattern.compile(PARSE_UPLOAD).matcher(line).find()) {
                        if (!Pattern.compile(SKIP_STRING_1).matcher(line).find()
                                && !Pattern.compile(SKIP_STRING_2).matcher(line)
                                .find()
                                && !Pattern.compile(SKIP_STRING_3).matcher(line)
                                .find()) {
                            if (line.contains("<")) {
                                line = line.replaceAll("<", "&lt;");
                            }
                            sb.append(line).append("@");
                        }
                        if (Pattern.compile(PARSE_DOWNLOAD).matcher(line).find()) {
                            fps.append(line);
                            setValue("FPS", line);
                        }
                        if (Pattern.compile(PARSE_UPLOAD).matcher(line).find()) {
                            sb.append(line);
                            setValue("FPS", line);
                        }
                    }

                    if (Pattern.compile(GC_FPS).matcher(line).find()) {
                        String reg = "FPS is";
                        int index = line.indexOf(reg);
                        String FPS = line.substring(index + reg.length() + 1,
                                line.length());

                        PPATProject.project.setProperty("GC_fps", FPS);
                    }
                    if (Pattern.compile(PLAYBACK_FPS).matcher(line).find()) {
                        String[] results = line.split(",");
                        String frameNum = results[0].split("\\s+")[5];
                        String aweFps = results[2].split("\\s+")[2];
                        PPATProject.project.setProperty("AwesomePlayer_fps", aweFps);
                        PPATProject.project.setProperty("total_frame_num", frameNum);
                    }
                    if (Pattern.compile(CODEC_FPS).matcher(line).find()) {
                        String codecFps = line.split("\\s+")[16];
                        PPATProject.project.setProperty("codec_fps", codecFps);
                    }
                    if (Pattern.compile(RECORD_FPS).matcher(line).find()) {
                        String reg = "Video fps::fps=";
                        int index = line.indexOf(reg);
                        String FPS = line.substring(index + reg.length(), line.length());
                        PPATProject.project.setProperty("video_fps", FPS);
                    }
                    if (Pattern.compile(PREVIEW_FPS).matcher(line).find()) {
                        String reg = "preview fps::fps=";
                        int index = line.indexOf(reg);
                        String FPS = line.substring(index + reg.length(), line.length());
                        PPATProject.project.setProperty("preview_fps", FPS);
                    }
                    if (find_mdcp) {
                        if (Pattern.compile("\\d+[.]\\d+\\s+\\d+[.]\\d+").matcher(line).find()) {
                            test_count++;
                            busy_rt_sum += Float.parseFloat(line.split("\\s+")[0]);
                            data_rt_sum += Float.parseFloat(line.split("\\s+")[1]);
                        } else {
                            PropertyMap.properties.put("busy_rt", mDf.format(busy_rt_sum / test_count));
                            System.out.println(mDf.format(busy_rt_sum / test_count));
                            PropertyMap.properties.put("data_rt", mDf.format(data_rt_sum / test_count));
                            find_mdcp = false;
                        }
                    }
                    if (Pattern.compile(MDCP_COMMOND).matcher(line).find()) {
                        find_mdcp = true;
                    }

                    if (Pattern.compile(PARSE_DUTY_CYCLE_5).matcher(line).find()) {
                        find_ddr = true;
                        count = 0;
                    }
                    if ((count < 6) && find_ddr) {
                        if (!Pattern.compile(PARSE_DUTY_CYCLE_3).matcher(line)
                                .find()) {
                            sb.append(line).append("@");
                        }
                        count++;
                    }
                    num++;

                    if (Pattern.compile("shell").matcher(line).find()) {
                        find_cpu = false;
                    }

                    if (Pattern.compile(PARSE_DUTY_CYCLE_6).matcher(line).find()) {
                        find_cpu = true;
                    }
                    if (find_cpu == true) {
                        if (!Pattern.compile(PARSE_DUTY_CYCLE_3).matcher(line)
                                .find()) {
                            if (line.contains("<")) {
                                line = line.replaceAll("<", "&lt;");
                            }
                            sb.append(line).append("@");
                        }
                    }
                } catch (Exception e) {

                }

            }
            setValue("Duty_Cycle", sb.toString());

            PPATProject.project.setProperty("log_num", Integer.toString(num));
            setValue("fps", fps.toString());
            reader.close();
        } catch (FileNotFoundException e1) {
            // TODO Auto-generated catch block
            System.out.println("Not found " + path + "/" + "serialport.log");
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }


    }

    @Override
    public void parseResultDetail() throws BuildException {
        setValue("Duty_Cycle", "");
        StatDutyCycle statdc = new StatDutyCycle();

        if (this.stat_d.equalsIgnoreCase("true")) {

            if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
                SerialPortCmd cmd = new SerialPortCmd();
                cmd.setProject(this.getProject());

                for (String dcnode : StatDutyCycle.DC_STAT_NODES) {
                    cmd.execute("cat " + dcnode);
                }
            } else {
                AdbCmd gcmd = new AdbCmd();
                gcmd.setPrintStdErr(true);
                gcmd.setPrintStdOut(true);
                gcmd.setTimeout(15);
                gcmd.setProject(this.getProject());
                CmdExecutionResult result;
                ArrayList<String> duty;
                StringBuilder sb = new StringBuilder();


                for (String dcnode : StatDutyCycle.DC_STAT_NODES) {
                    gcmd.execute("adb shell cat " + dcnode);
                    result = gcmd.getExeResult();
                    duty = result.stdout;
                    for (String d : duty) {
                        sb.append(d).append("\n");
                    }
                }

                gcmd.execute("adb shell cat /proc/driver/gc");
                result = gcmd.getExeResult();
                duty = result.stdout;
                sb.append(duty.get(0)).append("\n");

                setValue("Duty_Cycle", sb.toString());
            }
        }
    }

}
