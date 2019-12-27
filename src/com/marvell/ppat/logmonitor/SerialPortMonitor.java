package com.marvell.ppat.logmonitor;

import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import com.marvell.ppat.logmonitor.LogMonitor;
import com.marvell.ppat.listener.OutputListenerManager;
import com.marvell.ppat.resource.SerialPortResource;

public class SerialPortMonitor implements LogMonitor, SerialPortEventListener {

	private BufferedReader br = null;
	private OutputListenerManager listenerManager = null;
	private boolean monitorFlag = false;

	public SerialPortMonitor(SerialPortResource spr) {
		try {
			br = new BufferedReader(new InputStreamReader(spr.serialPort.getInputStream()));
		} catch (IOException e) {
			e.printStackTrace();
		}
		this.listenerManager = spr.listenerManager;
	}

	/*
	 * This method will be execute in a seperate thread
	 * 
	 * @see gnu.io.SerialPortEventListener#serialEvent(gnu.io.SerialPortEvent)
	 */
	public void serialEvent(SerialPortEvent event) {
		if (monitorFlag) {
			switch (event.getEventType()) {
			case SerialPortEvent.BI:
			case SerialPortEvent.OE:
			case SerialPortEvent.FE:
			case SerialPortEvent.PE:
			case SerialPortEvent.CD:
			case SerialPortEvent.CTS:
			case SerialPortEvent.DSR:
			case SerialPortEvent.RI:
			case SerialPortEvent.OUTPUT_BUFFER_EMPTY:
				break;
			case SerialPortEvent.DATA_AVAILABLE:

				try {
					String line = null;
					while ((line = br.readLine()) != null) {
						listenerManager.process(line);
					}
				} catch (IOException e) {
					if (e.getMessage().contains("zero bytes")) {
					} else {
						e.printStackTrace();
					}
				}
				break;
			}
		}
	}

	public void startMonitor() {
		monitorFlag = true;
	}

	public void stopMonitor() {
		monitorFlag = false;
	}
}
