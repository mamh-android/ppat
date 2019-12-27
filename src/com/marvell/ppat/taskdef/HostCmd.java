package com.marvell.ppat.taskdef;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.CmdSimpleExecutor;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;

public class HostCmd extends Task {

	protected boolean waitFlag = true;
	protected boolean JobMonitor = false;
	protected String cmd = null;
	protected String check = null;
	protected boolean printStdErr = true; // default don't print stderr
	protected boolean printStdOut = true; // default print stdout
	protected String redirectPath = null;
	protected String workingDirectory = null;
	protected int timeout = 600;
	protected String exitValue = null;

	private boolean redirectErr = false; // can publish of necessary
	private CmdExecutionResult exeResult = null;
	private BufferedWriter bw =null;
	private boolean res = false;
	private int mSleep = 0;
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		try {
			CmdSimpleExecutor exe = new CmdSimpleExecutor(redirectErr,workingDirectory);
			if (JobMonitor) {
				// execute cmd with jobmonitor	
				//exeResult = exe.exeCmd(this.getProject().getProperty("atf_jobmonitor")+ " -t " + timeout + " -q -e 1 " + cmd );
				if(cmd.toLowerCase().contains("sudo")){
					exeResult = exe.exeCmd("sudo "+ PPATProject.project.getProperty("user.dir") + "/" + PPATProject.project.getProperty("jobmonitor")+ " -t " + timeout + " -q -e 1 " + cmd.replace("sudo", "").trim() );
				}else{
					exeResult = exe.exeCmd(PPATProject.project.getProperty("user.dir") + "/" + PPATProject.project.getProperty("jobmonitor")+ " -t " + timeout + " -q -e 1 " + cmd );
				}
			} else {
				// execute cmd without jobmonitor	
				if(this.getProject() == PPATProject.project){
					PrintColor.printwhite(cmd);	
				}else{
					PrintColor.printwhite(this, cmd);
					PrintColor.printwhite(cmd);	
				}
				exeResult = exe.exeCmd(cmd);
			}		
			Thread.sleep(mSleep);
		
			System.out.println("Host cmd return value: " + exeResult.exitValue);
			if(exitValue != null){
				System.out.println(exitValue);
				this.getProject().setProperty(exitValue, exeResult.exitValue + "");
				PPATProject.project.setProperty(exitValue, exeResult.exitValue + "");
			}
			
			/* check stand output */
			if (check != null) {
				for (String line : exeResult.stdout) {
					Pattern pattern = Pattern.compile(check);
					Matcher matcher = pattern.matcher(line);
					if(matcher.find()){
						check = null;
						break;
					}
					
				}					
							
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}finally{	
			if (!waitFlag) {
				return;
			}		
			
			/*save/print log when use ctrl+c exit */
			if (redirectPath != null){
				try {					
					bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(redirectPath)));	
					for (String line : exeResult.stdout) {		
						PrintColor.printwhite(this, line);	
						bw.write(line);							
					}	
					for (String line : exeResult.stderr) {	
//						PrintColor.printRed(line);	
						PrintColor.printwhite(this, line);
						bw.write(line);					
					}
					bw.close();
				} catch (IOException e) {				
					e.printStackTrace();
				}
			}else{			
				/* show stand output */
				if (printStdOut) {
					for (String line : exeResult.stdout) {
						if(this.getProject() == PPATProject.project){
							PrintColor.printwhite(line);
						}else{
							PrintColor.printwhite(line);
							PrintColor.printwhite(this, line);
						}
						
//						PrintColor.printwhite(this, line);		
					}			
				}
				/* show stand error if command was not execute correctly */
				if (printStdErr) {
					for (String line : exeResult.stderr) {
						if(this.getProject() == PPATProject.project){
							PrintColor.printRed(line);			
						}else{
							PrintColor.printRed(this, line);	
							PrintColor.printRed(line);
						}
					}
				}
				
				if (exeResult.exitValue != 0 && !printStdErr) {
					for (String line : exeResult.stderr) {
//						PrintColor.printRed("ERR: " + line);	
						PrintColor.printRed(this, line);							
					}
				}				
			}
			
			if (check != null){
				throw new BuildException("NOT found check string");
			}	
		}
	}
	
	public void execute(String execmd) throws BuildException {
		setCmd(execmd);
		execute();
	}

	public void execute(String[] cmds) throws BuildException {
		for (int i = 0; i < cmds.length; i++) {
			setCmd(cmds[i]);
			execute();
		}
	}

	public CmdExecutionResult getExeResult() {
		return this.exeResult;
	}

	public void setWaitFlag(boolean flag) {
		this.waitFlag = flag;
	}

	public void setJobMonitor(boolean JobMonitor) {
		this.JobMonitor = JobMonitor;
	}

	public void setCmd(String cmd) {
		this.cmd = cmd;
	}

	public void setCheckString(String check) {
		this.check = check;
	}

	public void setExitValue(String value){
		this.exitValue = value;
	}
	
	public String getExitValue(){
		return this.exitValue;
	}
	public void setDuration(int duration) {
		this.timeout = duration;
	}
	
	public void setTimeout(int timeout) {
		this.timeout = timeout;
	}

	public void setWorkingDirectory(String workingDirectory) {
		this.workingDirectory = workingDirectory;
	}
	
	public String getWorkingDirectory(){
		return this.workingDirectory;
	}

	public void setPrintStdErr(boolean flag) {
		this.printStdErr = flag;
	}

	public void setPrintStdOut(boolean flag) {
		this.printStdOut = flag;
	}
	
	public void setRedirectPath(String redirectPath) {
		this.redirectPath = redirectPath;
	}
	
	public void setCmdIntervel(int mSleep){
		this.mSleep = mSleep;
	}
}
