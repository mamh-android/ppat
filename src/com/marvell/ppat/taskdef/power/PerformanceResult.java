package com.marvell.ppat.taskdef.power;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Set;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.db.CommonConsumptions;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.taskdef.CommonResult;
import com.marvell.ppat.taskdef.ParseInfo;
import com.marvell.ppat.taskdef.PropertyMap;

public class PerformanceResult extends CommonResult {

	private String file_n;
	private String server;
	private String dutyCycle;
	private String fps = "0";
	private String perf = "0";

	public void setFile_n(String file_n) {
		this.file_n = file_n;
	}

	public void setServer(String server) {
		this.server = server;
	}

	@Override
	public void generateResult() throws Exception {
		// TODO Auto-generated method stub
		Client client;
		try {
			if (this.getProject().getProperty("mode").equalsIgnoreCase("local")) {
				PrintColor
						.printRed("===========================================");
				PrintColor
						.printRed("++       Start to get power result      +++");
				PrintColor
						.printRed("++       Local PPAT skip this step      +++");
				PrintColor
						.printRed("===========================================");
			} else {
				client = ClientFactory.getClient(server, 8888);

				Map<String, String> res = client.getResult(file_n, true, true, false);

				PPATProject.project
						.setProperty("avgBattery", res.get("avgBat"));
				PPATProject.project
						.setProperty("avgPower", res.get("avgPower"));
				PPATProject.project.setProperty("avgVoltage",
						res.get("avgVoltage"));

				PPATProject.project.setProperty("avgVcc", res.get("avgVcc"));
				PPATProject.project.setProperty("avgVccPower",
						res.get("avgVccPower"));
				PPATProject.project.setProperty("avgVccVoltage",
						res.get("avgVccVoltage"));
				client.close();
			}

			// add parse duty cycle info
			ParseInfo parseDuty = new ParseInfo();
			parseDuty.setProject(this.getProject());
			parseDuty.execute();

			dutyCycle = parseDuty.getValue("Duty_Cycle") + "\n"
					+ parseDuty.getValue("fps");

			dutyCycle = parseDuty.getValue("Duty_Cycle") + "\n"
					+ parseDuty.getValue("fps");

			if (PPATProject.project.getProperty("fps_info") != null) {
				if (PPATProject.project.getProperty("fps_info") != "null") {
					dutyCycle += PPATProject.project.getProperty("fps_info");
					PPATProject.project.setProperty("fps_info", "null");
				}
			}

			try {
				if (!PPATProject.project.getProperty("thermal_start")
						.equalsIgnoreCase("null")) {
					dutyCycle += "before stat duty cycle, thermal info: \n"
							+ PPATProject.project.getProperty("thermal_start");
					PPATProject.project.setProperty("thermal_start", "null");
				}
				if (!PPATProject.project.getProperty("thermal_end")
						.equalsIgnoreCase("null")) {
					dutyCycle += "\nafter stat duty cycle, thermal info: \n"
							+ PPATProject.project.getProperty("thermal_end");
					PPATProject.project.setProperty("thermal_end", "null");
				}
			} catch (Exception e) {

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
		// read ui performance data from log file
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					new FileInputStream(folder + "/temp.log")));
			String line = null;
			try {
				while ((line = br.readLine()) != null) {
					String[] res = line.split("\\s+");
					caseName = res[0];
					perf = res[1];
					fps = res[2];
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				fps = "0";
			}
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		String str = "";
		String tune = "";
		try {
			tune = PPATProject.project.getProperty("tune");
		} catch (Exception e) {
		}
		
		String comments = "";
		try {
			comments = PPATProject.project.getProperty("description")
					.replaceAll("&nbsp;", " ");
			String purpose = PPATProject.project.getProperty("purpose");
			PPATProject.project.setProperty("purpose", purpose + " " + comments);
		} catch (Exception e) {
		}
		
		if (comments != "") {
			str = "<TestResult>" + "<CaseID>"
					+ caseName
					+ "</CaseID>"
					+ "<BatteryCurrent>"
					+ PPATProject.project.getProperty("avgBattery")
					+ "</BatteryCurrent>"
					+ "<VccMainCurrent>"
					+ PPATProject.project.getProperty("avgVcc")
					+ "</VccMainCurrent>"
					+ "<VccMainVoltage>"
					+ PPATProject.project.getProperty("avgVccVoltage")
					+ "</VccMainVoltage>"
					+ "<Response_Time>"
					+ perf
					+ "</Response_Time>"
					+ "<fps>"
					+ fps
					+ "</fps>"
					+ "<Comments>"
					+ comments + "</Comments>";

		} else {
			str = "<TestResult>" + "<CaseID>" + caseName + "</CaseID>"
					+ "<BatteryCurrent>"
					+ PPATProject.project.getProperty("avgBattery")
					+ "</BatteryCurrent>" + "<VccMainCurrent>"
					+ PPATProject.project.getProperty("avgVcc")
					+ "</VccMainCurrent>" + "<VccMainVoltage>"
					+ PPATProject.project.getProperty("avgVccVoltage")
					+ "</VccMainVoltage>" + "<Response_Time>" + perf
					+ "</Response_Time>" + "<fps>" + fps + "</fps>";
		}

		if (tune != "") {
			str += tune;
		}
		try {
			Set<String> keys = PropertyMap.properties.keySet();
			for (String key : keys) {
				str += "<" + key + ">" + PropertyMap.properties.get(key) + "</"
						+ key + ">";
			}
			PropertyMap.properties.clear();
		} catch (Exception e) {

		}
		String pt4File = PPATProject.project.getProperty(
				"log_path")
				+ "result/"
				+ PPATProject.project.getProperty("run_time")
				+ "/"
				+ caseName
				+ "/"
				+ PPATProject.project.getProperty("case_subdir");
		str += "<link>" + pt4File + "</link>";
		str += "</TestResult>";
		try {
			PowerReportFile.getInstance().writeToReportDoc(str);
			PowerReportFile.getInstance().updateResultXml();
			PowerReportFile.getInstance().updateResultHtml();
		} catch (Exception e) {
			System.out.println("Do nothing!");
		}

		try {
			dutyCycle = dutyCycle.replaceAll("&lt;", "<");
			String battery = PPATProject.project.getProperty("avgBattery");
			String vcc = PPATProject.project.getProperty("avgVcc");
			String image_date = PPATProject.project.getProperty("image_date");

			String soc = PPATProject.project.getProperty("board");
			String branch = PPATProject.project
					.getProperty("release_version");
			if (PPATProject.project.getProperty("mode").equalsIgnoreCase("local")) {
				PrintColor.printRed("Run PPAT with local mode, don't write db");
			} else {
				CommonConsumptions.insert_to_performance(caseName, image_date,
						perf, fps, battery, vcc, dutyCycle, soc, branch,
						PPATProject.project.getProperty("purpose") + comments);

			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
