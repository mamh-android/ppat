package com.marvell.ppat.resource;

import com.marvell.ppat.listener.OutputListener;

import java.util.ArrayList;

public interface IOResource {

    void addListener(OutputListener listener);

    void removeListener();

    void setRunCmdResult(boolean result);

    boolean runCmd(String cmd, ArrayList<OutputListener> listenerList);

}
