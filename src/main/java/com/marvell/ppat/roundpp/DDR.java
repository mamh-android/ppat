package com.marvell.ppat.roundpp;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.taskdef.SerialPortCmd;


public class DDR extends Component {

    private static SerialPortCmd serial = new SerialPortCmd();

    static {
        serial.setProject(PPATProject.project);
    }

    public DDR() {
        this.name = "ddr";
    }

    @Override
    public String getName() {
        // TODO Auto-generated method stub
        return this.name;
    }

    public void doFrequency(String freq) {
        serial.setCmd("phs_cmd 9 ddr " + freq);
        serial.execute();
        PPATProject.project.setProperty(this.name, freq);
    }
}