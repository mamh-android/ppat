package com.marvell.ppat.driver;

import com.marvell.ppat.roundpp.Component;
import com.marvell.ppat.taskdef.Reboot;
import com.marvell.ppat.taskdef.RoundCmdSet;
import com.marvell.ppat.taskdef.RoundPP;
import com.marvell.ppat.taskdef.SerialPortCmd;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Move;
import org.dom4j.Attribute;
import org.dom4j.Element;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

public class RunCaseWithPrecondition extends Task {

    int round = 0;
    private HashMap<String, String> tuneParams = new HashMap<String, String>();

    @Override
    public void execute() throws BuildException {
        try {

            run(InitRunCaseList.caseRoot, this.getProject());

            Reboot reboot = new Reboot();
            reboot.setProject(this.getProject());
            for (round = 1; round < RoundCmdSet.ROUND_CMD_SET.size(); round++) {
                if (round < (RoundCmdSet.ROUND_CMD_SET.size())) {
                    //two cases that reboot:
                    //1. round cmd set > 2
                    //2. not the last cmd set
                    reboot.execute();
                }

                RoundCmdSet cmdSet = RoundCmdSet.ROUND_CMD_SET.get(round);
                PrintColor.printGreen(this, "=============== Start to run #" + round + " command set ======================");
                cmdSet.run();

                run(InitRunCaseList.caseRoot, this.getProject());
            }
        } catch (BuildException e) {
            PPATExceptionHandler.handleException(e.getMessage());
        }
    }


    private void run(Element root, Project parentProj) {
        List<Element> lists = root.elements();
        String folderName = root.getPath().substring(1, root.getPath().length());

        Project precondProj = new Project();
        precondProj.init();
        Set<Map.Entry<Object, Object>> entrys;
        entrys = parentProj.getProperties().entrySet();
        for (Entry<Object, Object> entry : entrys) {
            String name = (String) entry.getKey();
            if (!name.equalsIgnoreCase("basedir")) {
                precondProj.setProperty(name, (String) entry.getValue());
            }
        }

        //find precondition.xml in folder
        File preconditionPlatform = new File(folderName + "/precondition." + PPATProject.project.getProperty("platform") + ".xml");
        File preconditionDef = new File(folderName + "/precondition.xml");

        //execute precondition
        if (preconditionDef.exists()) {
            precondProj = new Project();
            precondProj.init();
            for (Entry<Object, Object> entry : entrys) {
                String name = (String) entry.getKey();
                if (!name.equalsIgnoreCase("basedir")) {
                    precondProj.setProperty(name, (String) entry.getValue());
                }
            }
            ProjectHelper.configureProject(precondProj, preconditionDef);
            PrintColor.printGreen(this, "=============== Start to run " + root.getName() + " default  precondition ======================");
            precondProj.executeTarget(precondProj.getDefaultTarget());
            entrys = precondProj.getProperties().entrySet();
            precondProj.log("=============== Start to run " + root.getName() + " default  precondition ======================");
        }
        if ((PPATProject.project.getProperty("with_spc_precondition") != null) && (PPATProject.project.getProperty("with_spc_precondition").equalsIgnoreCase("true"))) {
            if (preconditionPlatform.exists()) {
                precondProj = new Project();
                precondProj.init();
                for (Entry<Object, Object> entry : entrys) {
                    String name = (String) entry.getKey();
                    if (!name.equalsIgnoreCase("basedir")) {
                        precondProj.setProperty(name, (String) entry.getValue());
                    }
                }
                RoundCmdSet.ROUND_CMD_SET.clear();
                RoundPP.root.clearContent();
                ProjectHelper.configureProject(precondProj, preconditionPlatform);
                PrintColor.printGreen(this, "=============== Start to run " + root.getName() + " precondition ======================");
                precondProj.executeTarget(precondProj.getDefaultTarget());

                //cope image files via FTP
                String jsonStr = this.getProject().getProperty("tc_list");
                if (jsonStr == null) {
                    return;
                } else {
                    try {
                        JSONObject json = new JSONObject(jsonStr);
                        String fileFolder = json.getString("folder");
                        String[] image_files = json.getString("test_files").split(",");
                        for (String file : image_files) {
                            if (file.trim() != "") {
                                FTPDriver.download(fileFolder, file, precondProj.getBaseDir().toString());
                            }
                        }
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        System.out.println("No specific image files to download");
                    }
                }

                entrys = precondProj.getProperties().entrySet();
                precondProj.log("=============== Start to run " + root.getName() + " precondition ======================");

                try {
                    if ((RoundCmdSet.ROUND_CMD_SET.size() > 0 && (round == RoundCmdSet.ROUND_CMD_SET.size() - 1)) || RoundCmdSet.ROUND_CMD_SET.size() == 0) {
                        Move moveLog = new Move();
                        moveLog.setProject(precondProj);
                        moveLog.setTodir(new File(PPATProject.project.getProperty("result_root") + "/" + root.getName() + "/"));
                        moveLog.setFile(preconditionPlatform);
                        moveLog.execute();
                        System.out.println("move " + preconditionPlatform.getPath() + " to " + PPATProject.project.getProperty("result_root") + "/" + root.getName() + "/");
                    }
                } catch (BuildException e) {

                }

            }
        }

        if (lists.size() == 0) {
            //here is the case node
            String casePath = root.getText();
            for (int i = 0; i < ListAllCases.casePathList.size(); i++) {
                if (ListAllCases.casePathList.get(i).equals(casePath)) {
                    String caseName = ListAllCases.caseList.get(i);
                    int index = casePath.lastIndexOf(".") + 1;
                    String spec = casePath.substring(0, index) + PPATProject.project.getProperty("platform") + ".xml";
                    System.out.println(spec);
                    File file = new File(spec);
                    if (file.exists()) {
                        casePath = spec;
                    }
//					entrys = precondProj.getProperties().entrySet();

                    Project caseProj = new Project();
                    caseProj.init();

                    //copy precondition project's properties to case project
                    for (Entry<Object, Object> entry : entrys) {
                        String name = (String) entry.getKey();
                        if (!name.equalsIgnoreCase("basedir")) {
                            caseProj.setProperty(name, (String) entry.getValue());
                        }
                    }

                    ProjectHelper.configureProject(caseProj, new File(casePath));

                    //run round cmd set

                    ExecuteCase exe = new ExecuteCase();
                    exe.setCaseProject(caseProj);
                    exe.setProject(caseProj);
                    exe.setCaseName(caseName);
                    exe.setCaseFile(casePath);

                    Reboot reboot = new Reboot();
                    reboot.setProject(caseProj);

                    if (RoundCmdSet.ROUND_CMD_SET.size() > 0 && round == 0) {
                        RoundCmdSet cmdSet = RoundCmdSet.ROUND_CMD_SET.get(round);
                        PrintColor.printGreen(this, "=============== Start to run #" + round + " command set ======================");
                        cmdSet.run();

                        //runcase
                        runCase(exe, caseProj, cmdSet);

//						for(int c = 0; c < RoundCmdSet.ROUND_CMD_SET.size(); c++){
//
//
//							PrintColor.printGreen(this, "=============== Finish to run #" + c + " command set ======================");
//							if(RoundCmdSet.ROUND_CMD_SET.size() > 1 && c < (RoundCmdSet.ROUND_CMD_SET.size() - 1)){
//								//two cases that reboot:
//								//1. round cmd set > 2
//								//2. not the last cmd set
//								reboot.execute();
//							}
//						}
//						RoundCmdSet.ROUND_CMD_SET.clear();
                    } else {
                        //runcase
                        runCase(exe, caseProj, null);
                    }
                }
            }
        } else {
            for (Element element : lists) {
                run(element, precondProj);
            }
        }
    }

    private void runCase(ExecuteCase exe, Project caseProj, RoundCmdSet cmdSet) {
        if (RoundPP.root.nodeCount() > 0) {
            //disable phs first
            SerialPortCmd serial = new SerialPortCmd();
            serial.setProject(caseProj);
            serial.execute("su");
            serial.execute("phs_cmd 5 manual");

            roundPP(RoundPP.root, exe, cmdSet);
        } else {
            exe.execute();
        }
    }

    private void roundPP(Element root, ExecuteCase ec, RoundCmdSet cmdSet) {
        List<Element> lists = root.elements();
        List<Attribute> attrs = root.attributes();
//		print(caseRoot);
        PrintColor.printwhite(this, "***********************************************");
        try {
            if (!root.isRootElement()) {
                String id = "";
                if (root.attributeValue("unit") != null && root.attributeValue("unit") != "") {
                    id = root.attributeValue("unit");
                }
                Class comp_class = Class.forName("com.marvell.ppat.roundpp." + root.getName().toUpperCase());
                Component comp = (Component) comp_class.newInstance();
                for (Iterator<Attribute> it = attrs.iterator(); it.hasNext(); ) {
                    Attribute attr = it.next();
                    Method comp_method = comp_class.getDeclaredMethod("do" + attr.getName(), String.class);
                    comp_method.invoke(comp, attr.getStringValue().trim());
                    PrintColor.printwhite(this, "*********" + root.getName() + " set " + attr.getName() + " : " + attr.getStringValue() + " ***********");
                    if (!attr.getName().equalsIgnoreCase("unit")) {
                        tuneParams.put(root.getName() + id + "_" + attr.getName(), "<" + root.getName() + id + "_" + attr.getName() + ">" + attr.getStringValue() + "</" + root.getName() + id + "_" + attr.getName() + ">");
                    }
                }
            }

        } catch (ClassNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (SecurityException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (InstantiationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (lists.size() == 0) {
            String tune = "";
            Set<String> keys = tuneParams.keySet();
            for (String key : keys) {
                tune += tuneParams.get(key);
            }
            PPATProject.project.setProperty("tune", tune);

            try {
                ec.execute();
            } catch (BuildException e) {
                PrintColor.printRed("Find " + e.getMessage());
                PrintColor.printRed("Reboot to run again!!!!");

                Reboot reboot = new Reboot();
                reboot.setProject(PPATProject.project);
                reboot.execute();

                if (cmdSet != null) {
                    PrintColor.printGreen(this, "=============== Start to run #" + RoundCmdSet.ROUND_CMD_SET.indexOf(cmdSet) + " command set ======================");
                    cmdSet.run();
                    PrintColor.printGreen(this, "=============== Finish to run #" + RoundCmdSet.ROUND_CMD_SET.indexOf(cmdSet) + " command set ======================");
                }
                ec.execute();
            }

        }
        for (Element element : lists) {
            roundPP(element, ec, cmdSet);
        }
    }
}
