package com.marvell.ppat.taskdef;

import java.util.ArrayList;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;

public class LTKCmd extends Task {

	protected String cmd = "";

	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		boolean result = exeLTKCmd();
//		int count = 0;
//		while(!result && count < 6){
//			PrintColor.printYellow("retry to run ltk client for " + count + " times.");
//			count++;
//			result = exeLTKCmd();
//		}
	}
	
	private boolean exeLTKCmd(){
		boolean res = false;
		HostCmd gc = new HostCmd();
        gc.setProject(PPATProject.project);
        String board_ID = PPATProject.project.getProperty("ltk_device_id");
    	gc.execute("rcc_utilc operate " + board_ID + " " + cmd);
    	    	    	
    	CmdExecutionResult result;
		result = gc.getExeResult();
		ArrayList<String> chkStr = result.stdout;
		for (String str : chkStr) {
			if (str.contains("Success")){
				res = true;
			}
		}
		chkStr = result.stderr;
		for (String str : chkStr) {
			if (str.contains("Success")){
				res = true;
			}
		}
		return res;
	}
	
	public void setCmd(String cmd){
		this.cmd = cmd;
	}
}
