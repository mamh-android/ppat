package com.marvell.ppat.taskdef;

import java.util.ArrayList;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;

public class ParseFPS extends Task {

	private String cmd;
	private static String GC_FPS = ".*FPS.*";
	private static String RECORD_FPS = ".*Video fps::fps=.*";
	private static String PREVIEW_FPS = ".*preview fps::fps=.*";
	private static String PLAYBACK_FPS = ".*playback::fps.*";
	private static String CODEC_FPS = ".*codec level.*fps.*";
	
	public void setCmd(String cmd){
		this.cmd = cmd;
	}
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
			SerialPortCmd serial = new SerialPortCmd();
			serial.setProject(this.getProject());
			serial.execute(this.cmd.split("adb shell|adb")[1]);
		}else{
			AdbCmd cmd = new AdbCmd();
			cmd.setProject(this.getProject());
			cmd.execute(this.cmd);
			CmdExecutionResult result;
			result = cmd.getExeResult();
			ArrayList<String> infos;
			infos = result.stdout;
			StringBuilder info = new StringBuilder();
			for(String line : infos){
				info.append(line).append("\n");
				if (Pattern.compile(GC_FPS).matcher(line).find()){
					String reg = "FPS is";
					int index = line.indexOf(reg);
					String FPS = line.substring(index + reg.length() + 1,
							line.length());
					
					PPATProject.project.setProperty("GC_fps", FPS);
				}else if (Pattern.compile(PLAYBACK_FPS).matcher(line).find()){
					String[] results = line.split(",");
					String frameNum = results[0].split("\\s+")[5];
					String aweFps = results[2].split("\\s+")[2];
					PPATProject.project.setProperty("AwesomePlayer_fps", aweFps);
					PPATProject.project.setProperty("total_frame_num", frameNum);
				}else if(Pattern.compile(CODEC_FPS).matcher(line).find()){
					String reg = "fps:";
					int index = line.indexOf(reg);
					String codecFps = line.substring(index + reg.length(), line.length()).trim();
					PPATProject.project.setProperty("codec_fps", codecFps);
				}else if(Pattern.compile(RECORD_FPS).matcher(line).find()){
					String reg = "Video fps::fps=";
					int index = line.indexOf(reg);
					String FPS = line.substring(index + reg.length(), line.length());
					PPATProject.project.setProperty("video_fps", FPS);
				}else if(Pattern.compile(PREVIEW_FPS).matcher(line).find()){
					String reg = "preview fps::fps=";
					int index = line.indexOf(reg);
					String FPS = line.substring(index + reg.length(), line.length());
					PPATProject.project.setProperty("preview_fps", FPS);
				}
			}
			String fps_info = PPATProject.project.getProperty("fps_info");
			PPATProject.project.setProperty("fps_info", fps_info + info.toString());
		}
	}
}
