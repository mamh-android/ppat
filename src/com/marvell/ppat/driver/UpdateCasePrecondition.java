package com.marvell.ppat.driver;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Move;
import org.apache.tools.ant.types.FileSet;
import org.json.*;


/**
 * parse json string and update precondition.platform.xml
 * json string like
 * {
    "TestCaseList": [
    	{
    		"name": "1080p",
    		"property":{
    			"count": "3",
	            "stream": "2_hd_other_samsung_colorful_variety_h264_1080p_HP_10M.mp4",
	            "duration": "167"
    		}
    	},
    	{
    		"name": "720p",
    		"property":{
    			"count": "3",
    			"name": "720p",
	            "stream": "4_hd_other_samsung_colorful_variety_h264_720p_HP_3M.mp4",
	            "duration": "160"
    		}
    	},
    	{
    		"name": "home",
    		"count": "3"
    	}
    ],
	"roundcmd": [
		{
			"description": "test1",
			"commands": "adb&nbsp;root"
		},
		{
			"description": "test2",
			"commands": "adb&nbsp;remount"
		}
	 ],
     "roundpp": {
        "cpu": {
            "CoreNum": "1,2,3,4",
            "Frequency": "312000,624000,1066000,1183000"
         },
         "gpu0": {
            "Frequency": "312000,624000"
         }
     }
	}				    
  }
 *
 */

public class UpdateCasePrecondition extends Task {

	@Override
	public void execute() throws BuildException {
		String jsonStr = this.getProject().getProperty("tc_list");
		if(jsonStr == null){
			return;
		}else{
			try {
				JSONObject json = new JSONObject(jsonStr);				
				JSONArray jsonArr = json.getJSONArray("TestCaseList");
				if(jsonArr != null){
					for(int i = 0; i < jsonArr.length(); i++){
						JSONObject param = (JSONObject) jsonArr.get(i);
						String caseName = param.get("name").toString();

						FileWriter fileWriter = null;
						BufferedWriter bufferWriter = null;
						for(int j= 0; j < ListAllCases.casePathList.size(); j++){
							if(ListAllCases.caseList.get(j).equalsIgnoreCase(caseName)){
								//update precondition.platform.xml
								String casePath = ListAllCases.casePathList.get(j);
								int index = casePath.lastIndexOf("/");
								
								String filePath = casePath.substring(0, index)  + "/precondition." + PPATProject.project.getProperty("platform") + ".xml";
								File file = new File(filePath);
								if(!file.exists()){
									System.out.println("create new file: " + filePath);
									file.createNewFile();
								}
								fileWriter = new FileWriter(filePath, false);
								bufferWriter = new BufferedWriter(fileWriter);
								
								break;
							}
						}
						if(bufferWriter != null){
							//writer header
							writeHeaderToFile(bufferWriter);
							
							if(param.has("property")){
								JSONObject prop = (JSONObject) param.get("property");
								Iterator<String> propNames = prop.keys();
								String property;
								while(propNames.hasNext()){
									property = propNames.next();
									
									try{
										writePropertyToFile(bufferWriter, property, (String)prop.get(property));
									}catch(Exception e){
										
									}
									
								}
							}
						}

						Iterator<String> keys = json.keys();
						String name;
						while(keys.hasNext()){
							name = keys.next();
							if(json.get(name) instanceof JSONObject){
								if(name.equalsIgnoreCase("roundpp")){//for round PP
									writeWriteLine(bufferWriter, "\t\t<RoundPP>");
									JSONObject roundPPParam = (JSONObject) json.get(name);
									Iterator<String> compNames = roundPPParam.keys();
									String compName;
									while(compNames.hasNext()){
										compName = compNames.next();
										JSONObject compObj = (JSONObject) roundPPParam.get(compName);
										
										//write comp info to RoundPP
										writeRoundPPToFile(bufferWriter, compName, compObj);
										
									}
									writeWriteLine(bufferWriter, "\t\t</RoundPP>");
								}
							}else if(json.get(name) instanceof JSONArray){
								//update command set
								JSONArray arr = json.getJSONArray(name);
								for(int k = 0; k < arr.length(); k++){
									if(name.equalsIgnoreCase("roundcmd")){
										JSONObject input = (JSONObject) arr.get(k);
										String description = (String) input.get("description");
										String commands = ((String) input.get("commands")).replace("&nbsp;", " ").replace("&quot;","\"");
										PPATProject.project.setProperty("precondition", commands);
										writeWriteLine(bufferWriter, "\t\t<RoundCmdSet>");
										writeWriteLine(bufferWriter, "\t\t\t<SystemProperty key=\"description\" value=\"" + description.replace("&nbsp;", " ") + "\"/>");
										
										String[] commandArr = commands.split("&amps;|;");
										for(String cmd : commandArr){
											cmd = cmd.replace("\"", "&quot;");
											if(cmd.startsWith("adb")){
												writeWriteLine(bufferWriter, "\t\t\t<AdbCmd cmd=\"" + cmd.replace("&nbsp;", " ") + "\"/>");
											}else if(cmd.contains("table")){
												PPATProject.project.setProperty("SyncToTable", "ondemand");
											}else{
												writeWriteLine(bufferWriter, "\t\t\t<SerialPortCmd cmd=\"" + cmd.replace("&nbsp;", " ") + "\"/>");
											}
										}
										writeWriteLine(bufferWriter, "\t\t</RoundCmdSet>");
									}else if(name.equalsIgnoreCase("property")){
										JSONObject roundcmd = (JSONObject) arr.get(k);
										Iterator<String> props = roundcmd.keys();
										String proName;
										while(props.hasNext()){
											proName = props.next();
											if(bufferWriter != null){
												writePropertyToFile(bufferWriter, proName, (String)roundcmd.get(proName));
											}
											
										}
									}
								}
							}
						}

						//writer footer
						if(bufferWriter != null){
							writeFooterToFile(bufferWriter);
							bufferWriter.close();
						}
					}
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				System.out.println("No json string for case precondition");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * write bellow info
	 * <?xml version="1.0"?>
		<project name="case_basic_power_video_720p" basedir="." default="run">
		    <include file="${user.dir}/config/command.xml"/>
		    <target name="run">
	 */
	private void writeHeaderToFile(BufferedWriter bufferWriter){
		try {
			bufferWriter.write("<?xml version=\"1.0\"?>\n");
			bufferWriter.write("<project basedir=\".\" default=\"run\">\n");
			bufferWriter.write("\t<include file=\"${user.dir}/config/command.xml\"/>\n");
			bufferWriter.write("\t<target name=\"run\">\n");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * write 
	 * 		<SetProperty name="count" value="4"></SetProperty>
			<SystemProperty name="count" value="4"></SystemProperty>
	 * @param bufferWriter
	 * @param content
	 */
	private void writePropertyToFile(BufferedWriter bufferWriter, String name, String value){
		try {
			bufferWriter.write("\t\t<SetProperty name=\"" + name + "\" value=\"" + value.replace("&nbsp;", " ") + "\"/>\n");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void writeWriteLine(BufferedWriter bufferWriter, String line){
		try {
			bufferWriter.write(line + "\n");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * write 
	 * <RoundPP>
            <cpu>
                <CoreNum>1,2,3</CoreNum>
                <Frequency>312000,624000</Frequency>
            </cpu>
            <vpu>
                <unit id="1">
                    <Frequency>156000,416000</Frequency>
                </unit>
            </vpu>
      * </RoundPP>
	 */
	private void writeRoundPPToFile(BufferedWriter bufferWriter, String compName, JSONObject compObj){
		try {
			Iterator<String> compValues = compObj.keys();
			String val;
			
			if(compName.equalsIgnoreCase("ddr")){
				bufferWriter.write("\t\t\t<" + compName + ">\n");
				while(compValues.hasNext()){
					val = compValues.next();
					bufferWriter.write("\t\t\t\t<" + val + ">" + compObj.get(val) + "</" + val + ">\n");
				}
				bufferWriter.write("\t\t\t</" + compName + ">\n");
			}else{
				String name = compName.substring(0, 3);
				String id = compName.substring(3, 4);
				bufferWriter.write("\t\t\t<" + name + ">\n");
				bufferWriter.write("\t\t\t\t<unit id=\"" + id + "\">\n");
				while(compValues.hasNext()){
					val = compValues.next();
					bufferWriter.write("\t\t\t\t\t<" + val + ">" + compObj.get(val) + "</" + val + ">\n");
				}
				bufferWriter.write("\t\t\t\t</unit>\n");
				bufferWriter.write("\t\t\t</" + name + ">\n");
			}
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * write 
	 * 	</target>
	 * </project>
	 * @param bufferWriter
	 */
	private void writeFooterToFile(BufferedWriter bufferWriter){
		try {
			bufferWriter.write("\t</target>\n");
			bufferWriter.write("</project>\n");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
