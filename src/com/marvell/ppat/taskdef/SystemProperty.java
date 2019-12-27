package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;

/**
 * set global property
 *
 */
public class SystemProperty extends Task {

	private String key;
	private String value;
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		PPATProject.project.setProperty(key, value);
	}

	public void setKey(String name){
		this.key = name;
	}
	
	public void setValue(String value){
		this.value = value;
	}
	
	public void addText(String value){
		this.value = value;
	}
}
