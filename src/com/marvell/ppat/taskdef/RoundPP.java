package com.marvell.ppat.taskdef;

import java.io.FileOutputStream;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.XMLWriter;

import com.marvell.ppat.driver.PrintColor;

public class RoundPP extends Task {
	
	/* store a static tree of round PP params*/
	public static Document resultDoc = DocumentHelper.createDocument();
	public static Element root = resultDoc.addElement("root");
	
	private Vector cpus = new Vector();
	private Vector ddrs = new Vector();
	private Vector vpus = new Vector();
	private Vector gpus = new Vector();
	
	public Cpu createCpu(){
		Cpu cpu = new Cpu();
		cpus.add(cpu);
		return cpu;
	}
	
	public Gpu createGpu(){
		Gpu gpu = new Gpu();
		gpus.add(gpu);
		return gpu;
	}
	
	public Ddr createDdr(){
		Ddr ddr = new Ddr();
		ddrs.add(ddr);
		return ddr;
	}
	
	public Vpu createVpu(){
		Vpu vpu = new Vpu();
		vpus.add(vpu);
		return vpu;
	}
	
	
	/**
	 * <cpu>
	 * 		<CoreNum>1,2</CoreNum>
	 * 		<Frequency>312000,624000</Frequency>
	 * </cpu>
	 *
	 */
/*	public class Cpu{
		public Cpu(){}
		private Vector coreNums = new Vector();
		private Vector freqs = new Vector();
		
		
		public String getName(){
			return "cpu";
		}
		public Frequency createFrequency(){
			Frequency freq = new Frequency();
			freqs.add(freq);
			return freq;
		}
		
		public CoreNum createCoreNum(){
			CoreNum coreNum = new CoreNum();
			coreNums.add(coreNum);
			return coreNum;
		}
	}*/

	/**
	 * CPU GPU and VPU has the same structure
	 * 
	 * <gpu>
	 * 		<unit id="0">
	 * 			<Frequency>312000,416000</Frequency>
	 * 		</unit>
	 * 		<unit id="1">
	 * 			<Frequency>156000</Frequency>
	 * 		</unit>
	 * </gpu>
	 *
	 */
	
	public class Gpu{
		public Gpu(){}
		private Vector units = new Vector();
		
		public Unit createUnit(){
			Unit unit = new Unit();
			units.add(unit);
			return unit;
		}
		
		public String getName(){
			return "gpu";
		}
	}
	
	public class Cpu{
		public Cpu(){}
		private Vector units = new Vector();
		
		public Unit createUnit(){
			Unit unit = new Unit();
			units.add(unit);
			return unit;
		}
		
		public String getName(){
			return "cpu";
		}
	}
	
	public class Vpu{
		public Vpu(){}
		private Vector units = new Vector();
		
		public Unit createUnit(){
			Unit unit = new Unit();
			units.add(unit);
			return unit;
		}
		
		public String getName(){
			return "vpu";
		}
	}
	
	/**
	 * <ddr>
	 * 		<Frequency>156000</Frequency>
	 * </ddr>
	 *
	 */
	
	public class Ddr{
		public Ddr(){}
		private Vector freqs = new Vector();
		
		public Frequency createFrequency(){
			Frequency freq = new Frequency();
			freqs.add(freq);
			return freq;
		}
		
		public String getName(){
			return "ddr";
		}
	}
	
	public class CoreNum{
		public CoreNum(){}
		String coreNum;
		public void addText(String coreNum){
			this.coreNum = coreNum;
		}
		public String getCoreNum(){
			return this.coreNum;
		}
	}
	
	public class Frequency{
		public Frequency(){}
		String freq;
		public void addText(String freq){
			this.freq = freq;
		}
		public String getFrequency(){
			return this.freq;
		}
		
	}
	
	public class Unit{
		public Unit(){}
		String id;
		private Vector freqs = new Vector();
		private Vector coreNums = new Vector();
		public void setId(String id){
			this.id = id;
		}
		public String getId(){
			return this.id;
		}
		public Frequency createFrequency(){
			Frequency freq = new Frequency();
			freqs.add(freq);
			return freq;
		}
		
		public CoreNum createCoreNum(){
			CoreNum coreNum = new CoreNum();
			coreNums.add(coreNum);
			return coreNum;
		}
	}
	
	@Override
	public void execute() throws BuildException {
		PrintColor.printRed(this, "start round PP");
		// TODO Auto-generated method stub
		// handle nested elements
        for (Iterator it = vpus.iterator(); it.hasNext(); ) {
        	Vpu vpu = (Vpu)it.next();
            for (Iterator iter = vpu.units.iterator(); iter.hasNext(); ) {
            	Unit unit = (Unit)iter.next();
                for (Iterator iterfreq = unit.freqs.iterator(); iterfreq.hasNext(); ) {
                	Frequency freq = (Frequency)iterfreq.next();
                    addElementWithAttributes(vpu.getName(), root, "unit", unit.getId(), "Frequency", freq.getFrequency());
                }
            }
        }
        for (Iterator it = gpus.iterator(); it.hasNext(); ) {
        	Gpu gpu = (Gpu)it.next();
            for (Iterator iter = gpu.units.iterator(); iter.hasNext(); ) {
            	Unit unit = (Unit)iter.next();
                for (Iterator iterfreq = unit.freqs.iterator(); iterfreq.hasNext(); ) {
                	Frequency freq = (Frequency)iterfreq.next();
                    addElementWithAttributes(gpu.getName(), root, "unit", unit.getId(), "Frequency", freq.getFrequency());
                }
            }
        }
        for (Iterator it = cpus.iterator(); it.hasNext();){
        	Cpu cpu = (Cpu)it.next();
        	for (Iterator iter = cpu.units.iterator(); iter.hasNext(); ) {
        		Unit unit = (Unit)iter.next();
        		for(Iterator iter_cn = unit.coreNums.iterator(); iter_cn.hasNext();){
            		CoreNum coreNum = (CoreNum) iter_cn.next();
            		addElementWithAttributes(cpu.getName(), root, "unit", unit.getId(), "CoreNum", coreNum.getCoreNum());
            	}
            	for(Iterator iter_freq = unit.freqs.iterator(); iter_freq.hasNext();){
            		Frequency freq = (Frequency)iter_freq.next();
            		addElementWithAttributes(cpu.getName(), root, "unit", unit.getId(), "Frequency", freq.getFrequency());
            	}
        	}
        	
        }

        for (Iterator it = ddrs.iterator(); it.hasNext(); ) {
        	Ddr ddr = (Ddr)it.next();
        	for (Iterator iterfreq = ddr.freqs.iterator(); iterfreq.hasNext(); ) {
            	Frequency freq = (Frequency)iterfreq.next();
            	addElementWithSingleAttribute(ddr.getName(), root, "Frequency", freq.getFrequency());
            }
        }
		PrintColor.printRed(this, "finish round PP");
	}
	
	private void addElementWithSingleAttribute(String ele, Element root, String attr, String attrVal){
		List<Element> lists = root.elements();
		if(lists.size() == 0){
			String[] attrVals = attrVal.split(",");
			for(String val : attrVals){
				Element element = root.addElement(ele);
				element.addAttribute(attr, val);
			}
			
			return;
		}
		for(Element element : lists){
			addElementWithSingleAttribute(ele, element, attr, attrVal);
		}
		
	}
	
	private void addElementWithAttributes(String ele, Element root, String attrName1, String attrVal1, String attrName2, String attrVal2){
		List<Element> lists = root.elements();
		if(lists.size() == 0){
			String[] attrVals = attrVal2.split(",");
			for(String val : attrVals){
				Element element = root.addElement(ele);
				element.addAttribute(attrName1, attrVal1);
				element.addAttribute(attrName2, val);
			}
			
			return;
		}
		for(Element element : lists){
			addElementWithAttributes(ele, element, attrName1, attrVal1,attrName2, attrVal2);
		}
		
	}
}
