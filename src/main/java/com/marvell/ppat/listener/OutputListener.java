package com.marvell.ppat.listener;

public interface OutputListener {
    void process(String line);

    boolean getResult();

    void cleanup();
}