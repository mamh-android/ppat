package com.marvell.ppat.taskdef;

import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.logmonitor.LogMonitor;
import com.marvell.ppat.logmonitor.LogMonitorFactory;
import com.marvell.ppat.resource.LTKResource;
import com.marvell.ppat.resource.ResourceManager;

public class PowerCtrlUSB extends Task {

	private String flag = "";

	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
    	LTKResource ltk = (LTKResource) ResourceManager.getResource("ltk");
    	HostCmd gc = new HostCmd();
        gc.setProject(PPATProject.project);
        if(ltk == null){
            if(flag.equalsIgnoreCase("on")){
            	if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
        			PrintColor.printRed(this, "===========================================");
        			PrintColor.printRed(this, "++       Plug in usb                    +++");
        			PrintColor.printRed(this, "++       Local PPAT skip this step      +++");
        			PrintColor.printRed(this, "===========================================");
        		}else{
        			gc.execute("./tools/relay "+ PPATProject.project.getProperty("relay_usb")+" 0");
                    sleep(1);
                    gc.execute("./tools/relay "+ PPATProject.project.getProperty("relay_usb")+" 1");

                	if(this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")){
                      /*start monitor log*/		
                		List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(super.getProject().getProperty("os"));
                		if(!logMonitorList.isEmpty()){
            				for(int i =0; i<logMonitorList.size();i++){
            					System.out.println("Stop the "+ i +"logMonitor " + logMonitorList.get(i));
            					logMonitorList.get(i).stopMonitor();
            				}
            			}
            			LogMonitorFactory.clearLogMonitor();
                		
                		logMonitorList = LogMonitorFactory.getLogMonitor(PPATProject.project.getProperty("os"));
            			if(!logMonitorList.isEmpty()){
            				for(int i =0; i<logMonitorList.size();i++){
            					System.out.println("Ready to start the "+i+" logcat monitor "+ logMonitorList.get(i));
            					logMonitorList.get(i).startMonitor();
            				}
            			}	
                	}
        		}
            }else{
            	if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
        			PrintColor.printRed(this, "===========================================");
        			PrintColor.printRed(this, "++       Plug out usb                   +++");
        			PrintColor.printRed(this, "++       Local PPAT skip this step      +++");
        			PrintColor.printRed(this, "===========================================");
        		}else{
        			/*stop monitor log*/		
                	if(this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")){
                		List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(super.getProject().getProperty("os"));
                		if(!logMonitorList.isEmpty()){
                			for(int i =0; i<logMonitorList.size();i++){
                				System.out.println("Stop the "+i+" logcat monitor "+ logMonitorList.get(i));
            					logMonitorList.get(i).stopMonitor();
                			}
                		}
                	}
        			gc.execute("./tools/relay "+ PPATProject.project.getProperty("relay_usb")+" 1");
                    sleep(1);
                    gc.execute("./tools/relay "+ PPATProject.project.getProperty("relay_usb")+" 0");
        		}
            }
        }else{
    		LTKCmd ltkcmd = new LTKCmd();
        	
        	if(flag.equalsIgnoreCase("on")){
        		if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
        			PrintColor.printRed(this, "===========================================");
        			PrintColor.printRed(this, "++       Plug in usb                    +++");
        			PrintColor.printRed(this, "++       Local PPAT skip this step      +++");
        			PrintColor.printRed(this, "===========================================");
        		}else{
        			String usb_port = PPATProject.project.getProperty("relay_usb");
        			if(usb_port != null){
        				gc.execute("./tools/relay "+ usb_port+" 0");
                        sleep(1);
                        gc.execute("./tools/relay "+ usb_port+" 1");
        			}else{
        				ltkcmd.setCmd("vbus 0");
                    	ltkcmd.execute();
                        sleep(1);
        				ltkcmd.setCmd("vbus 1");
                    	ltkcmd.execute();
        			}
        			
                	if(this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")){
                        /*start monitor log*/		
                  		List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(super.getProject().getProperty("os"));
                  		if(!logMonitorList.isEmpty()){
              				for(int i =0; i<logMonitorList.size();i++){
              					System.out.println("Stop the "+ i +"logMonitor " + logMonitorList.get(i));
              					logMonitorList.get(i).stopMonitor();
              				}
              			}
              			LogMonitorFactory.clearLogMonitor();
                  		
                  		logMonitorList = LogMonitorFactory.getLogMonitor(PPATProject.project.getProperty("os"));
              			if(!logMonitorList.isEmpty()){
              				for(int i =0; i<logMonitorList.size();i++){
              					System.out.println("Ready to start the "+i+" logcat monitor "+ logMonitorList.get(i));
              					logMonitorList.get(i).startMonitor();
              				}
              			}	
                  	}
        		}
        		
                
            }else{
            	if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
        			PrintColor.printRed(this, "===========================================");
        			PrintColor.printRed(this, "++       Plug out usb                   +++");
        			PrintColor.printRed(this, "++       Local PPAT skip this step      +++");
        			PrintColor.printRed(this, "===========================================");
        		}else{
        			/*stop monitor log*/		
                	if(this.getProject().getProperty("logcat") != null && this.getProject().getProperty("logcat").equalsIgnoreCase("true")){
                		List<LogMonitor> logMonitorList = LogMonitorFactory.getLogMonitor(super.getProject().getProperty("os"));
                		if(!logMonitorList.isEmpty()){
                			for(int i =0; i<logMonitorList.size();i++){
                				System.out.println("Stop the "+i+" logcat monitor "+ logMonitorList.get(i));
            					logMonitorList.get(i).stopMonitor();
                			}
                		}
                	}
                	String usb_port = PPATProject.project.getProperty("relay_usb");
        			if(usb_port != null){
        				gc.execute("./tools/relay "+ usb_port+" 1");
                        sleep(1);
                        gc.execute("./tools/relay "+ usb_port+" 0");
        			}else{
        				ltkcmd.setCmd("vbus 1");
                    	ltkcmd.execute();
                        sleep(1);
        				ltkcmd.setCmd("vbus 0");
                    	ltkcmd.execute();
        			}
        		}
            }
        }
	}

	public String getFlag() {
		return flag;
	}

	public void setFlag(String flag) {
		this.flag = flag;
	}
	
	private void sleep(int seconds){
		try {
			Thread.sleep(seconds * 1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
