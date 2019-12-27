package com.marvell.ppat.driver;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Target;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Ant;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.XMLWriter;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * init the list of test case, update precondition.xml
 * @author zhoulz
 *
 */
public class InitRunCaseList extends Task {
	
	public static Document caseDoc = DocumentHelper.createDocument();
	public static Element caseRoot = caseDoc.addElement("case");
	
	@Override
	public void execute() throws BuildException {
		// TODO Auto-generated method stub
		String caselist = this.getProject().getProperty("tc_list");
		String[] runcaselist = null;
		if(caselist == null){
			PrintColor.printRed(this, "NOT choose any test case to run!!!");
			System.exit(-1);
		}else{
			//parse json str
			JSONObject json;
			try {
				json = new JSONObject(caselist);
				JSONArray jsonArr = json.getJSONArray("TestCaseList");
				if(jsonArr != null){
					runcaselist = new String[jsonArr.length()];
					String caseName = null;
					for(int i = 0; i < jsonArr.length(); i++){
						JSONObject param = (JSONObject) jsonArr.get(i);
						caseName = param.get("name").toString();
						runcaselist[i] = caseName;
					}
				}
			} catch (JSONException e) {
				//read string
				runcaselist = caselist.split(",");
			}
			
		}

		
		//get all case list as bellow format
		/*
		 <root>
			<case>
				<basic>
					<power>
						<lpm>
							<home>case/basic/power/lpm/home/home.ppat.xml</home>
						</lpm>
						<video>
							<720p>case/basic/power/video/720p/720p.eden.ppat.xml</720p>
							<vga>case/basic/power/video/vga/VGA.ppat.xml</vga>
						</video>
						<game>
							<angrybirds>case/basic/power/game/angrybirds/AngryBirds.ppat.xml</angrybirds>
						</game>
					</power>
				</basic>
			</case>
		 </root>
		 */
		if(runcaselist != null){
			for(int j = 0; j < runcaselist.length; j++){
				for(int i = 0; i < ListAllCases.caseList.size(); i++){
					String caseName = ListAllCases.caseList.get(i);
					if(caseName.equalsIgnoreCase(runcaselist[j].trim()) || (runcaselist[j].trim().equalsIgnoreCase(i + ""))){
						System.out.println("case: " + caseName + "  --|-- path: " + ListAllCases.casePathList.get(i));
						
						//delete precondition.platform.xml
						String casePath = ListAllCases.casePathList.get(i);
						
						if(casePath.contains("baremetal")){//not check bootup
							this.getProject().setProperty("bootUpChk", "false");
						}
						int index = casePath.lastIndexOf("/");
						String[] paths = casePath.split("/");
						
						String filePath = casePath.substring(0, index)  + "/precondition." + PPATProject.project.getProperty("platform") + ".xml";
						
						File file = new File(filePath);
						if(file.exists()){
							System.out.println("delete file: " + filePath);
							file.delete();
						}
						
						//add node to root
						Element parentNode = caseRoot;
						for(int k = 1; k < paths.length - 1; k++){
							String parentPath = paths[k - 1];
							String path = paths[k];
							parentNode = addParentNodetoRoot(parentNode, parentPath, path);
						}
						parentNode.setText(ListAllCases.casePathList.get(i));//add case full path to node as text
						
					}
				}
			}
		}
		
//		print(caseRoot);
//		try{
//			XMLWriter writer = new XMLWriter(new FileOutputStream("test.xml"));
//			writer.write(caseDoc);
//			writer.close();
//		}catch(Exception e){
//			
//		}
//		
//		Target t = (Target) this.getProject().getTargets().get("init");
//		Ant ant = new Ant();
//		ant.setAntfile("case/basic/power/video/720p/720p.eden.ppat.xml");
//		ant.setProject(getProject());
//		ant.setOutput("720p.log");
//		
//		t.addTask(ant);
		
	}
	
	private void print(Element root){
		List<Element> lists = root.elements();
		System.out.println("+++++++++++++++++++++++++++");
		System.out.print(root.getName() + " -> ");
		
		if(lists.size() == 0){
			System.out.println("*************************");
			return;
		}else{
			for(Element element : lists){
				System.out.println(element.getName());
				print(element);
			}
		}
	}
	
	private Element addParentNodetoRoot(Element parentNode, String parentNodeName, String targetNodeName){
		if(parentNode.getName().equalsIgnoreCase(parentNodeName)){//find parent node
			List<Element> elements = parentNode.elements();
			
			for(int i = 0; i < elements.size(); i++){
				Element ele = elements.get(i);
				if(ele.getName().equalsIgnoreCase(targetNodeName)){
					if(i == elements.size() - 1){
						return ele;
					}
				}
			}
			
			Element target = parentNode.addElement(targetNodeName);
			return target;
		}else{
			Element target = parentNode.addElement(parentNodeName);
			return target.addElement(targetNodeName);
		}
		
	}

}
