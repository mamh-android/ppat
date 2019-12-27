package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;

public class ScreenUnlock extends Task {

	private final int maxTryTime = 2; 
	public void execute() throws BuildException {
		try {					
			if (ResourceManager.getResource("adb") !=null){			
				AdbCmd cmd = new AdbCmd();
				cmd.setProject(this.getProject());
				cmd.setPrintStdOut(false);
				
				for(int i=0; i < maxTryTime; i++){
					cmd.execute("adb shell input keyevent 82");
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}		
				cmd.setCheckString(null);
				cmd.execute("adb shell input keyevent 3");
			}else if ( ResourceManager.getResource("serialport") != null){ 		
				SerialPortCmd spc = new SerialPortCmd();
				spc.setProject(this.getProject());
				for(int i=0; i < maxTryTime; i++){
					spc.execute("input keyevent 82");
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}		
				spc.setCheckString(null);
				spc.execute("input keyevent 3");				
			}
			Thread.sleep(1000);
		} catch (InterruptedException e) {			
			e.printStackTrace();		
		} 
		
		
	}
}
