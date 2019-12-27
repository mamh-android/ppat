package com.marvell.ppat.logmonitor;

import java.util.ArrayList;
import java.util.List;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.logmonitor.LogMonitor;
import com.marvell.ppat.logmonitor.LogcatMonitor;
import com.marvell.ppat.logmonitor.SerialPortMonitor;
import com.marvell.ppat.resource.AdbResource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.resource.SerialPortResource;

public class LogMonitorFactory {
	private static List<LogMonitor> logMonitorList = null;
	private static boolean keepSerial = false; // for reboot keep the serial port logs
	
	public static List<LogMonitor> getLogMonitor(String os) {
		if (logMonitorList!=null && !keepSerial) return logMonitorList;
		
		if(logMonitorList==null){
			logMonitorList = new ArrayList<LogMonitor>();
		}
	//	logMonitorList = new ArrayList<LogMonitor>();

		/* add special log monitor */
		os = os.trim();
		if (os.equalsIgnoreCase("android")) {
			AdbResource lr = (AdbResource) ResourceManager.getResource("adb");
			if (lr != null) {
				if(PPATProject.project.getProperty("adblog_main").equalsIgnoreCase("true")){
					logMonitorList.add(new LogcatMonitor(lr, false,"main"));
					/* Add system log , added in 2012-08-03 */
					logMonitorList.add(new LogcatMonitor(lr, false,"system"));
				}			
				if(PPATProject.project.getProperty("adblog_radio").equalsIgnoreCase("true")){
					System.out.println("Add radio monitor to logcat list!!");
					logMonitorList.add(new LogcatMonitor(lr, false,"radio"));
				}
				if(PPATProject.project.getProperty("adblog_events").equalsIgnoreCase("true")){
					logMonitorList.add(new LogcatMonitor(lr, false,"events"));
				}
			}
		} else if (os.equalsIgnoreCase("windows")) {
			// TODO: add log monitor of windows
		}

		/* add serial port log monitor */
		SerialPortResource spr = (SerialPortResource) ResourceManager.getResource("serialport");
		if (spr != null && !keepSerial) {
			logMonitorList.add(new SerialPortMonitor(spr));
		}

		return logMonitorList;
	}
	
	public static void clearLogMonitor(){
		logMonitorList.clear();
		logMonitorList = null;
	}
	
	public static void removeLogMonitor(LogMonitor logMonitor){
		logMonitorList.remove(logMonitor);
	}
	
	public static void setSerialPortKeep(boolean bl){
		keepSerial = bl;
	}
}
