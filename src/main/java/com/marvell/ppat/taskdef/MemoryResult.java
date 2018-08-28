package com.marvell.ppat.taskdef;

import com.marvell.ppat.db.CommonConsumptions;
import com.marvell.ppat.db.CommonScenarios;
import com.marvell.ppat.driver.PPATProject;
import com.marvell.ppat.driver.PrintColor;

import org.apache.tools.ant.BuildException;

import java.util.ArrayList;
import java.util.HashMap;

public class MemoryResult extends CommonResult {

    private String cmd;

    private static final String MEMORY_TABLE = "memories";
    private static final String MEMORY_SCENARIO_TABLE = "memoryscenarios";

    public void setCmd(String cmd) {
        this.cmd = cmd;
    }

    @Override
    public void generateResult() throws Exception {
        // TODO Auto-generated method stub
        HostCmd cmd = new HostCmd();
        cmd.setProject(getProject());
        cmd.setWorkingDirectory(getProject().getBaseDir().toString());
        cmd.execute(this.cmd);

        parseMemoryResult(cmd.getExeResult().stdout);
    }

    private void parseMemoryResult(ArrayList<String> stdout)
            throws ClassNotFoundException {
        String soc = this.getProject().getProperty("soc");
        String board = this.getProject().getProperty("board");
        String os = this.getProject().getProperty("os_version");
        String rls_version = this.getProject().getProperty("release_version");
        String img_date = this.getProject().getProperty("image_date");
        if (this.getProject().getProperty("SyncToDB").equalsIgnoreCase("true")) {
            HashMap<String, Integer> name_to_id = CommonScenarios
                    .getScenarios(MEMORY_SCENARIO_TABLE);

            String link = PPATProject.project.getProperty(
                    "log_path")
                    + "result/"
                    + PPATProject.project.getProperty("run_time")
                    + "/"
                    + caseName
                    + "/"
                    + PPATProject.project.getProperty("case_subdir");
            String ddr_size = "";
            for (String s : stdout) {
                String mem_data_item = s.split(":")[0].trim();
                if (mem_data_item.equalsIgnoreCase("ddr_size")) {
                    ddr_size = s.split(":")[1].split("\\s+")[0].trim();
                    break;
                }
            }

            for (String s : stdout) {
                try {
                    String mem_data_item = s.split(":")[0].trim();
                    String mem_data_size = s.split(":")[1].split("\\s+")[0].trim();
                    String mem_data_unit = s.split(":")[1].split("\\s+")[1].trim();

                    //find mem_data id
                    int scenario_id = name_to_id.get(mem_data_item);

                    // insert data to database
                    CommonConsumptions.insert_to_memory(MEMORY_TABLE,
                            MEMORY_SCENARIO_TABLE, scenario_id, img_date,
                            mem_data_size, mem_data_unit, "", "", soc, board, os + "_"
                                    + rls_version, link, ddr_size);

                } catch (Exception e) {
                    PrintColor.printYellow("can't split" + s);
                }

            }// end for()
        } else {
            PrintColor.printRed("No need insert to database!");
        }
    }

    @Override
    public void generateReport() throws BuildException {
        // TODO Auto-generated method stub

    }

}
