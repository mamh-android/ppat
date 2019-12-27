package com.marvell.ppat.resource;

import java.util.ArrayList;

import com.marvell.ppat.resource.Resource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.taskdef.HostCmd;
import com.marvell.ppat.driver.CmdExecutionResult;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.listener.OutputListenerManager;


public class AdbResource implements Resource{
	public OutputListenerManager listenerManager;
	public final String key;
	
	public AdbResource(String key) {	
		this.key = key;
		ResourceManager.addResource(key, this);
	}
	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		
	}

}
