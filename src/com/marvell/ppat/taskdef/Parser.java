package com.marvell.ppat.taskdef;

public interface Parser {
	public void setCheckString(String checkString);
	public void setMatchNum(int matchNum);
	public void setRexFile(String rexFile);
	public void setReverse(boolean reverse);
}