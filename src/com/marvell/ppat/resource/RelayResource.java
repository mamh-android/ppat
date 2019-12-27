package com.marvell.ppat.resource;

import gnu.io.CommPortIdentifier;

import java.util.Enumeration;

import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;
import com.marvell.ppat.resource.Resource;
import com.marvell.ppat.resource.ResourceManager;
import com.marvell.ppat.taskdef.HostCmd;

public class RelayResource implements Resource {
	private String _port_ = null;
	private String _key_ = null;
	private String _relayPort_ = null;
	private int _rate_ = 9600;
	
	
	public RelayResource(String port, int rate, String key, String relayPort){
		this._key_ = key;
		this._port_ = port;
		this._rate_ = rate;
		this._relayPort_ = relayPort;
		
		HostCmd gc = new HostCmd();
        gc.setProject(PPATProject.project);
        
        
        
		for (String portUsing : relayPort.split(";"))
		{
			String[] setting = portUsing.split(":");
			PPATProject.project.setProperty("relay_" + setting[0].toLowerCase().trim(), setting[1]);
			PPATProject.project.setProperty("relay_" + setting[0].toLowerCase().trim(), setting[1]);
		}
		
		
		if(initResource(port)){
			ResourceManager.addResource(key, this);
			System.out.println("Initialize the relay success!!");
		}else{
			System.out.println("Initialize the relay FAILED!!");
			
		}
		
	}
	
	private boolean initResource(String port){
		String osname = System.getProperty("os.name","").toLowerCase();
		if ( port == null ) {
			if ( osname.startsWith("windows") ) {
				port = "COM1";
	 		} else if (osname.startsWith("linux")) {
	 			port = "/dev/ttyS0";
	 		} else {	 		
	 			System.out.println("init Relay Resource FAILED");
				System.exit(1);
	 		}
		}
		
		boolean portFound = false;
		CommPortIdentifier portId = null;
		
		for(int i = 0; i < 50 ; i++){
			System.out.println("========= Start to init the relay port for the "+i+" times.");
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();
//			CommPortIdentifier portId = null;
			while (portList.hasMoreElements()) {
//				System.out.println("++++++++++++++++++++++sacn the next port+++++++++++++++++++++");
				portId = (CommPortIdentifier) portList.nextElement();
				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equalsIgnoreCase(port)) {
						portFound = true;
						break;
					} 
				}
			}
			if(portFound){
				System.out.println("++++++++++++++++++++++Find the relay port!!+++++++++++++++++++++");
				break;
			}
			//System.out.println("++++++++++++++++++++++End of sacn the next port+++++++++++++++++++++");
			System.out.println("++++++++++++++++++++++The relay port status is "+portFound);
		}
		return portFound;
	}
	
	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		System.out.println("Close the relay success!!");
	}
	
	public String getPort(){
		return this._port_;
	}
	
	public String getKey(){
		return this._key_;
	}
	
	public String getRelayPort(){
		return this._relayPort_;
	}
	
	public int getRate(){
		return this._rate_;
	}
}
