package com.marvell.ppat.taskdef;

import java.util.ArrayList;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;


public class UpdateEvent extends Task {

	private String name="";
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
			PrintColor.printRed(this,"Run PPAT with local mode, don't cat image date");
		}else{
			AdbCmd cmd = new AdbCmd();
			cmd.setProject(this.getProject());
			int i = 0;
			boolean find = false;
			while(i < 100){
				cmd.execute("adb shell cat /sys/class/input/input" + i + "/name");
				ArrayList<String> nodeName = cmd.getExeResult().stdout;
				for(String name : nodeName){
					if(name.equalsIgnoreCase(this.name)){
						SystemProperty prop = new SystemProperty();
						prop.setProject(getProject());
						prop.setKey("InputEvent");
						prop.setValue(i + "");
						prop.execute();
						this.getProject().setProperty("InputEvent",i + "");	
						System.out.println("update input event:" + i);
						find = true;
						break;
					}
				}
				if(find){
					break;
				}
				i++;
			}
		}
		
	}
	public void setName(String name) {
		this.name = name;
	}
}
