package com.marvell.ppat.taskdef;

import java.sql.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PPATExceptionHandler;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.resource.AdbResource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;


/**
 * enable EMMD dump
 * screen unlock
 * @author zhoulz
 *
 */
public class PrepareBoard extends Task {
	
	private boolean enableEmmd = false;
	
	private void runAdbCmd (String cmd, String checkstring, boolean showflag) throws BuildException{		
		 runAdbCmd (cmd, checkstring, showflag, 0);
	}
	
	private void runAdbCmd (String cmd, String checkstring, boolean showflag, int intervel) throws BuildException{
		
		AdbCmd ac = new AdbCmd();		
		ac.setProject(this.getProject());
		ac.setShowFlag(showflag);
		ac.setCmdIntervel(intervel);
		ac.setCheckString(checkstring);
		ac.execute(cmd);
		if(cmd.contains("build.prop")){
			for(String line : ac.getExeResult().stdout){
				if(line.contains("ro.abs_build_ver=")){
					String PatternStr = "[0-9]{4}-[0-9]{2}-[0-9]{2}";
					String PatternStr_1 = "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]_";
				    Pattern pattern = Pattern.compile(PatternStr);
				    Pattern pattern_1 = Pattern.compile(PatternStr_1);
				    Matcher matcher = pattern.matcher(line); 
				    Matcher matcher_1 = pattern_1.matcher(line); 
				    if(matcher_1.find()){
					    PPATProject.project.setProperty("image_date", matcher_1.group(0).split("_")[0]);
				    	String[] str_cont_os_version = line.split("=")[1].split("_");
					    String os_version = str_cont_os_version[2].split("-")[1];
					    int os_idx = line.indexOf(os_version);
				    	if(!PPATProject.project.getProperty("os_version").equalsIgnoreCase(os_version)){
					    	System.out.println("update os_version to :" + os_version);
					    	PPATProject.project.setProperty("os_version", os_version);
					    }
				    	 if((os_idx + os_version.length()) == line.length()){
						    	PPATProject.project.setProperty("release_version", "master");
					    }else{
					    	String rls_version = line.substring(os_idx + os_version.length() + 1);
					    	PPATProject.project.setProperty("release_version", rls_version);
					    	System.out.println("update release_version to :" + PPATProject.project.getProperty("release_version"));
					    }
				    }else if(matcher.find()){
					    PPATProject.project.setProperty("image_date", matcher.group(0));
				    	String[] str_cont_os_version = line.split("=")[1].split("_");
				    	String os_version = str_cont_os_version[1].split("-")[1];
				    	int os_idx = line.indexOf(os_version);
				    	if(!PPATProject.project.getProperty("os_version").equalsIgnoreCase(os_version)){
					    	System.out.println("update os_version to :" + os_version);
					    	PPATProject.project.setProperty("os_version", os_version);
					    }
				    	
				    	 if((os_idx + os_version.length()) == line.length()){
						    	PPATProject.project.setProperty("release_version", "master");
					    }else{
					    	String rls_version = line.substring(os_idx + os_version.length() + 1);
					    	PPATProject.project.setProperty("release_version", rls_version);
					    	System.out.println("update release_version to :" + PPATProject.project.getProperty("release_version"));
					    }
				    	
				    }
				}
			}
		}
		
		if(cmd.contains("autoburn.log")){
			for(String line : ac.getExeResult().stdout){
				String PatternStr = "[0-9]{4}-[0-9]{2}-[0-9]{2}";
				Pattern pattern = Pattern.compile(PatternStr);  
				Matcher matcher = pattern.matcher(line); 
				if(matcher.find()){
					PPATProject.project.setProperty("image_date", matcher.group(0));
				}
			}
		}
	}
	
	private void runserialportCmd (String cmd, String checkstring, int maxline) throws BuildException{
		SerialPortCmd spc = new SerialPortCmd();
		spc.setProject(this.getProject());
		spc.setCheckString(checkstring);
		if(maxline != 0){
			spc.setMaxLine(maxline);
		}	
		spc.execute(cmd);	
	}	
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		SerialPortResource sr = (SerialPortResource) ResourceManager
				.getResource("serialport");
		AdbResource adb = (AdbResource) ResourceManager.getResource("adb");
		
		if(sr != null){
			try {
				runserialportCmd("su",null,0);		
				runserialportCmd("ls /system","framework",200);	
				runserialportCmd("cat /system/build.prop",null,0);	
				
				if(!enableEmmd){								
					log("enable EMMD by serialport...",Project.MSG_INFO);
					runserialportCmd("setprop persist.sys.dump.enable 1",null,0);	
					runserialportCmd("getprop persist.sys.dump.enable 1","1",10);							
					log("enable EMMD successfully",Project.MSG_INFO);
					enableEmmd = true;
				}				
			} catch (Exception setid) {
                System.out.println("prepare");
				PPATExceptionHandler.handleException("serialport is not available!!");
			}
		}
		if(adb != null){
                System.out.println(adb);
			try{
				runAdbCmd("adb get-state", "device", true);	
				runAdbCmd("adb root", null, true, 2000);
				runAdbCmd("adb root","root",true);
				runAdbCmd("adb shell cat /system/build.prop",null,true);
				runAdbCmd("adb shell cat /data/autoburn.log",null,true);
				
				if(!enableEmmd){
					log("enable EMMD by adb...",Project.MSG_INFO);
					runAdbCmd("adb shell setprop persist.sys.dump.enable 1", null, false);
					runAdbCmd("adb shell getprop persist.sys.dump.enable 1", "1", true);
					log("enable EMMD successfully",Project.MSG_INFO);
					enableEmmd = true;								
				}
				
			} catch (Exception e){			
				PPATExceptionHandler.handleException("adb is not available!!");
			}
		}
		
		log("set stay awake...", Project.MSG_INFO);
		StayAwake stayawake = new StayAwake();
		stayawake.setProject(this.getProject());
		stayawake.setFlag("true");
		stayawake.execute();

		log("screen unlock...", Project.MSG_INFO);
		ScreenUnlock unlock = new ScreenUnlock();
		unlock.setProject(this.getProject());						
		unlock.execute();

		log("unset stay awake...", Project.MSG_INFO);
		stayawake.setFlag("false");
		stayawake.execute();
	}
		
}
