package com.marvell.ppat.taskdef.power;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Iterator;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.tools.ant.BuildException;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import com.marvell.ppat.driver.PPATProject;

public class PowerReportFile {
	
	private File htmlFile;
	private Document reportDoc;
	private ArrayList<String> OUT_COLUMNS = new ArrayList<String>();
	
	private PowerReportFile(){
		StringBuilder strBuilder = new StringBuilder();
		strBuilder.append("Power_Result");
		strBuilder.append(".html");

		htmlFile = new File(PPATProject.project.getProperty("result_root") + strBuilder.toString());	
		
		reportDoc = DocumentHelper.createDocument();
		reportDoc.addElement("TestReport");
		
		String imagePath = PPATProject.project.getProperty("image_path");
		
		String log = PPATProject.project.getProperty("log_path") + "result/" + PPATProject.project.getProperty("run_time");
		String envList = 
				"<TestEnvList>" 
					+ "<TestEnv key=\"Platform\">"
					+ PPATProject.project.getProperty("platform") + "</TestEnv>"
					+ "<TestEnv key=\"Os\">"
					+ PPATProject.project.getProperty("os") + "," + PPATProject.project.getProperty("os_version") + PPATProject.project.getProperty("release_version") + "</TestEnv>"
					+ "<TestEnv key=\"Device Info\">"
					+ PPATProject.project.getProperty("device_info") + "</TestEnv>" 
					+ "<TestEnv key=\"Task Purpose\">"
					+ PPATProject.project.getProperty("purpose").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\"", "&quot;").replaceAll("'", "&apos;") + "</TestEnv>"
					+ "<TestEnv key=\"Image Path\">"
					+ imagePath + "</TestEnv>"
					+ "<TestEnv key=\"Log\">" 
					+ log + "</TestEnv>" 				
				+ "</TestEnvList>";

		try {
			reportDoc.getRootElement().add(
					DocumentHelper.parseText(envList).getRootElement());
			reportDoc.getRootElement().addElement("TestResultList");
		} catch (DocumentException e) {
			e.printStackTrace();
			throw new BuildException("Document Exception in HTMLSingleton");
		}
	}

	
	private static final PowerReportFile INSTANCE = new PowerReportFile();
	
	
	public static PowerReportFile getInstance(){
		return INSTANCE;
	}
	

	/**
	 * Write string to reportdoc, for commonresult task use
	 * 
	 * @param resultStr
	 *            : String
	 * @throws DocumentException
	 */
	public void writeToReportDoc(String resultStr) throws DocumentException {
		Document caseDoc = DocumentHelper.parseText(resultStr);
		((Element) reportDoc.selectSingleNode("/TestReport/TestResultList"))
				.add(caseDoc.getRootElement());

		updateXsl("config/powerResult.xsl.template", "config/powerResult.xsl", resultStr);
	}

	/**
	 * Refresh result file, for runcase use
	 * 
	 * @throws Exception
	 */
	public void updateResultHtml() throws Exception {
		updateResultHtml(reportDoc, "config/powerResult.xsl");
	}

	public void updateXsl(String fileIn, String fileOut, String result){
		try{
			BufferedReader in = new BufferedReader(new FileReader(fileIn));
			BufferedWriter out = new BufferedWriter(new FileWriter(fileOut));
			String s = null;
			while((s = in.readLine()) != null){
				out.write(s);
				out.newLine();
			}
			//
			Document caseDoc = DocumentHelper.parseText(result);
			Element testResult = (Element)caseDoc.selectSingleNode("TestResult");
			String th = "<tr bgcolor=\"#6dc22c\">";
			String tr = "<xsl:for-each select=\"TestResultList/TestResult\"><tr bgcolor=\"#FFFFFF\">";
			for(Iterator<Element> iter = testResult.elementIterator(); iter.hasNext();){
				Element ele = iter.next();
				if(!OUT_COLUMNS.contains(ele.getName())){
					OUT_COLUMNS.add(ele.getName());
				}
				
			}
			
			for(String col : OUT_COLUMNS){
				th += "<th bgcolor=\"#6dc22c\">" + col + "</th>";
				tr += "<td bgcolor=\"#FFFFFF\"><xsl:value-of select=\"" + col + "\" /></td>";
			}
			th += "</tr>";
			tr += "</tr></xsl:for-each></table></body></html></xsl:template></xsl:stylesheet>";
			out.write(th);
			out.write(tr);
			out.flush();
			in.close();
			out.close();
			}catch(IOException e){
				e.printStackTrace();
			} catch (DocumentException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}
	public void updateResultHtml(Document doc, String xslPath) throws Exception {
		Reader content = new StringReader(doc.asXML());
		OutputStream out = null;
		StreamSource streamSrc = new StreamSource(xslPath);
		TransformerFactory tFactory = TransformerFactory.newInstance();

		Transformer trans = tFactory.newTransformer(streamSrc);
		out = new FileOutputStream(htmlFile);
		trans.transform(new StreamSource(content), new StreamResult(out));
//		 out.close();//TODO if it is necessary
	}

	public void updateResultXml() throws Exception {
		updateResultXml(reportDoc, PPATProject.project.getProperty("result_root")+"powerResult.xml");
	}

	public void updateResultXml(Document doc, String xmlFileName)
			throws Exception {
		OutputStream os = new FileOutputStream(new File(xmlFileName));
		OutputStreamWriter osw = new OutputStreamWriter(os);
		osw.write(doc.getRootElement().asXML().toString());
		osw.close();
		os.close();
	}
	
	public File getHTML(){
		return htmlFile;
	}

}
