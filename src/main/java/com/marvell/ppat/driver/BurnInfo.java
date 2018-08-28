package com.marvell.ppat.driver;

import com.marvell.ppat.taskdef.HostCmd;

import org.apache.tools.ant.Project;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.ArrayList;

public class BurnInfo {

    private static final String BUILDLOG_MASTER = "LAST_BUILD.";
    private static final String BUILDLOG_RLS = "LAST_BUILD.rls_";
    public static String LOCAL_IMAGE_PATH = "";

    private String imagePath;
    private ArrayList<String> imageList = new ArrayList<String>();

    public void addImageFile(String file) {
        imageList.add(file);
    }

    public ArrayList<String> getImageList() {
        return this.imageList;
    }

    public void setImagePath(String path) {
        this.imagePath = path;
    }

    public String getImagePath() {
        return this.imagePath;
    }

    public BurnInfo(Project proj) {


        LOCAL_IMAGE_PATH = proj.getProperty("local_image_path");
        //generate image path
        if (proj.getProperty("burn_mode").equalsIgnoreCase("latest")) {
            String releaseVersion = proj.getProperty("release_version");
            String buildlog = "";
            if (releaseVersion.equalsIgnoreCase("master")) {
                buildlog = BUILDLOG_MASTER + proj.getProperty("last_build_infix") + "-" + proj.getProperty("os_version");
            } else {
                buildlog = BUILDLOG_RLS + proj.getProperty("last_build_infix") + "_" + proj.getProperty("os_version") + "_" + proj.getProperty("release_version");
            }
            //copy buildlog to local
            String buildlog_path = proj.getProperty("image_path_prefix") + "/" + buildlog;
            HostCmd cmd = new HostCmd();
            cmd.setProject(proj);

            File autoburn = new File(LOCAL_IMAGE_PATH);
            if (!autoburn.exists()) {
                autoburn.mkdir();
            }
            System.out.println("cp " + buildlog_path + " " + LOCAL_IMAGE_PATH);
            cmd.execute("cp " + buildlog_path + " " + LOCAL_IMAGE_PATH);

            //parse buildlog
            InputStreamReader in = null;
            LineNumberReader input = null;
            try {
                in = new InputStreamReader(new FileInputStream(LOCAL_IMAGE_PATH + buildlog));
                input = new LineNumberReader(in);
                String line = null;
                while ((line = input.readLine()) != null) {
                    if (line.contains("Package")) {
                        String imagepath = line.split(":")[1];
                        setImagePath(imagepath);
                    }
                }

            } catch (Exception e) {

            } finally {
                if (input != null) {
                    try {
                        input.close();
                    } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
                if (in != null) {
                    try {
                        in.close();
                    } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }

                /* delete the file */
                File f = new File(LOCAL_IMAGE_PATH + buildlog);
                if (f.exists()) {
                    f.delete();
                }
            }
        } else {
            String img_path = proj.getProperty("image_path").replace("10.38.116.40", "");
            setImagePath(img_path);
        }
    }


}
