package com.marvell.ppat.driver;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.io.File;
import java.util.List;

public class ParseProperty extends Task {

    private String fileName;

    @Override
    public void execute() throws BuildException {
        // TODO Auto-generated method stub
        SAXReader saxReader = new SAXReader();
        try {
            File platform = new File(fileName);
            if (!platform.exists()) {
                PrintColor.printRed(this, "Can't find " + fileName + "!!!");
                System.exit(-1);
            }
            Document domList = saxReader.read(platform);
            List<?> argList = domList.selectNodes("/PlatformConfig/PropertyConfig/Property");
            if (argList.isEmpty()) {
                System.out.println("there is no Arg Property node!");
            } else {
                for (Object al : argList) {
                    Element listNode = (Element) al;
                    String propertyKey = listNode.attributeValue("name").trim();
                    String propertyValue = listNode.getText().trim();
                    if (!propertyValue.trim().isEmpty()) {
                        System.out.println("system property: " + propertyKey + " = " + propertyValue);
                        this.getProject().setProperty(propertyKey, propertyValue);
                    }
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
