package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.ResourceManager;

public class ScreenOn extends Task {

	@Override
	public void execute() throws BuildException {
		LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");
		if(ltk == null){//use serialport to send command
			SerialPortCmd cmd = new SerialPortCmd();
			cmd.setProject(this.getProject());
			cmd.execute("svc power stayon true");
			cmd.execute("svc power stayon false");
		}else{
			if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
				SerialPortCmd cmd = new SerialPortCmd();
				cmd.setProject(this.getProject());
				cmd.execute("svc power stayon true");
				cmd.execute("svc power stayon false");
			}else{
				LTKCmd ltkcmd = new LTKCmd();
	        	ltkcmd.setCmd("onkey");
	        	ltkcmd.execute();
				SerialPortCmd cmd = new SerialPortCmd();
				cmd.setProject(this.getProject());
				cmd.execute("svc power stayon true");
				cmd.execute("svc power stayon false");
			}
		}
	}
}
