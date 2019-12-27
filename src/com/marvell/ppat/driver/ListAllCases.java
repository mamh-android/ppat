package com.marvell.ppat.driver;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.Path;

/**
 * InitCaseList scan case folder and fill an ArrayList with case name
 *
 */
public class ListAllCases extends Task {
	
	/* store all case list in a static ArrayList */
	public static ArrayList<String> caseList = new ArrayList<String>();//case name list
	public static ArrayList<String> casePathList = new ArrayList<String>();//case path list
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		String caseSearchPath = this.getProject().getProperty("case_searchpath");
		String[] caseSearchPathList = caseSearchPath.split(":");

		for (int i = 0; i < caseSearchPathList.length; i++) {
			Utils.listFiles(caseList, casePathList, caseSearchPathList[i], ".ppat.xml");
		}
		
		if(caseList.size() == 0){
			PrintColor.printRed(this, "Not find any test case in " + caseSearchPath + "!!!!");
		}else{
			System.out.println("caseID\t\tcaseName");
			for(int i = 0; i < caseList.size(); i++){
				System.out.println("\t" + i + "\t\t" + caseList.get(i));
			}
		}
	}

}
