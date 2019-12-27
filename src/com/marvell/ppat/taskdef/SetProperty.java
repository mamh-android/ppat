package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;

/**
 * set property only available in the same project 
 *
 */
public class SetProperty extends Task {
	
	private String name;
	private String value;
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		this.getProject().setProperty(name, value);
	}

	public void setName(String name){
		this.name = name;
	}
	
	public void setValue(String value){
		this.value = value;
	}
	
	public void addText(String value){
		this.value = value;
	}
}
