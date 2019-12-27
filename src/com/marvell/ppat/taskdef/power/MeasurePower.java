package com.marvell.ppat.taskdef.power;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.driver.PrintColor;

public class MeasurePower extends Task {

	private String sample_t;
	private String voltage;
	private String save_f;
	private String port;
	private String server;
	private String sleep = "true";
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		try {
			if(this.getProject().getProperty("mode").equalsIgnoreCase("local")){
    		    PrintColor.printRed("================================================================");
    		    PrintColor.printRed("================================================================");
    			PrintColor.printRed("++         Start to measure power for                        +++");
    			PrintColor.printRed("                   " + sample_t + "s                                     ");
    			PrintColor.printRed("++         Local PPAT skip this step                         +++");
    			PrintColor.printRed("================================================================");
    			if(sleep.equals("true")){
					Thread.sleep(Integer.parseInt(sample_t) * 1000);
				}
			}else{
				new Thread(new Runnable(){

					@Override
					public void run() {
						// TODO Auto-generated method stub

						Client client;
						try {
							client = ClientFactory.getClient(server, 8888);

							client.measurePower(Integer.parseInt(sample_t), Integer.parseInt(voltage), save_f, port);
						} catch (TTransportException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						} catch (TException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
					
				}).start();
				
				if(sleep.equals("true")){
					Thread.sleep(Integer.parseInt(sample_t) * 1000);
				}
			}
		} catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public String getSample_t() {
		return sample_t;
	}
	public void setSample_t(String sample_t) {
		this.sample_t = sample_t;
	}
	public String getVoltage() {
		return voltage;
	}
	public void setVoltage(String voltage) {
		this.voltage = voltage;
	}
	public String getSave_f() {
		return save_f;
	}
	public void setSave_f(String save_f) {
		this.save_f = save_f;
	}
	public void setPort(String port){
		this.port = port;
	}
	public void setServer(String server){
		this.server = server;
	}

	public void setSleep(String sleep) {
		this.sleep = sleep;
	}
	
}
