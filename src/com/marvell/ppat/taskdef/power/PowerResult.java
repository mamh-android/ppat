package com.marvell.ppat.taskdef.power;

import java.util.Map;
import java.util.Set;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.apache.tools.ant.BuildException;

import com.marvell.ppat.db.CommonConsumptions;
import com.marvell.ppat.db.DatabaseUtils;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.taskdef.CommonResult;
import com.marvell.ppat.taskdef.ParseInfo;
import com.marvell.ppat.taskdef.PropertyMap;

public class PowerResult extends CommonResult {

	private String file_n;
	protected String dutyCycle = " ";
	protected String fps = " ";
	protected String extendData = " ";
	private String server;
	private String stat_d = "true";

	public String getFile_n() {
		return file_n;
	}

	public void setFile_n(String file_n) {
		this.file_n = file_n;
	}

	public void setStat_d(String stat_d) {
		this.stat_d = stat_d;
	}

	public void setServer(String server) {
		this.server = server;
	}

	@Override
	public void generateResult() throws Exception {
		// TODO Auto-generated method stub
		Client client;
		try {
			if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
    			PrintColor.printRed("===========================================");
    			PrintColor.printRed("++       Start to get power result      +++");
    			PrintColor.printRed("++       Local PPAT skip this step      +++");
    			PrintColor.printRed("===========================================");

			}else{
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
			

			// add parse duty cycle info
			if(stat_d == "true"){
				ParseInfo parseDuty = new ParseInfo(stat_d);
				parseDuty.setProject(this.getProject());
				parseDuty.execute();

				dutyCycle = parseDuty.getValue("Duty_Cycle") + "\n"
						+ parseDuty.getValue("fps");
				
				dutyCycle = parseDuty.getValue("Duty_Cycle") + "\n"
						+ parseDuty.getValue("fps");
				
				
				if(PPATProject.project.getProperty("fps_info") != null){
					if(PPATProject.project.getProperty("fps_info") != "null"){
						dutyCycle += PPATProject.project.getProperty("fps_info");
						PPATProject.project.setProperty("fps_info", "null");
					}
				}

				try{
					if(!PPATProject.project.getProperty("thermal_start").equalsIgnoreCase("null")){
						dutyCycle += "before stat duty cycle, thermal info: \n" + PPATProject.project.getProperty("thermal_start");
						PPATProject.project.setProperty("thermal_start", "null");
					}
					if(!PPATProject.project.getProperty("thermal_end").equalsIgnoreCase("null")){
						dutyCycle += "\nafter stat duty cycle, thermal info: \n" + PPATProject.project.getProperty("thermal_end");
						PPATProject.project.setProperty("thermal_end", "null");
					}
				}catch (Exception e){
					
				}
				
				fps = parseDuty.getValue("FPS");
				if(fps == null){
					fps = "";
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
		try {
			String str = "";
			String comments = "";
			String tune = "";
			try {
				comments = PPATProject.project.getProperty("description")
						.replaceAll("&nbsp;", " ");
			} catch (Exception e) {
			}

			try{
				tune = PPATProject.project.getProperty("tune");
			}catch (Exception e){
				
			}
			if (comments != "") {
				str = "<TestResult>" + "<CaseID>" + caseName + "</CaseID>"
						+ "<BatteryCurrent>"
						+ PPATProject.project.getProperty("avgBattery")
						+ "</BatteryCurrent>" + "<VccMainCurrent>"
						+ PPATProject.project.getProperty("avgVcc")
						+ "</VccMainCurrent>" + "<VccMainVoltage>"
						+ PPATProject.project.getProperty("avgVccVoltage")
						+ "</VccMainVoltage>" 
						+ "<Comments>" + comments + "</Comments>";
				try {
					String gcfps = PPATProject.project.getProperty("GC_fps");
					if (!gcfps.equalsIgnoreCase("null")) {
						str += "<GC_fps>"
								+ gcfps
								+ "</GC_fps>";
						PPATProject.project.setProperty("GC_fps", "null");
						fps = gcfps;
					}
				} catch (Exception e) {
				}
			} else {
				str = "<TestResult>" + "<CaseID>" + caseName + "</CaseID>"
						+ "<BatteryCurrent>"
						+ PPATProject.project.getProperty("avgBattery")
						+ "</BatteryCurrent>" + "<VccMainCurrent>"
						+ PPATProject.project.getProperty("avgVcc")
						+ "</VccMainCurrent>" + "<VccMainVoltage>"
						+ PPATProject.project.getProperty("avgVccVoltage")
						+ "</VccMainVoltage>";
				try {
					String gcfps = PPATProject.project.getProperty("GC_fps");
					if (!gcfps.equalsIgnoreCase("null")) {
						str += "<GC_fps>"
								+ gcfps
								+ "</GC_fps>";
						PPATProject.project.setProperty("GC_fps", "null");
						fps = gcfps;
					}
				} catch (Exception e) {
				}
			}
			if (tune != "") {
				str += tune;
			}
			try {
				String codec_fps = PPATProject.project.getProperty("codec_fps");
				if (!codec_fps.equalsIgnoreCase("null")) {
					str += "<codec_fps>" + codec_fps + "</codec_fps>";
					PPATProject.project.setProperty("codec_fps", "null");
				}
				String total_frame_num = PPATProject.project.getProperty("total_frame_num");
				if (!total_frame_num.equalsIgnoreCase("null")) {
					str += "<total_frame_num>" + total_frame_num
							+ "</total_frame_num>";
					PPATProject.project.setProperty("total_frame_num", "null");
				}
				String awePlayerfps = PPATProject.project.getProperty("AwesomePlayer_fps");
				if(!awePlayerfps.equalsIgnoreCase("null")) {
					str += "<AwesomePlayer_fps>" + awePlayerfps
							+ "</AwesomePlayer_fps>";
					PPATProject.project.setProperty("AwesomePlayer_fps", "null");
				}
			} catch (Exception e) {
			}
			
			try {
				String video_fps = PPATProject.project.getProperty("video_fps");
				if (!video_fps.equalsIgnoreCase("null")) {
					str += "<video_fps>" + video_fps + "</video_fps>";
					PPATProject.project.setProperty("video_fps", "null");

					fps = video_fps;
				}
			} catch (Exception e) {
			}
			try {
				String display_fps = PPATProject.project.getProperty("preview_fps");
				if (!display_fps.equalsIgnoreCase("null")) {
					str += "<preview_fps>" + display_fps + "</preview_fps>";
					PPATProject.project.setProperty("preview_fps", "null");
					fps = display_fps;
				}
			} catch (Exception e) {
			}
			try{
				Set<String> keys = PropertyMap.properties.keySet();
				for(String key : keys){
					str += "<" + key + ">" + PropertyMap.properties.get(key) + "</" + key + ">";
				}
				PropertyMap.properties.clear();
			}catch(Exception e){
				
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
				e.printStackTrace();
			}
			if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
    			this.getProject().setProperty("SyncToDB", "false");
			}
			if (this.getProject().getProperty("SyncToDB")
					.equalsIgnoreCase("true")) {
				dutyCycle = dutyCycle.replaceAll("&lt;", "<");
				String battery = PPATProject.project.getProperty("avgBattery");
				if (battery == null || battery.equalsIgnoreCase("NaN")
						|| battery.equalsIgnoreCase("NULL")) {
					return;
				}
				String vcc = PPATProject.project.getProperty("avgVcc");

				String vcc_main_power = PPATProject.project.getProperty("avgVccPower");
				String db_name = PPATProject.project.getProperty(
						"db_name");

				String image_date = PPATProject.project.getProperty(
						"image_date");
				
				String assigner = PPATProject.project.getProperty("assigner");
				String platform = PPATProject.project.getProperty("platform");
				String device = PPATProject.project.getProperty("device");
				String branch = PPATProject.project.getProperty("os_version") + "_" + PPATProject.project.getProperty("release_version");
				String purpose = PPATProject.project.getProperty("purpose") + comments;
				String precondition = PPATProject.project.getProperty("precondition");
				if(precondition == null){
					precondition = "";
				}
				int user_id = DatabaseUtils.insertOrGetUser(assigner);
				String task_id = DatabaseUtils.insertOrGetTask(user_id, platform, device, branch, precondition, comments, purpose, db_name, image_date);
				
				if( platform.equalsIgnoreCase("hln3ff") && branch.equalsIgnoreCase("lp5.1_k314_beta1") && db_name.equalsIgnoreCase("daily")){
					comments =  this.getProject().getProperty("adb_device_id");
				}
				int power_record_id = DatabaseUtils.insetPowerRecord(caseName, platform, device, branch, user_id, image_date, db_name, comments, battery, vcc, vcc_main_power, dutyCycle, fps, pt4File, task_id, purpose);
				String cpu0_freq = PPATProject.project.getProperty("cpu0");
				if(cpu0_freq != null){
					DatabaseUtils.insertComponentsInfo("cpu0", cpu0_freq, power_record_id);
				}
				
				String cpu4_freq = PPATProject.project.getProperty("cpu4");
				if(cpu4_freq != null){
					DatabaseUtils.insertComponentsInfo("cpu4", cpu4_freq, power_record_id);
				}
				String ddr_freq = PPATProject.project.getProperty("ddr");
				if(ddr_freq != null){
					DatabaseUtils.insertComponentsInfo("ddr", ddr_freq, power_record_id);
				}
				String vpu_freq = PPATProject.project.getProperty("vpu0");
				if(vpu_freq != null){
					DatabaseUtils.insertComponentsInfo("vpu0", vpu_freq, power_record_id);
				}
				String gpu_freq = PPATProject.project.getProperty("gpu0");
				if(gpu_freq != null){
					DatabaseUtils.insertComponentsInfo("gpu0", gpu_freq, power_record_id);
				}
				String gpu1_freq = PPATProject.project.getProperty("gpu1");
				if(gpu1_freq != null){
					DatabaseUtils.insertComponentsInfo("gpu1", gpu1_freq, power_record_id);
				}
				String gpu2_freq = PPATProject.project.getProperty("gpu2");
				if(gpu2_freq != null){
					DatabaseUtils.insertComponentsInfo("gpu2", gpu2_freq, power_record_id);
				}
				String vpu1_freq = PPATProject.project.getProperty("vpu1");
				if(vpu1_freq != null){
					DatabaseUtils.insertComponentsInfo("vpu1", vpu1_freq, power_record_id);
				}
				if (db_name.equalsIgnoreCase("helen")) {
					CommonConsumptions.insert_to_consumptions(
							"helnconsumptions", "helnscenarios", caseName,
							image_date, battery, vcc, dutyCycle.replaceAll("@",
									"\n"), pt4File, fps, PPATProject.project.
									getProperty("avgVccPower"));
				} else if (db_name.equalsIgnoreCase("helnlte")) {
					CommonConsumptions.insert_to_consumptions(
							"helnlteconsumptions", "helnltescenarios",
							caseName, image_date, battery, vcc, dutyCycle
									.replaceAll("@", "\n"), pt4File, fps, PPATProject.project.getProperty("avgVccPower"));
				} else if (db_name.equalsIgnoreCase("daily")) {
					CommonConsumptions.insertData(
							"edenconsumptions",
							"edenscenarios",
							caseName,
							image_date,
							battery,
							vcc,
							dutyCycle.replaceAll("@", "\n"),
							pt4File,
							fps,
							PPATProject.project.getProperty("soc"),
							PPATProject.project.getProperty("board"),
							PPATProject.project.getProperty("os_version")
									+ "_"
									+ PPATProject.project.getProperty(
											"release_version"),PPATProject.project.getProperty("avgVccPower"));
				} else {
					CommonConsumptions.insert_to_ondemands(
							caseName,
							image_date,
							battery,
							vcc,
							dutyCycle.replaceAll("@", "\n"),
							PPATProject.project.getProperty("purpose") + comments,
							fps,
							cpu0_freq,
							gpu_freq,
							vpu_freq,
							ddr_freq,
							PPATProject.project.getProperty("assigner"),
							PPATProject.project.getProperty("platform")
									+ PPATProject.project.getProperty(
											"release_version")
									+ PPATProject.project.getProperty(
											"os_version"), pt4File,
							"",//special commads that run before test
							PPATProject.project.getProperty("avgVccPower"),
							gpu1_freq, gpu2_freq, vpu1_freq);
					
				}
			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}

