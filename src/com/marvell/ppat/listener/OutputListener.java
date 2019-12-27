package com.marvell.ppat.listener;

public interface OutputListener {
	public void process(String line);
	public boolean getResult();
	public void cleanup();
}