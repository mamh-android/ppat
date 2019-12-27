package com.marvell.ppat.driver;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Ant;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class ParseCommonConfig extends Task {
	
	@Override
	public void execute() throws BuildException {
		PPATProject.project = this.getProject();
		String platfromConfigFilePath = "config/platform.xml";
		SAXReader saxReader = new SAXReader();
		try {
			File platform = new File(platfromConfigFilePath);
			if(!platform.exists()){
				PrintColor.printRed(this, "Can't find " + platfromConfigFilePath + "!!!");
				System.exit(-1);
			}
			Document domList = saxReader.read(platform); 					
			List<?> argList = domList.selectNodes("/PlatformConfig/PropertyConfig/Property");
			if (argList.isEmpty()) {
				PrintColor.printRed(this, "there is no Arg Property node!");
			} 
			else {
				for (Object al : argList) {
					Element listNode = (Element) al;
					String propertyKey = listNode.attributeValue("name").trim();
					String propertyValue = listNode.getText().trim();
					if (!propertyValue.trim().isEmpty()) {
						this.getProject().setProperty(propertyKey,propertyValue);
					}
				}
			}
			// init result folder
			if (this.getProject().getProperty("run_time") == null) {
				DateFormat df = new SimpleDateFormat("yyyy-MM-dd@HH-mm-ss");
				Date date = new Date();
				this.getProject().setProperty("run_time", df.format(date));
			}
			this.getProject().setProperty("root", this.getProject().getBaseDir().toString());
			String result_root = this.getProject().getBaseDir().toString() + "/result/"
					+ this.getProject().getProperty("run_time") + "/";
			this.getProject().setProperty(
					"result_root", result_root);
			
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
}
