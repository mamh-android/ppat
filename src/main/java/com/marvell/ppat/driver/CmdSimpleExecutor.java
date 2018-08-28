package com.marvell.ppat.driver;

import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.Map;

public class CmdSimpleExecutor {

    // private String printTpye = null;
    private boolean redirectErrorStream = false;
    private String workingDirectory = null;
    private Map<String, String> environment = null;

    public CmdSimpleExecutor() {
        // this.printTpye = "stdout";
        this.workingDirectory = null;
        this.environment = null;
    }

    public CmdSimpleExecutor(String type) {
        // this.printTpye = type;
        this.workingDirectory = null;
        this.environment = null;
    }

    public CmdSimpleExecutor(boolean redirectErrorStream,
                             String workingDirectoryP) {
        this.redirectErrorStream = redirectErrorStream;
        this.workingDirectory = workingDirectoryP;
    }

    public CmdSimpleExecutor(boolean redirectErrorStream,
                             String workingDirectoryP, Map<String, String> environmentP) {
        this.redirectErrorStream = redirectErrorStream;
        this.workingDirectory = workingDirectoryP;
        this.environment = environmentP;
    }

    /**
     * Execute cmd by Process builder
     *
     * @param cmd
     * @return
     */
    public CmdExecutionResult exeCmd(String cmd) {
        ArrayList<String> cmdList = new ArrayList<String>();
        String[] ary = cmd.split("\\s{1,}"); // match extra space
        for (int i = 0; i < ary.length; i++) {
            //System.out.println(ary[i]);
            cmdList.add(ary[i].replaceAll("&nbsp;", " "));
        }
        return exeCmd(cmdList);
    }

    public CmdExecutionResult exeCmd(ArrayList<String> cmdList) {
        Process process = null;
        StreamCollecter t1 = null;
        StreamCollecter t2 = null;
        ProcessBuilder pb = null;
        CmdExecutionResult result = new CmdExecutionResult();
        try {
            pb = new ProcessBuilder(cmdList);

            /* set proess env */
            pb.redirectErrorStream(redirectErrorStream);

            if (workingDirectory != null) {
                pb.directory(new File(workingDirectory));
            }
            if (environment != null && environment.size() > 0) {
                pb.environment().putAll(environment);
            }

            /* start the process to execute cmd */
            process = pb.start();

            t1 = new StreamCollecter(process.getInputStream());
            t1.start();

            if (!pb.redirectErrorStream()) { // if redirectErrorStream, skip
                // this step
                t2 = new StreamCollecter(process.getErrorStream());
                t2.start();
            }

            result.exitValue = process.waitFor();

            t1.join();
            if (!pb.redirectErrorStream()) { // if redirectErrorStream, skip
                // this step
                t2.join();
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            /* get result when exception */
            result.stdout = t1.getResult();
            if (!pb.redirectErrorStream()) {
                result.stderr = t2.getResult();
            }
            if (process != null) {
                process.destroy(); // avoid open too many file
            }
        }
        return result;
    }

    /**
     * collect result stream, include stderr & stdout
     */
    private class StreamCollecter extends Thread {
        LineNumberReader input;
        ArrayList<String> resutlList;

        public StreamCollecter(InputStream stream) {
            InputStreamReader ir = new InputStreamReader(stream);
            input = new LineNumberReader(ir);
        }

        public ArrayList<String> getResult() {
            return resutlList;
        }

        @Override
        public void run() {
            resutlList = new ArrayList<String>();
            try {
                String line = null;
                while ((line = input.readLine()) != null) {
                    resutlList.add(line);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }
}
