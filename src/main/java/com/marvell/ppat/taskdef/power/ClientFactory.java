package com.marvell.ppat.taskdef.power;

import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransportException;

public class ClientFactory {

    public static Client getClient(String ip, int port) throws TTransportException {
        TSocket transport = new TSocket(ip, port);

        TProtocol protocol = new TBinaryProtocol(transport);

        transport.open();

        Client client = new Client(protocol, transport);
        return client;
    }

}
