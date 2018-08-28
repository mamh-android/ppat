package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import java.util.ArrayList;

public class SetVol extends Task {

    private int vol;
    private String vol_hx;//vol value to write
    private static ArrayList<String> REGISTER_ADDRS;
    private static String PM800_REG = "/sys/kernel/debug/pm800_reg";
    private static String PM886_REG = "/sys/kernel/debug/88pm886";
    private static ArrayList<String> REGISTER_ADDRS_000;
    private static ArrayList<String> REGISTER_ADDRS_001;

    public SetVol() {
        super();
    }

    public void setVol(String vol) {
        this.vol = Integer.parseInt(vol);
    }

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub

        int val = (int) ((this.vol - 600) / 12.5);
        vol_hx = Integer.toHexString(val);

        String platform = getProject().getProperty("platform");

        if (platform.equalsIgnoreCase("helnlte") || platform.equalsIgnoreCase("hln2") || platform.equalsIgnoreCase("eden")) {
            REGISTER_ADDRS = new ArrayList<String>();
            REGISTER_ADDRS.add("0x3c");
            REGISTER_ADDRS.add("0x3d");
            REGISTER_ADDRS.add("0x3e");
            REGISTER_ADDRS.add("0x3f");
        } else if (platform.equalsIgnoreCase("ulc1")) {
            REGISTER_ADDRS_000 = new ArrayList<String>();
            REGISTER_ADDRS_000.add("0xA5");
            REGISTER_ADDRS_000.add("0xA6");
            REGISTER_ADDRS_000.add("0xA7");
            REGISTER_ADDRS_000.add("0xA8");

            REGISTER_ADDRS_001 = new ArrayList<String>();
            REGISTER_ADDRS_001.add("0x9A");
            REGISTER_ADDRS_001.add("0x9B");
            REGISTER_ADDRS_001.add("0x9C");
            REGISTER_ADDRS_001.add("0x9D");
        }

        SerialPortCmd serial = new SerialPortCmd();
        serial.setProject(this.getProject());
        if (platform.equalsIgnoreCase("helnlte") || platform.equalsIgnoreCase("hln2")) {
            for (String addr : REGISTER_ADDRS) {
                serial.execute("echo -0x1 " + addr + " > " + PM800_REG);
                serial.execute("echo 0x" + vol_hx + " > " + PM800_REG);
            }
        } else if (platform.equalsIgnoreCase("eden")) {
            for (int i = 0; i < 4; i++) {
                for (String addr : REGISTER_ADDRS) {
                    serial.execute("echo -0x1 0x4f > " + PM800_REG);
                    serial.execute("echo 0x" + i + " > " + PM800_REG);
                    serial.execute("echo -0x1 " + addr + " > " + PM800_REG);
                    serial.execute("echo 0x" + vol_hx + " > " + PM800_REG);
                }
            }
        } else if (platform.equalsIgnoreCase("ulc1")) {
            serial.execute("echo 0x1 > " + PM886_REG + "/page-address");

            //set ${DVC1, DVC2, DVC3} = 0x000
            for (String addr : REGISTER_ADDRS_000) {
                serial.execute("echo " + addr + " > " + PM886_REG + "/register-address");
                serial.execute("echo 0x" + vol_hx + " > " + PM886_REG + "/register-value");
            }

            //set ${DVC1, DVC2, DVC3} = 0x001
            int val_001 = (int) ((this.vol - 600) / 12.5) | 0x80;
            String vol_hx_001 = Integer.toHexString(val_001);
            for (String addr : REGISTER_ADDRS_001) {
                serial.execute("echo " + addr + " > " + PM886_REG + "/register-address");
                serial.execute("echo 0x" + vol_hx_001 + " > " + PM886_REG + "/register-value");
            }
        }
    }
}
