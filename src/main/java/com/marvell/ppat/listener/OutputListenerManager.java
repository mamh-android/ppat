package com.marvell.ppat.listener;

import java.util.ArrayList;

public class OutputListenerManager {

    private OutputListener defaultListener = null;

    private ArrayList<OutputListener> list = new ArrayList<OutputListener>();

    public OutputListenerManager(OutputListener dl) {
        defaultListener = dl;
    }

    /**
     * The instance can be called in multi-thread, so need to sync
     * to ensure the safety of accessing list member
     *
     * @param listener
     */
    public synchronized void addListener(OutputListener listener) {
        list.add(listener);
    }

    public synchronized void removeListener(OutputListener listener) {
        list.remove(listener);
    }

    public synchronized void removeListener() {
        for (int i = 0; i < list.size(); i++) {
            //
            list.remove(i);
        }
    }

    public synchronized void process(String line) {
        for (OutputListener listener : list) {
            listener.process(line);
        }

        if (defaultListener != null) {
            defaultListener.process(line);
        }
    }

    public synchronized void cleanup() {
        for (OutputListener listener : list) {
            listener.cleanup();
        }

        if (defaultListener != null) {
            defaultListener.cleanup();
        }
//		System.out.println("listener manger");
    }
}
