package com.marvell.ppat.resource;

import java.util.ArrayList;

import com.marvell.ppat.listener.OutputListener;

public interface IOResource {
	
	public void addListener(OutputListener listener);
	
	public void removeListener();
	
	public void setRunCmdResult(boolean result);
	
	public boolean runCmd(String cmd, ArrayList<OutputListener> listenerList);
	
}
