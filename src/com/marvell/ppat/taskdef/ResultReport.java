package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.taskdef.power.PowerReportFile;

public class ResultReport extends Task {
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		PowerCtrlUSB usb_off = new PowerCtrlUSB();
		usb_off.setProject(this.getProject());
		usb_off.setFlag("on");
		usb_off.execute();

		HostCmd cmd = new HostCmd();
		cmd.setProject(getProject());
		
		String filePath = PowerReportFile.getInstance().getHTML().getAbsolutePath();
		cmd.execute("python /usr/local/bin/sendmail.py -l " + filePath + " -t " + getProject().getProperty("assigner"));
		
	}
}
