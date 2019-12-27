package com.marvell.ppat.listener;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.marvell.ppat.resource.IOResource;

public class CmpListener implements OutputListener {

	private IOResource resource = null;
	
	private boolean result = false;
	
	private int maxLine = 0;
	
	private int processedLine = 0;
	
	private int currentCmpLine = 0;
	
	private String[] cmp;
	
	private boolean pattern = false;
	
	public CmpListener(IOResource resource, String[] cmp, int maxLine) {
		this.resource = resource;
		this.cmp = cmp;
		this.maxLine = maxLine;	
	}
	
	public CmpListener(IOResource resource, String[] cmp) {
		this.resource = resource;
		this.cmp = cmp;
		this.maxLine = 100;
	}
	
	public void process(String line) {
		
		//System.out.println("The array cmp is "+cmp[currentCmpLine]);
		//System.out.println(line.contains(cmp[currentCmpLine]));
		if(pattern){
			Pattern pattern = Pattern.compile(cmp[currentCmpLine]);
			Matcher matcher = pattern.matcher(line.trim());
			if(matcher.find())
				this.result = true;
		}else{
			if (line.contains(cmp[currentCmpLine])){
				this.result = true;
			}
		}
		//System.out.println("The current in SE string is : "+line);
		if (this.result == true) {
			if ( ++currentCmpLine == cmp.length ) {
				synchronized (resource) {
					resource.notify();
					return;
				}
			}
		}
		
		if (++processedLine == maxLine ) {
			synchronized (resource) {
				this.result = false;
				resource.notify();
			}
		}
	}

	public void cleanup() {
		processedLine = 0;		
		currentCmpLine = 0;
		maxLine = 0;
	}
	
	public boolean getResult(){
		return result;
	}
	
	public void setPattern(boolean isPattern){
		this.pattern = isPattern;
	}

}

