package com.marvell.ppat.resource;

import com.marvell.ppat.listener.OutputListenerManager;


public class AdbResource implements Resource {
    public OutputListenerManager listenerManager;
    public final String key;

    public AdbResource(String key) {
        this.key = key;
        ResourceManager.addResource(key, this);
    }

    @Override
    public void cleanup() {
        // TODO Auto-generated method stub

    }

}
