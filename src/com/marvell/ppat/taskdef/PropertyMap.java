package com.marvell.ppat.taskdef;

import java.util.HashMap;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class PropertyMap extends Task {

public static HashMap<String, String> properties = new HashMap<String, String>();
	
	private String key =null;
	private String value =null;
	
	public void setKey(String key) {    
    	this.key = key;
    }   
   
	public void setValue(String value) {    
		this.value = value;
    }

	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		if (this.key == null || this.value == null) {
			 throw new BuildException("key and value must be specified "
	                    + "for environment variables.");
       }
		properties.put(this.key, this.value);
		this.getProject().setProperty(this.key, this.value);
	}
}
