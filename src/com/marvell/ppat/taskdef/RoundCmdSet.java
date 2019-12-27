package com.marvell.ppat.taskdef;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.marvell.ppat.taskdef.RoundPP.Frequency;
import com.marvell.ppat.taskdef.RoundPP.Unit;
import com.marvell.ppat.taskdef.RoundPP.Vpu;

public class RoundCmdSet extends Task {
	
	public static ArrayList<RoundCmdSet> ROUND_CMD_SET = new ArrayList<RoundCmdSet>();
	
	private Vector sysProps = new Vector();
	private Vector hostCmds = new Vector();
	private Vector adbCmds = new Vector();
	private Vector serialCmds = new Vector();
	private Vector sleeps = new Vector();
	private Vector echos = new Vector();
	
	public SystemProperty createSystemProperty(){
		SystemProperty sysProp = new SystemProperty();
		sysProps.add(sysProp);
		return sysProp;
	}
	
	public AdbCmd createAdbCmd(){
		AdbCmd adbCmd = new AdbCmd();
		adbCmds.add(adbCmd);
		return adbCmd;
	}
	
	public SerialPortCmd createSerialPortCmd(){
		SerialPortCmd serialCmd = new SerialPortCmd();
		serialCmds.add(serialCmd);
		return serialCmd;
	}
	
	public HostCmd createHostCmd(){
		HostCmd hostCmd = new HostCmd();
		hostCmds.add(hostCmd);
		return hostCmd;
	}
	
	@Override
	public void execute() throws BuildException {
		ROUND_CMD_SET.add(this);
	}

	public void run(){
		for (Iterator it=sysProps.iterator(); it.hasNext(); ) {
			SystemProperty sysProp = (SystemProperty)it.next();
			sysProp.setProject(getProject());
			sysProp.execute();
        }
		for (Iterator it=adbCmds.iterator(); it.hasNext(); ) {
			AdbCmd adbCmd = (AdbCmd)it.next();
			adbCmd.setProject(getProject());
			if(adbCmd.cmd.contains("reboot")){
				Reboot reboot = new Reboot();
				reboot.setProject(this.getProject());
				reboot.setType("adb");
				reboot.execute();
			}else{
				adbCmd.execute();
			}
        }
		for (Iterator it=serialCmds.iterator(); it.hasNext(); ) {
			SerialPortCmd serialCmd = (SerialPortCmd)it.next();
			serialCmd.setProject(getProject());
			serialCmd.execute();
        }
	}
}
