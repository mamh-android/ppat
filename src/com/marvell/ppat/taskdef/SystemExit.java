package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class SystemExit extends Task {
	
	private int exitCode = 0;
	
	public void setExitCode(String code){
		this.exitCode = Integer.parseInt(code);
	}
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		System.exit(this.exitCode);
	}
}
