package com.marvell.ppat.roundpp;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.taskdef.SerialPortCmd;

public class VPU extends Component{

	private static SerialPortCmd serial = new SerialPortCmd();
	private String id = "";
	
	static{
		serial.setProject(PPATProject.project);
	}
	
	public VPU(){
		this.name = "vpu";
	}
	
	public void dounit(String id){
		this.id = id;
		this.name = "vpu";
	}
	
	@Override
	public String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}
	
	public VPU(String id){
		this.id = id;
	}
	public void doFrequency(String freq){
		serial.setCmd("phs_cmd 9 " + this.name + this.id + " " + freq);
		serial.execute();
		PPATProject.project.setProperty(this.name + this.id, freq);
	}
}

