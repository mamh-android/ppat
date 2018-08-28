package com.marvell.ppat.taskdef;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.MacroDef;
import org.apache.tools.ant.taskdefs.MacroInstance;

public class For extends Task {

    private int intStart;
    private int intEnd;
    private int step;
    private String param;
    private MacroDef macroDef;

    public Object createSequential() {
        macroDef = new MacroDef();
        macroDef.setProject(this.getProject());
        return macroDef.createSequential();
    }

    public void setIntStart(String start) {
        intStart = Integer.parseInt(start);
    }

    public void setIntEnd(String end) {
        intEnd = Integer.parseInt(end);
    }

    public void setStep(String step) {
        this.step = Integer.parseInt(step);
    }

    public void setParam(String paramName) {
        param = paramName;
    }

    @Override
    public void execute() throws BuildException {
        //set attr as param
        MacroDef.Attribute attr = new MacroDef.Attribute();
        attr.setName(param);
        macroDef.addConfiguredAttribute(attr);

        //execute for loop
        for (int i = intStart; i <= intEnd; i += step) {
            MacroInstance instance = new MacroInstance();
            instance.setProject(getProject());
            instance.setOwningTarget(getOwningTarget());
            instance.setMacroDef(macroDef);
            instance.setDynamicAttribute(param, i + "");
            instance.execute();
        }
    }
}
