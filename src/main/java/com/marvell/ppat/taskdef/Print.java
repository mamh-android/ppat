package com.marvell.ppat.taskdef;

import com.marvell.ppat.driver.PrintColor;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class Print extends Task {

    private String message;

    public void setMessage(String msg) {
        this.message = msg;
    }

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        PrintColor.printwhite(this.message);
    }
}
