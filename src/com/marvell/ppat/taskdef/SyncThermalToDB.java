package com.marvell.ppat.taskdef;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.apache.tools.ant.BuildException;

import com.marvell.ppat.db.DatabaseUtils;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.taskdef.power.Client;
import com.marvell.ppat.taskdef.power.ClientFactory;
import com.marvell.ppat.taskdef.power.PowerReportFile;

public class SyncThermalToDB extends CommonResult {
	
	private String file_n = "";
	private String server;
	
	public void setFile_n(String file_n) {
		this.file_n = file_n;
	}
	
	public void setServer(String server) {
		this.server = server;
	}
	
	@Override
	public void generateResult() throws Exception {
		Client client;
		try {
			if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
    			PrintColor.printRed("===========================================");
    			PrintColor.printRed("++       Start to get power result      +++");
    			PrintColor.printRed("++       Local PPAT skip this step      +++");
    			PrintColor.printRed("===========================================");

			}else{
				if(file_n != ""){
					client = ClientFactory.getClient(server, 8888);

					Map<String, String> res = client.getResult(
							file_n,
							true,
							true,
							false);

					PPATProject.project.setProperty("avgBattery", res.get("avgBat"));
					PPATProject.project.setProperty("avgPower", res.get("avgPower"));
					PPATProject.project.setProperty("avgVoltage", res.get("avgVoltage"));

					PPATProject.project.setProperty("avgVcc", res.get("avgVcc"));
					PPATProject.project
							.setProperty("avgVccPower", res.get("avgVccPower"));
					PPATProject.project.setProperty("avgVccVoltage",
							res.get("avgVccVoltage"));

					client.close();
				}
				
			}

		} catch (TTransportException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

	@Override
	public void generateReport() throws BuildException {
		// TODO Auto-generated method stub
		String comments = "";
		try {
			comments = PPATProject.project.getProperty("description")
					.replaceAll("&nbsp;", " ");
		} catch (Exception e) {
		}
		//parse temperature.log and usb_tc08.log
		String subcase_root = this.getProject().getProperty("subcase_root");
		File tempFile = new File(subcase_root + "/temperature.log");
		File tc08_file = new File(subcase_root + "/usb_tc08.log");
		float max_temp = 0.0f;
		BufferedReader br;
		
		//insert thermal_scenarios
		int thermal_scenario_id = DatabaseUtils.insertOrGetScenario("thermal_scenarios", caseName);
		String battery = "0";
		String vcc_main = "0";
		String vcc_main_power = "0";
		if(file_n != ""){
			battery = PPATProject.project.getProperty("avgBattery");
			vcc_main = PPATProject.project.getProperty("avgVcc");
			vcc_main_power = PPATProject.project.getProperty("avgVccPower");
		}
		String platform = this.getProject().getProperty("platform");
		String device = this.getProject().getProperty("device");
		String branch = this.getProject().getProperty("os_version") + "_" + this.getProject().getProperty("release_version");
		String image_date = this.getProject().getProperty("image_date");
		String run_type = this.getProject().getProperty("db_name");
		String log_link = PPATProject.project.getProperty(
				"log_path")
				+ "result/"
				+ PPATProject.project.getProperty("run_time")
				+ "/"
				+ caseName
				+ "/"
				+ PPATProject.project.getProperty("case_subdir");
		int thermal_record_id = 0;
		
		//parse tc08 file
		if(tc08_file.exists()){
			try {
				br = new BufferedReader(new InputStreamReader(
						new FileInputStream(tc08_file)));
				LineNumberReader reader = new LineNumberReader(br);
				String line = reader.readLine();

				ArrayList<ArrayList<String>> temp_results = new ArrayList<ArrayList<String>>();
				while(line != null){
					String[] temp_vals = line.split("\\s+");
					int arr_len = temp_vals.length;
					for(int i = 0; i < arr_len - 1; i++){
						String temp_val = temp_vals[i + 1];
						String time = temp_vals[0];
						float temp = Float.parseFloat(temp_val);
						if(temp > max_temp)
							max_temp = temp;
						if(temp_results.size() == (arr_len - 1)){//already has data, need append
							String val = "{x:" + time + ",y:" + temp_val + "}";
							temp_val = val;
							temp_results.get(i).add(temp_val);
						}else{//need add a new data
							ArrayList<String> temp_reulst_cols = new ArrayList<String>();
							String val = "{x:" + time + ",y:" + temp_val + "}";
							temp_val = val;
							temp_reulst_cols.add(temp_val);
							
							//add to temp
							temp_results.add(temp_reulst_cols);
						}
					}
					line = reader.readLine();
				}
				reader.close();
				//write thermal_reocrds
				thermal_record_id = DatabaseUtils.insertThermalRecord(platform, branch, device, max_temp, image_date, battery, vcc_main, vcc_main_power, log_link, thermal_scenario_id, comments);
				for(ArrayList<String> temp_result : temp_results){
					DatabaseUtils.insertThermalTempInfo(thermal_record_id, temp_result.toString(),"ch" + temp_results.indexOf(temp_result));
				}
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		if(tempFile.exists()){
			String PatternStr = "\\w+\\s+\\w+\\s+\\w+\\s+\\w+\\s+\\w+";
		    Pattern pattern = Pattern.compile(PatternStr);  
			try {
				br = new BufferedReader(new InputStreamReader(
						new FileInputStream(tempFile)));

				LineNumberReader reader = new LineNumberReader(br);
				String line = reader.readLine();

				ArrayList<ArrayList<String>> temp_results = new ArrayList<ArrayList<String>>();
				while(line != null){
				    Matcher matcher = pattern.matcher(line); 
					 if(matcher.find()){
						 String[] temp_vals = line.split("\\s+");
							int arr_len = temp_vals.length;
							for(int i = 0; i < arr_len - 1; i++){
								String temp_val = temp_vals[i + 1];
								String time = temp_vals[0];
								if(temp_results.size() == (arr_len - 1)){//already has data, need append
									int length = temp_val.length();
									if(length > 3){
										temp_val = temp_val.substring(0, length - 3);
										String val = "{x:" + time + ",y:" + temp_val + "}";
										temp_val = val;
									}
									temp_results.get(i).add(temp_val);
								}else{//need add a new data
									ArrayList<String> temp_reulst_cols = new ArrayList<String>();
									temp_reulst_cols.add(temp_val);
									
									//add to temp
									temp_results.add(temp_reulst_cols);
								}
							}
					 }
					line = reader.readLine();
				}
				reader.close();
				
				//write to db
				if(thermal_record_id == 0){
					PrintColor.printRed(this, "failed to get max temp!!!");
					return;
				}
				for(ArrayList<String> temp_result : temp_results){
					String y_axis_name = temp_result.remove(0);
					if(temp_result.size() > 1){
						if(y_axis_name.equalsIgnoreCase("Core_num") || y_axis_name.equalsIgnoreCase("stage")){
							DatabaseUtils.insertThermalFreqInfo(thermal_record_id, temp_result.toString(),y_axis_name, 1);
						}else if(y_axis_name.equalsIgnoreCase("temp")){
							DatabaseUtils.insertThermalTempInfo(thermal_record_id, temp_result.toString(),"SoC");
						}else{
							DatabaseUtils.insertThermalFreqInfo(thermal_record_id, temp_result.toString(),y_axis_name, 0);
						}
					}
				}
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		String result = "<TestResult>" + "<CaseID>" + caseName + "</CaseID>"
				+ "<MaxTemp>"
				+ PPATProject.project.getProperty("avgBattery")
				+ "</MaxTemp>"
				+ "<link>" + log_link + "</link>";
//		try {
//			PowerReportFile.getInstance().writeToReportDoc(result);
//			PowerReportFile.getInstance().updateResultXml();
//			PowerReportFile.getInstance().updateResultHtml();
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
	}

}
