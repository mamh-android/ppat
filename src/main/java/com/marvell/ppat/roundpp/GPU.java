package com.marvell.ppat.roundpp;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.taskdef.SerialPortCmd;


public class GPU extends Component {

    private static SerialPortCmd serial = new SerialPortCmd();
    private String id = "0";

    static {
        serial.setProject(PPATProject.project);
    }

    public GPU() {
        this.name = "gpu";
    }

    public void dounit(String id) {
        this.id = id;
        this.name = "gpu" + id;
    }

    @Override
    public String getName() {
        // TODO Auto-generated method stub
        return this.name;
    }

    public GPU(String id) {
        this.id = id;
    }

    public void doFrequency(String freq) {
        serial.setCmd("phs_cmd 9 " + this.name + " " + freq);
        serial.execute();
        PPATProject.project.setProperty(this.name, freq);
    }
}
