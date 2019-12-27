package com.marvell.ppat.db;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class PowerDataAnalysis {

	/**
	 * DELTA storage the power wave for different scenarios
	 * here the value is the percentage, specific value comes from actual measurement
	 */
	public static HashMap<String, String> POWER_DELTA = new HashMap<String, String>();
	public static HashMap<String, Float> PERFORMANCE_BASE = new HashMap<String, Float>();
	
	static{
		SAXReader reader_conf = new SAXReader();
		Document powerParaDoc = null;
		try {
			powerParaDoc = reader_conf.read(new File("config/ErrorRateConfig.xml"));
			
			List<?> caseList = powerParaDoc.selectNodes("/ErrorRate/TestCase");
			
			for (Object cl : caseList) {
				try{
					Element TestCaseNode = (Element) cl;
					String caseName = TestCaseNode.attributeValue("name");
					for(Iterator<Element> iter = TestCaseNode.elementIterator(); iter.hasNext();){
						Element pp = iter.next();
						String type = pp.getName();
						if(type.equalsIgnoreCase("Power")){
							POWER_DELTA.put(caseName, pp.getStringValue());
						}else{
							PERFORMANCE_BASE.put(caseName, Float.parseFloat(pp.getStringValue()));
						}
					}
				}catch(Exception e){
					e.printStackTrace();
				}
			}
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}
}
