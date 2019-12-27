package com.marvell.ppat.resource;

import gnu.io.CommPortIdentifier;
import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Random;
import java.util.TooManyListenersException;

import com.marvell.ppat.driver.PPATExceptionHandler;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.listener.CmpListener;
import com.marvell.ppat.listener.LogListener;
import com.marvell.ppat.listener.OutputListener;
import com.marvell.ppat.listener.OutputListenerManager;
import com.marvell.ppat.listener.SerialPortListener;
import com.marvell.ppat.logmonitor.SerialPortMonitor;

public class SerialPortResource implements Resource,IOResource {
	public final SerialPort serialPort;
	private SerialPortMonitor sm =null;
	private boolean result = false;
	private long timeout = 30000;
	private long defaultTimeout = 30000;
	public final OutputListenerManager listenerManager;

	public SerialPortResource(String port, int rate, String key, boolean flag) {
		serialPort = initResource(port, rate);
		listenerManager = null;
		ResourceManager.addResource(key, this);
	}
	public SerialPortResource(String port, int rate, String key) {
		serialPort = initResource(port, rate);
		if(serialPort == null){
			listenerManager = null;
			System.out.println("Initialize the serial port FAILED!!!");
			PPATExceptionHandler.handleException("Initialize the serial port FAILED!!!");
		}else{
			// create listener manager, default listener is logListener		
			listenerManager = new OutputListenerManager(new LogListener(PPATProject.project.getProperty("result_root")+key + ".log"));	
            
			listenerManager.addListener(new SerialPortListener(Thread.currentThread()));

            /*
             * create 3rd-party serial port even listener, which will trigger
             * all the SPLogListener event
             */
			sm = new SerialPortMonitor(this);
			sm.startMonitor();
			try {
				serialPort.addEventListener(sm);		
			}catch (TooManyListenersException e) {		
				e.printStackTrace();		
			}	
			ResourceManager.addResource(key, this);
			System.out.println("Initialize the serial port success!");	
		}

	}
	
	private SerialPort initResource(String port, int rate) {
		String osname = System.getProperty("os.name","").toLowerCase();
		if ( port == null ) {
			if ( osname.startsWith("windows") ) {
				port = "COM1";
	 		} else if (osname.startsWith("linux")) {
	 			port = "/dev/ttyUSB0";
	 		} else {	 	
	 			System.out.println("Initialize the serial port FAILED!!!");
				PPATExceptionHandler.handleException("Initialize the serial port FAILED!!!");
	 		}
		}
		
		boolean portFound = false;
		CommPortIdentifier portId = null;
		SerialPort serialPort = null;
		for(int i = 0; i < 1 ; i++){ /////// i < 50//for testing without serial port
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();
			while (portList.hasMoreElements()) {
				portId = (CommPortIdentifier) portList.nextElement();
				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equalsIgnoreCase(port)) {
						portFound = true;
						break;
					} 
				}
			}
			if(portFound){
				try {
					serialPort = (SerialPort) portId.open("SimpleReadApp", 2000);
					serialPort.notifyOnDataAvailable(true);
					serialPort.setSerialPortParams(rate, SerialPort.DATABITS_8, 
							   SerialPort.STOPBITS_1, 
							   SerialPort.PARITY_NONE);
					if ( port.indexOf("tty") < 0 ) {
						serialPort.notifyOnOutputEmpty(true);
						System.out.println("Retry to initialize the serial ports while the port has not been found!!");
						Thread.sleep(1000);
					}else{
						break;
					}
				} catch (PortInUseException e) {
					e.printStackTrace();
					if(i == 49){
						System.out.println("PortInUseException found after retry 50 times!");
						e.printStackTrace();
					}
							
				} catch (UnsupportedCommOperationException e1) {
					e1.printStackTrace();
					if(i == 49){
						System.out.println("UnsupportedCommOperationException found after retry 50 times!");
						e1.printStackTrace();
					}
				} catch (Exception e2) {
					e2.printStackTrace();
					if(i == 49){
						System.out.println("USB convert serial port Exception found after retry 50 times!");
						e2.printStackTrace();
					}
				}
			}else{
				if(i == 49){
					System.out.println("Serial port initialize failed after retry 50 times!");
				}
				try {
					int randomNum = Integer.parseInt(port.replace("/dev/ttyUSB", ""))*1000 + 1;
					Random rd = new Random();
					int randomTime = rd.nextInt(1000)+randomNum;
					System.out.println("Sleep the random time "+randomTime);
					Thread.sleep(randomTime);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				System.out.println("Retry to initialize the serial ports!!");
			}
		}
		
		return serialPort;
	}
	
	@Override
	public void addListener(OutputListener listener) {
		// TODO Auto-generated method stub
		listenerManager.addListener(listener);
	}

	@Override
	public void removeListener() {
		// TODO Auto-generated method stub
		listenerManager.removeListener();
	}

	@Override
	public void setRunCmdResult(boolean result) {
		// TODO Auto-generated method stub
		this.result = result;
	}

	@Override
	public boolean runCmd(String cmd, ArrayList<OutputListener> listenerList) {
		// TODO Auto-generated method stub
		OutputStream outputStream = null;
		try {
			outputStream = serialPort.getOutputStream();
		} catch (IOException e) {		
			e.printStackTrace();
 			timeout = defaultTimeout;
		}
		
		// add listener
		if ( listenerList != null ) {
			for ( OutputListener listener : listenerList ) {
				listenerManager.addListener(listener);
			}
		}
		
		//need to run command
		if(cmd!=null){
			char[] cmdCharArr = cmd.toCharArray();
			try{
				for(char cmdChar : cmdCharArr){
					byte b = Byte.parseByte((int)cmdChar + "");
					byte[] cmdb = new byte[1];
					cmdb[0] = b;
					
					outputStream.write(cmdb);//write a singer char
					if (PPATProject.project.getProperty("platform").equalsIgnoreCase("ulc1ff")){
						Thread.sleep(100);
					}else{
						Thread.sleep(1);
					}
				}
				
				byte[] cmdBuff = new byte[2];
				cmdBuff[0] = 13;
				cmdBuff[1] = 10;
				
				outputStream.write(cmdBuff);
				outputStream.flush();
			}catch (IOException e){
				
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			
//			byte[] ary = cmd.getBytes();
//			byte[] cmdBuff = new byte[cmd.length() + 2];
//			int i = 0;
//			for (i = 0; i < ary.length; i++) {
//				cmdBuff[i] = ary[i];
//			}
//			// add /r/n
//			cmdBuff[i] = 13;
//			cmdBuff[i + 1] = 10;
//			
//			try {
//				outputStream.write(cmdBuff);
//				outputStream.flush();
//			} catch (Exception e) {				
//				e.printStackTrace();
//				timeout = defaultTimeout;
//			}
		}		

		// if no need to listen the result, return true with sleep
		// to sync I/O and program exe
		if ( listenerList == null ) {
//			try {
//				Thread.sleep(300);
//			} catch (InterruptedException e) {
//				e.printStackTrace();
//			}
			timeout = defaultTimeout;
			return true;
		}
		synchronized (this) {
			try {
				this.wait(timeout);
//				System.out.println("timeout");
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		timeout = defaultTimeout;
		boolean result = true;
		for (OutputListener listener : listenerList){
			result &= listener.getResult();
			listenerManager.removeListener(listener);
		}
		return result;
	}

	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		if( System.getProperty("os.name","").toLowerCase().startsWith("linux")){				
		} else{
			serialPort.removeEventListener();
			serialPort.close();
		}
		if(listenerManager != null){
			listenerManager.cleanup();//release the listener band to this resource
			sm.stopMonitor();
		}
	}

	/*for parse com log*/
	public boolean parseOut(String compare, int maxLine) {
		ArrayList<OutputListener> listenerList = new ArrayList<OutputListener>();
		String[] cmpAry = new String[]{compare};	
		listenerList.add(new CmpListener(this, cmpAry, maxLine));		
		return runCmd(null, listenerList);
	}
	
	public boolean parseOut(String[] compare, int maxLine) {
		ArrayList<OutputListener> listenerList = new ArrayList<OutputListener>();
		listenerList.add(new CmpListener(this, compare, maxLine));		
		return runCmd(null, listenerList);
	}
	
	public void setTimeout(Long timeout){
		this.timeout = timeout;
	}
	public boolean runCmd(String cmd, String compare, int maxLine, boolean isPattern) {
		String[] cmpAry = new String[]{compare};
		
		return runCmd(cmd, cmpAry, maxLine, isPattern);
	}
	public boolean runCmd(String cmd, String compare, int maxLine) {
		return runCmd(cmd,compare,maxLine,false);
	}
	public boolean runCmd(String cmd, String[] compare, int maxLine, boolean isPattern) {
		ArrayList<OutputListener> listenerList = new ArrayList<OutputListener>();
		CmpListener opl = new CmpListener(this, compare, maxLine);
		if (isPattern){
			opl.setPattern(isPattern);
		}
		listenerList.add(opl);
		
		return runCmd(cmd, listenerList);
	}	
}

