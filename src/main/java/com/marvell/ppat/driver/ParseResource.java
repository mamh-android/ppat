package com.marvell.ppat.driver;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class ParseResource extends Task {

    private String fileName;
    private static List<CreateResource> resources = new ArrayList<CreateResource>();

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        SAXReader saxReader = new SAXReader();
        String resName = "";
        try {
            File platform = new File(fileName);
            if (!platform.exists()) {
                PrintColor.printRed(this, "Can't find " + fileName + "!!!");
                System.exit(-1);
            }
            Document domList = saxReader.read(platform);
            List<?> argList = domList.selectNodes("/PlatformConfig/ResourceConfig/Resource");
            if (argList.isEmpty()) {
                System.out.println("there is no Arg Property node!");
            } else {
                for (Object al : argList) {
                    Element listNode = (Element) al;
                    resName = listNode.attributeValue("name");
                    log("resource: " + resName, Project.MSG_INFO);
                    /*
                     * if user do not set the attribute, it will use default
                     * value in CreateResource task
                     */
                    String port = listNode.attributeValue("port");
                    String rate = listNode.attributeValue("rate");
                    String remoteip = listNode.attributeValue("remoteip");
                    String user = listNode.attributeValue("user");
                    String pw = listNode.attributeValue("pw");

                    CreateResource create = new CreateResource();
                    create.setProject(this.getProject());
                    create.setTaskName("create");
                    create.setName(resName);
                    create.setPort(port);
                    create.setRate(rate);
                    create.setRemoteip(remoteip);
                    create.setUser(user);
                    create.setPw(pw);
//					create.setSpecFlag(getDeviceInfoFlag);
                    resources.add(create);
                    create.execute();
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void setFileName(String file) {
        this.fileName = file;
    }
}
