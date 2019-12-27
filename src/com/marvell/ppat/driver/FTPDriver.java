package com.marvell.ppat.driver;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.net.ftp.FTPClient;

public class FTPDriver {
	private static String SERVER_ADDR = "10.38.32.98";
	private static String USER = "anonymous";
	private static String PASSWORD = "";
	private static FTPClient ftpClient = new FTPClient();
	
	public static void download(String folder, String fileName, String destFolder){
        try { 
            ftpClient.connect(SERVER_ADDR); 
            ftpClient.login(USER, PASSWORD); 
            ftpClient.enterLocalPassiveMode();

            String remoteFileName = "upload/" + folder + "/" + fileName;
//            ftpClient.setBufferSize(1024); 
            ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE); 
            OutputStream fos = new BufferedOutputStream(new FileOutputStream(new File(destFolder + "/" + fileName)));
            boolean success = ftpClient.retrieveFile(remoteFileName, fos); 
            System.out.println("ftp download file " + success);
            fos.close();
        } catch (IOException e) { 
            e.printStackTrace(); 
            throw new RuntimeException("FTP client ERROR", e); 
        } finally { 
            try { 
                ftpClient.disconnect(); 
            } catch (IOException e) { 
                e.printStackTrace(); 
                throw new RuntimeException("Close FTP connection ERROR", e); 
            } 
        } 
	}
}
