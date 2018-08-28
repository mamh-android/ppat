package com.marvell.ppat.taskdef;

public interface Parser {
    void setCheckString(String checkString);

    void setMatchNum(int matchNum);

    void setRexFile(String rexFile);

    void setReverse(boolean reverse);
}