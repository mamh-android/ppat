package com.marvell.ppat.driver;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Move;
import org.dom4j.Element;

import com.marvell.ppat.taskdef.Reboot;
import com.marvell.ppat.taskdef.RoundCmdSet;
import com.marvell.ppat.taskdef.RoundPP;

public class RunPrecondition extends Task {

	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		run(InitRunCaseList.caseRoot , this.getProject());
	}

	private void run(Element root, Project parentProj){
		List<Element> lists = root.elements();
		String folderName = root.getPath().substring(1, root.getPath().length());


		Project precondProj = new Project();
		precondProj.init();
		Set<Map.Entry<Object, Object>> entrys;
		entrys = parentProj.getProperties().entrySet(); 
        for (Entry<Object, Object> entry : entrys) {  
        	String name = (String)entry.getKey();
        	if(! name.equalsIgnoreCase("basedir")){
        		precondProj.setProperty(name, (String)entry.getValue());
        	}
        }  

		//find precondition.xml in folder 
		File preconditionPlatform = new File(folderName + "/precondition." + PPATProject.project.getProperty("platform") + ".xml");
		File preconditionDef = new File(folderName + "/precondition.xml");

		//execute precondition
		if(preconditionDef.exists()){
			precondProj = new Project();
			precondProj.init();
	        for (Entry<Object, Object> entry : entrys) {  
	        	String name = (String)entry.getKey();
	        	if(! name.equalsIgnoreCase("basedir")){
	        		precondProj.setProperty(name, (String)entry.getValue());
	        	}
	        }
			ProjectHelper.configureProject(precondProj, preconditionDef);
			PrintColor.printGreen(this, "=============== Start to run " + root.getName() + " default  precondition ======================");
			precondProj.executeTarget(precondProj.getDefaultTarget());
			entrys = precondProj.getProperties().entrySet(); 
			precondProj.log("=============== Start to run " + root.getName() + " default  precondition ======================");
		}

		if(preconditionPlatform.exists()){
			precondProj = new Project();
			precondProj.init();
	        for (Entry<Object, Object> entry : entrys) {  
	        	String name = (String)entry.getKey();
	        	if(! name.equalsIgnoreCase("basedir")){
	        		precondProj.setProperty(name, (String)entry.getValue());
	        	}
	        }
	        RoundCmdSet.ROUND_CMD_SET.clear();
	        RoundPP.root.clearContent();
			ProjectHelper.configureProject(precondProj, preconditionPlatform);
			PrintColor.printGreen(this, "=============== Start to run " + root.getName() + " precondition ======================");
			precondProj.executeTarget(precondProj.getDefaultTarget());
			entrys = precondProj.getProperties().entrySet(); 
			precondProj.log("=============== Start to run " + root.getName() + " precondition ======================");
		}

		for(Element element : lists){
			run(element, precondProj);
		}
	}
}
