package com.marvell.ppat.roundpp;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.taskdef.SerialPortCmd;

public class CPU extends Component {

    private static String CPU_FREQ = "/sys/devices/system/cpu/";
    private static String CPU_GOVERNOR = CPU_FREQ + "cpu0/cpufreq/scaling_governor";
    private static String CPU_SCALING_MAX_FREQ = CPU_FREQ + "cpu0/cpufreqscaling_max_freq";
    private static String CPU_SCALING_MIN_FREQ = CPU_FREQ + "cpu0/cpufreqscaling_min_freq";
    private static String CPU_SCALING_SET_FREQ = CPU_FREQ + "cpu0/cpufreqscaling_setspeed";
    private static String CPU_HOTPLUG_LOCK = "/sys/devices/system/cpu/hotplug/lock";
    private static int CPU_CORE_NUM = 4;

    private static SerialPortCmd serial = new SerialPortCmd();
    private String id = "0";

    static {
        serial.setProject(PPATProject.project);
    }

    public CPU() {
        this.name = "cpu";
    }

    public void dounit(String id) {
        this.id = id;
        this.name = "cpu" + id;
    }

    public void doCoreNum(String num) {
        int coreNum = Integer.parseInt(num);

        for (int i = 1; i < coreNum; i++) {
            serial.setCmd("echo 1 > " + CPU_FREQ + "cpu" + (i + Integer.parseInt(this.id)) + "/online");
            serial.execute();
        }
        for (int i = coreNum; i < CPU_CORE_NUM; i++) {
            serial.setCmd("echo 0 > " + CPU_FREQ + "cpu" + (i + Integer.parseInt(this.id)) + "/online");
            serial.execute();
        }
        String purpose = PPATProject.project.getProperty("Purpose");
        PPATProject.project.setProperty("Purpose", purpose + " core num: " + num);
    }

    public void doFrequency(String freq) {
        serial.setCmd("phs_cmd 9 cpu" + this.id + " " + freq);
        serial.execute();
        PPATProject.project.setProperty(this.name, freq);
    }

    @Override
    public String getName() {
        // TODO Auto-generated method stub
        return this.name;
    }

    public void doGovernor(String gov) {
        serial.setCmd("echo " + gov + " > " + CPU_GOVERNOR);
        serial.execute();
        String purpose = PPATProject.project.getProperty("Purpose");
        PPATProject.project.setProperty("Purpose", purpose + this.name + " governor: " + gov);
    }

    public void dominfreq(String minfreq) {
        serial.setCmd("echo " + minfreq + " > " + CPU_SCALING_MIN_FREQ);
        serial.execute();

        String purpose = PPATProject.project.getProperty("Purpose");
        PPATProject.project.setProperty("Purpose", purpose + this.name + " minfreq: " + minfreq);
    }

    public void domaxfreq(String maxfreq) {
        serial.setCmd("echo " + maxfreq + " > " + CPU_SCALING_MAX_FREQ);
        serial.execute();
        String purpose = PPATProject.project.getProperty("Purpose");
        PPATProject.project.setProperty("Purpose", purpose + this.name + " maxfreq: " + maxfreq);
    }
}
