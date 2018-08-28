package com.marvell.ppat.taskdef;

import com.marvell.ppat.taskdef.power.Client;
import com.marvell.ppat.taskdef.power.ClientFactory;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class RemoteHostCmd extends Task {
    private String cmd = null;
    private String file = null;
    private String server;
    private String sample_t;
    private String sleep = "true";

    @Override
    public void execute() throws BuildException {

        new Thread(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub

                Client client;
                try {
                    client = ClientFactory.getClient(server, 8888);
                    client.runCmd(cmd, file);
                } catch (TTransportException e1) {
                    // TODO Auto-generated catch block
                    e1.printStackTrace();
                } catch (TException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

        }).start();


        if (sleep.equals("true")) {
            try {
                Thread.sleep(Integer.parseInt(sample_t) * 1000);
            } catch (NumberFormatException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    public void setSample_t(String sample_t) {
        this.sample_t = sample_t;
    }

    public void setCmd(String cmd) {
        this.cmd = cmd;
    }

    public void setFile(String file) {
        this.file = file;
    }

    public void setServer(String server) {
        this.server = server;
    }

    public void setSleep(String sleep) {
        this.sleep = sleep;
    }
}
