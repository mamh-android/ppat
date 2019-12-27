package com.marvell.ppat.driver;

import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;

public class Utils implements Comparator<String> {

	
	public static boolean deleteFile(File file){		
		if (!file.isDirectory()){
			return file.delete();		
		} 
		File[] fileList = file.listFiles();
		for (int i=0 ;i<fileList.length;i++){
			 if (!deleteFile(fileList[i])){		
				 return false;
			 }
		}		
		return file.delete();
		
	}
	
	
	/**
	 * get file or dictionary size
	 * 
	 * @param baseDirName
	 *
	 * @return long file/dir size (byte)
	 */
	public static long getFileSize(String baseDirName) {	
		long size = 0;
		File baseDir = new File(baseDirName);
		if (!baseDir.exists() ) {			
			System.out.println("ERR: " + baseDirName + " is not exist!");
			return 0;
		}
		if (!baseDir.isDirectory()){			
			return baseDir.length();
		}
		
		File[] filelist = baseDir.listFiles();	
		for (int i = 0; i < filelist.length; i++) {		
			size += getFileSize(filelist[i].toString());
		}		
		return size;
	}
	
	
	
	
	/**
	 * find files recursively
	 * 
	 * @param baseDirName
	 * @param targetFileName
	 * @param wildmatch
	 * @return file name found/null
	 */
	public static String findFiles(String baseDirName, String targetFileName,
			boolean wildmatch) {
		String tempName = null;
		// judge if the dir exist
		if(baseDirName.endsWith(File.separator)){
			baseDirName=baseDirName.substring(0,baseDirName.length()-1);
		}
		File baseDir = new File(baseDirName);
		if (!baseDir.exists() || !baseDir.isDirectory()) {
			System.out.println("ERR: [" + baseDirName + "]is not a directory!");
		} else {
			String[] filelist = baseDir.list();
			String fileReturn = null;
			for (int i = 0; i < filelist.length; i++) {
				File readfile = new File(baseDirName + "/" + filelist[i]);
				if (!readfile.isDirectory()) { // if it is a file
					tempName = readfile.getName();
					if (wildmatch && wildcardMatch(targetFileName, tempName)) {
						return baseDirName + "/" + filelist[i];

					} else if (tempName.equalsIgnoreCase(targetFileName)) {
						return baseDirName + "/" + filelist[i];
					}
				} else if (readfile.isDirectory() && !readfile.isHidden()) {
					fileReturn = findFiles(baseDirName + "/" + filelist[i],
							targetFileName, wildmatch);
					if (fileReturn != null) {
						break;
					}
				}
			}
			return fileReturn;
		}
		return null;
	}

	public static void listFiles(ArrayList<String> fileList, ArrayList<String> filePathList, String baseDirName, String fileSuffix){
		File baseDir = new File(baseDirName);
		String tempFileName = null;
		if (!baseDir.exists() || !baseDir.isDirectory()) {
			System.out.println("ERR: [" + baseDirName + "]is not a directory!");
		}else{
			String[] filelistOfBaseDir = baseDir.list();
			for(String fileName : filelistOfBaseDir){
				File file = new File(baseDir + "/" + fileName);
				if(!file.isDirectory()){//this is a file
					tempFileName = file.getName();
					if(tempFileName.endsWith(fileSuffix)){//this is a testcase
						tempFileName = tempFileName.split(fileSuffix)[0];
						if(tempFileName.contains(".")){
							String[] namelist = tempFileName.split("\\.");
							tempFileName = namelist[0];
							if(namelist.length > 1){
								if(!namelist[1].equalsIgnoreCase(PPATProject.project.getProperty("platform"))){
									continue;
								}
							}
						}
						if(!fileList.contains(tempFileName)){
							fileList.add(tempFileName);
							filePathList.add(baseDir + "/" + fileName);
						}
					}
				}else if(file.isDirectory() && !file.isHidden()){
					listFiles(fileList, filePathList, baseDirName + "/" + fileName, fileSuffix);
				}
			}
		}
	}
	/**
	 * used for special string match
	 * 
	 * @param pattern
	 * @param str
	 * @return true if match the string
	 */
	private static boolean wildcardMatch(String pattern, String str) {
		int patternLength = pattern.length();
		int strLength = str.length();
		int strIndex = 0;
		char ch;
		for (int patternIndex = 0; patternIndex < patternLength; patternIndex++) {
			ch = pattern.charAt(patternIndex);
			if (ch == '*') {
				while (strIndex < strLength) {
					if (wildcardMatch(pattern.substring(patternIndex + 1), str
							.substring(strIndex))) {
						return true;
					}
					strIndex++;
				}
			} else if (ch == '?') {
				strIndex++;
				if (strIndex > strLength) {
					return false;
				}
			} else {
				if ((strIndex >= strLength) || (ch != str.charAt(strIndex))) {
					return false;
				}
				strIndex++;
			}
		}
		return (strIndex == strLength);
	}



	/**
	 * transfer string with ${} to unify format
	 * 
	 * @param antProject
	 * @param antPath
	 * @return
	 */
	public static String TranferString(Project antProject, String antPath) {
		String path = "";
		if ((antPath != null) && (!antPath.equalsIgnoreCase(""))) {
			if (antPath.contains("\\")) {
				antPath = antPath.replace("\\", "/");
			}
			String[] folder = antPath.split("/");
			for (int i = 0; i < folder.length; i++) {
				if (folder[i].contains("$")) {
					folder[i] = folder[i].replace("$", "");
					folder[i] = folder[i].replace("{", "");
					folder[i] = folder[i].replace("}", "");
					folder[i] = antProject.getProperty(folder[i]);
				}
				path = path + folder[i] + "/";
			}
		}
		return path;
	}


	public int compare(String s1, String s2) {
		int value1 = Integer.valueOf(s1.split("\\s{1,}")[0]);
		int value2 = Integer.valueOf(s2.split("\\s{1,}")[0]);

		if (value1 < value2) {
			return -1;
		} else if (value1 > value2) {
			return 1;
		} else {
			return 0;
		}
	}

	/**
	 * delete null(space) from list
	 * 
	 * @param list
	 *            : ArrayList<String> target list
	 * @return ArrayList<String>
	 */
	public static ArrayList<String> deleteNullFromList(ArrayList<String> list) {
		// ArrayList<String> resultList = new ArrayList<String>();
		for (int i = 0; i < list.size(); i++) {
			if (list.get(i).equals("") || list.get(i) == null) {
				list.remove(i);
			}

		}
		return list;
	}
	
	
	public static LineNumberReader processExeCmd(String cmd) throws IOException {
		Process process = Runtime.getRuntime().exec(cmd);
		InputStreamReader ir = new InputStreamReader(process
				.getInputStream());
		LineNumberReader input = new LineNumberReader(ir);
		return input;
	}
	
	
	public static String getAllLocalHostIP(){ 
//        List<String> res=new ArrayList<String>(); 
        Enumeration netInterfaces; 
        try { 
            netInterfaces = NetworkInterface.getNetworkInterfaces(); 
            String ipaddr = null; 
            while (netInterfaces.hasMoreElements()) { 
                NetworkInterface ni = (NetworkInterface) netInterfaces.nextElement(); 
                Enumeration nii=ni.getInetAddresses(); 
                while(nii.hasMoreElements()){ 
                	ipaddr = ((InetAddress) nii.nextElement()).getHostAddress(); 
                    if ((ipaddr.indexOf(":") == -1) &&(!ipaddr.contains("127.0.0.1"))){                     	
                    	System.out.println("local ip=" +ipaddr); 
                    	return ipaddr;                    
                    } 
                } 
            } 
        } catch (SocketException e) { 
            e.printStackTrace(); 
        } 
        return null;
    } 
	

	public static String getLocalHostName(){ 
		String hostName=null;
		try {
			hostName = InetAddress.getLocalHost().getHostName().toString();
		} catch (UnknownHostException e) {	
			e.printStackTrace();
		}
		return hostName;
    } 
	
	
	
	/**
	 * used as sync flag for different progress
	 * @param filePath
	 */
	public static File syncWithFile(String filePath){
		File syncFile = new File(filePath);
		System.out.println("waiting sync flag to be released..."); 
		while(true){
			while (syncFile.exists()){
				try {
					System.out.println("come to SYNCFILE .exists");
					Thread.sleep(4000);
					
				} catch (InterruptedException e) {			
					e.printStackTrace();
				}
			}
			try {
				if(syncFile.createNewFile()){
					System.out.println("syncFile created, break it");
					break;
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return syncFile;
	}
	
	
	/**
	 * used as sync flag for different progress
	 * @param filePath
	 */
	public static File syncRelay(String relayPort){
		File syncFile = new File(relayPort);
		System.out.println("Waiting the relay sync flag to be released... relay port is "+relayPort); 
		while(true){
			while (syncFile.exists()){
				try {
					Thread.sleep(2000);
				} catch (InterruptedException e) {			
					e.printStackTrace();
				}
			}
			try {
				if(syncFile.createNewFile()){
					break;
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return syncFile;
	}

}
