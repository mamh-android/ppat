package com.marvell.ppat.taskdef.power;

import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TTransport;


public class Client extends DataService.Client {

    public TTransport transport;

    public Client(TProtocol prot, TTransport ftransport) {
        super(prot);
        this.transport = ftransport;
        // TODO Auto-generated constructor stub
    }

    public void close() {
        this.transport.close();
    }

}
