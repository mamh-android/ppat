package com.marvell.ppat.driver;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Ant;

public class PrintColor {

	/**
	 *  
	 * @param color
	 * 	30:black
	    31:red
	    32:green
	    33:yellow
	    34:blue
	    35:purple
	    36:dark green
	    37:white
	 * @param str
	 */
	public static void printRed(Task task, String str){
		task.log("\033[1;31m" + str + "\033[m", Project.MSG_ERR);
//		System.out.println("\033[1;31m" + sdf.format(date) + " " + str + "\033[m");
	}

	public static void printRed(String str){
		System.out.println("\033[1;31m" + str + "\033[m");
	}
	
	public static void printwhite(Task task, String str){
		task.log(str, Project.MSG_INFO);
//		System.out.println("\033[1;37m" + sdf.format(date) + " " + str + "\033[m");
	}
	
	public static void printwhite(String str){
		System.out.println(str);
	}
	
	public static void printYellow(Task task, String str){
		task.log("\033[1;33m" + str + "\033[m");
//		System.out.println("\033[1;33m" + sdf.format(date) + " " + str + "\033[m");
	}
	
	public static void printYellow(String str){
		System.out.println("\033[1;33m" + str + "\033[m");
	}
	
	public static void printGreen(Task task, String str){
		task.log("\033[1;32m" + str + "\033[m");
//		System.out.println("\033[1;32m" + sdf.format(date) + " " + str + "\033[m");
	}
	
	public static void printGreen(String str){
		System.out.println("\033[1;32m" + str + "\033[m");
	}
}
