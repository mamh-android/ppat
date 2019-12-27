package com.marvell.ppat.driver;

import java.io.File;

import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.types.FileSet;

import com.marvell.ppat.taskdef.HostCmd;
import com.marvell.ppat.taskdef.power.PowerReportFile;

public class PPATExceptionHandler {
	public static void handleException(String exceptionDetail){
		HostCmd rmOK = new HostCmd();
		rmOK.setProject(PPATProject.project);
		rmOK.setWorkingDirectory(PPATProject.project.getProperty("root"));
		//copy log
		Copy copy = new Copy();
		copy.setProject(PPATProject.project);
		copy.setTaskName("copy");
		FileSet fs = new FileSet();
		fs.setDir(new File("result/" + PPATProject.project.getProperty("run_time")));
		copy.addFileset(fs);
		copy.setTodir(new File(PPATProject.project.getProperty("backup_remote") + "result/" + PPATProject.project.getProperty("run_time")));
		copy.execute();
		String filePath = PowerReportFile.getInstance().getHTML().getAbsolutePath();
		
		PrintColor.printRed("[Exception]" + exceptionDetail);
		
		File file = new File(filePath);
		if(file.exists()){
			rmOK.execute("python /usr/local/bin/sendmail.py -l " + filePath + " -t " + PPATProject.project.getProperty("assigner"));
		}
		
		System.exit(1);
	}
}
