package com.marvell.ppat.listener;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.taskdef.SerialPortCmd;

public class LogListener implements OutputListener {
	private PrintStream fLog = null; 
	private PrintStream local_print = null;
	private boolean print = false;
	private boolean input_char = true;
	public LogListener(String fileName) {
		// create file log
		try {
//			fLog = new PrintStream(new File(fileName));
			fLog = new PrintStream(new FileOutputStream(new File(fileName), true));
		} catch (FileNotFoundException e1) {
			e1.printStackTrace();
		}
	}
	
	public void process(String line) {
			fLog.println(line);
			if(line.contains("cat /sys/kernel/debug")){
				print = true;
			}
			if(line.contains("fakecmd") || line.startsWith("shell@") ){
				print = false;
			}
//			if((line.contains("`") && PPATProject.project.getProperty("platform").equalsIgnoreCase("ulc1ff")  && input_char) || line.contains(">> fkcmd")){
//				SerialPortCmd serial = new SerialPortCmd();
//				serial.setProject(PPATProject.project);
//				serial.execute("`");
//				input_char = false;
//			}
//			if(!input_char && line.contains("# fkcmd") ){
//				input_char = true;
//			}
			if(print){

				File outfile = new File(PPATProject.project.getProperty("result_root") + PPATProject.project.getProperty("case_name") + "/" + PPATProject.project.getProperty("case_name") +".log");
				try {
					local_print = new PrintStream(new FileOutputStream(outfile, true));
					local_print.println(line);
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				System.out.println(line);
			}
	}

	public void cleanup() {
		fLog.close();
	}
	
	public boolean getResult(){
		return true;
	}
}

