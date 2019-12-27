package com.marvell.ppat.listener;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Mkdir;

import com.marvell.ppat.driver.PPATExceptionHandler;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.taskdef.EnterUboot;
import com.marvell.ppat.taskdef.HostCmd;
import com.marvell.ppat.taskdef.PowerCtrlUSB;
import com.marvell.ppat.taskdef.Reboot;
import com.marvell.ppat.taskdef.SerialPortCmd;

public class SerialPortListener implements OutputListener {
	private String caseRoot = PPATProject.project.getProperty("result_root");
	private Thread atdThread;
	private String currentTask;
	
	public SerialPortListener(Thread atdThread) {
		// TODO Auto-generated constructor stub
		this.atdThread = atdThread;
	}

	public void process(String line) {
	    if(line.contains("Detect EMMD signature!!") || line.contains("EMMD: ready to perform memory dump")){
	    	PrintColor.printRed("[Exception]Detect EMMD dump...");
	    	atdThread.suspend();
	    	
	    	//make sure usb on
	    	PowerCtrlUSB usb = new PowerCtrlUSB();
	    	usb.setProject(PPATProject.project);
	    	usb.setFlag("on");
	    	usb.execute();
	    	
	    	dumpBuffer();

	    	usb.setFlag("off");
	    	usb.execute();
	    	
	    	EnterUboot enter = new EnterUboot();
			enter.setProject(PPATProject.project);
			enter.execute();
				
			try {
				Thread.sleep(30000);
				SerialPortCmd serial = new SerialPortCmd();
				serial.setProject(PPATProject.project);
				serial.execute("boot");
				Thread.sleep(30000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    	atdThread.resume();
	    } 
	    
	}

	@Override
	public boolean getResult() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		
	}
	
	public void dumpBuffer(){
		HostCmd gc = new HostCmd();
		gc.setProject(PPATProject.project);
		
		Mkdir mkdir=new Mkdir();
		mkdir.setProject(PPATProject.project);
		mkdir.setTaskName("mkdir");
		PrintColor.printRed("Maker a directory EMMDDUMP");
		mkdir.setDir(new File(caseRoot+"/EMMDDUMP"));
		mkdir.execute();
		
		
		//dump
		PrintColor.printRed("Dump DDR buffer...");
		gc.setWorkingDirectory(caseRoot+"/EMMDDUMP");
		gc.setTimeout(900);
		gc.setJobMonitor(true);
		gc.execute("sudo fastboot dump EMMDDUMP");
	}
	
}
