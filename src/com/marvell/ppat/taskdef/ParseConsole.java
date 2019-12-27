package com.marvell.ppat.taskdef;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;

public class ParseConsole extends ParseCommon {
	public void parseResult() throws BuildException {
		String caseName = this.getProject().getProperty("case_name");
		String folder = this.getProject().getProperty("case_root");
		BufferedReader br;
		try {
			br = new BufferedReader(new InputStreamReader(
					new FileInputStream(folder + "/" + caseName + ".log")));
			String line = null;
			int hits = 0;
			boolean matched = true;
			/*use cmp file to match*/ 
			if (rexFile != null) {  
				BufferedReader matchbr = new BufferedReader(
						new InputStreamReader(new FileInputStream(rexFile)));
				String cmp = "";
				while ((line = br.readLine()) != null) {
					if (matched && (cmp = matchbr.readLine()) == null) {
						if (hits != 0){
							System.out.println("cmp file is over, all items are matched! ");
							setTempResult ("PASS");	
							setTempDetail("rex file are all matched!");
							break;						
						}
						System.out.println("RexFile is empty, please have a check!");
						setTempResult ("FAIL");			
						setTempDetail("RexFile is empty, please have a check!");
					}
					
					if(Pattern.compile(cmp).matcher(line).find()){
						hits++;
						matched = true;
					}else{
						matched = false;
					}
				}
				matchbr.close();				
			}
			/*use check string to match*/ 
			else {
				while ((line = br.readLine()) != null) {
					if(Pattern.compile(checkString).matcher(line).find()){
						hits++;
					}				
					if (hits >= matchNum) {
						System.out.println("check string ["+checkString +"] matched "+ hits + " times!");			
						setTempResult ("PASS");	
						setTempDetail("check string matched "+ hits + " times!");
						break;
					}				
				}
			}
			br.close();			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	@Override
	public void parseResultDetail() throws BuildException {
		// TODO Auto-generated method stub
		
	}	
}
