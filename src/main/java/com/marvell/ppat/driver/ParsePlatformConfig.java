package com.marvell.ppat.driver;

import com.marvell.ppat.taskdef.HostCmd;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class ParsePlatformConfig extends Task {

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        PrintColor.printwhite(this, "+++++++++++++++++++ Parse property of platform.xml ++++++++++++++++++");
        String platform = this.getProject().getProperty("platform");
        if (platform == null) {
            PrintColor.printRed(this, "platform info is empty!!!");
            System.exit(-1);
        }
        String platfromConfigFilePath = "config/platform." + platform + ".xml";

        if (this.getProject().getProperty("backup_remote") != null) {
            this.getProject().setProperty("remote_backup_flag", "true");
        }

        SAXReader saxReader = new SAXReader();
        try {
            File platfromConfigFile = new File(platfromConfigFilePath);
            if (!platfromConfigFile.exists()) {
                PrintColor.printRed(this, "Can't find " + platfromConfigFilePath
                        + "!!!");
                System.exit(-1);
            }
            Document domList = saxReader.read(platfromConfigFile);

            // parse property
            List<?> propList = domList
                    .selectNodes("/PlatformConfig/PropertyConfig/Property");
            if (propList.isEmpty()) {
                PrintColor.printRed(this, "there is no Arg Property node!");
            } else {
                for (Object al : propList) {
                    Element listNode = (Element) al;
                    String propertyKey = listNode.attributeValue("name").trim();
                    String propertyValue = listNode.getText().trim();
                    if (!propertyValue.trim().isEmpty()) {
                        PrintColor.printwhite(this, "system property: " + propertyKey
                                + " = " + propertyValue);
                        this.getProject().setProperty(propertyKey,
                                propertyValue);
                    }
                }
            }

            HostCmd cmd = new HostCmd();
            cmd.setProject(getProject());
            cmd.execute("hostname -I");
            ArrayList<String> out = cmd.getExeResult().stdout;

            String ptf_link = this.getProject().getProperty("log_path");

            this.getProject().setProperty("log_path", ptf_link.replaceAll("/\\d+[.]\\d+[.]\\d+[.]\\d+/", "/" + out.get(0).trim() + "/"));
            System.out.println(this.getProject().getProperty("power_server"));
            //parse resource
            List<?> resList = domList
                    .selectNodes("/PlatformConfig/ResourceConfig/Resource");
            if (resList.isEmpty()) {
                PrintColor.printRed(this, "there is no Arg Property node!");
            } else {
                String resourceName;
                for (Object res : resList) {
                    Element listNode = (Element) res;
                    resourceName = listNode.attributeValue("name");
                    PrintColor.printwhite(this, "resource: " + resourceName);
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
                    create.setName(resourceName);
                    create.setPort(port);
                    create.setRate(rate);
                    create.setRemoteip(remoteip);
                    create.setUser(user);
                    create.setPw(pw);
                    create.execute();
                }
            }

            List<?> argList = domList.selectNodes("/PlatformConfig/AutoBurnConfig/Property");
            if (argList.isEmpty()) {
            } else {
                for (Object al : argList) {
                    Element listNode = (Element) al;
                    String propertyKey = listNode.attributeValue("name").trim();
                    String propertyValue = listNode.getText().trim();
                    if (!propertyValue.trim().isEmpty()) {
                        if (!propertyValue.trim().isEmpty()) {
                            this.getProject().setProperty(propertyKey, propertyValue);
                        }
                    }
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
