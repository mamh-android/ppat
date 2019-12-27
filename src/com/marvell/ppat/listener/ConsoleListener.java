package com.marvell.ppat.listener;


public class ConsoleListener implements OutputListener{
	
	private String printTag = "";
	
	public ConsoleListener(String printTag){
		this.printTag = printTag;
	}

	@Override
	public void process(String line) {
		// TODO Auto-generated method stub
		if(line.isEmpty() || line.contains("#")||line.contains("<")){ //skip serial port marks
			return;
		}
		System.out.println(this.printTag + line);
	}

	@Override
	public boolean getResult() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		
	}

}
