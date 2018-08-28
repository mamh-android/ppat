package com.marvell.ppat.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DatabaseUtils {

    public static String URL = "jdbc:mysql://10.38.116.40:3306/ppat";
    public static String url_bak = "jdbc:mysql://10.38.116.40:3306/power";
    public static String USER = "root";
    public static String PASSWORD = "marvell";
    public static String DRIVER = "com.mysql.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static String insertOrGetTask(int user_id, String platform, String device, String branch, String precondition, String comments, String purpose, String run_type, String image_date) {
        String task_id = null;
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {

                Statement state = conn.createStatement();

                Date date = new Date(System.currentTimeMillis());
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String sql = "select task_id from task_infos where platform='" + platform + "' and device='" + device
                        + "' and branch='" + branch + "' and purpose='" + purpose + "' and run_type='" + run_type + "' and image_date='" + image_date + "'";
                try {
                    ResultSet rs = state.executeQuery(sql);
                    while (rs.next()) {
                        String id = rs.getString("task_id");
                        task_id = id;
                    }
                } catch (Exception e) {//not found result
                    e.printStackTrace();
                }

                //count task
                sql = "select count(id) from task_infos where task_id like '" + image_date + "%'";
                int count = 0;
                try {
                    ResultSet rs = state.executeQuery(sql);
                    while (rs.next()) {
                        count += rs.getInt(1);
                    }
                } catch (Exception e) {//not found result
                    e.printStackTrace();
                }
                if (task_id == null) {//need insert
                    task_id = image_date + "_" + count;
                    PreparedStatement pre = conn
                            .prepareStatement("insert into task_infos (user_id, platform, device, branch, precondition, created_at, finished_at, comments, purpose, run_type, task_id, image_date)" +
                                    " values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)", Statement.RETURN_GENERATED_KEYS);
                    pre.setInt(1, user_id);
                    pre.setString(2, platform);
                    pre.setString(3, device);
                    pre.setString(4, branch);
                    pre.setString(5, precondition);
                    pre.setString(6, sdf.format(date));
                    pre.setString(7, sdf.format(date));
                    pre.setString(8, comments);
                    pre.setString(9, purpose);
                    pre.setString(10, run_type);
                    pre.setString(11, task_id);
                    pre.setString(12, image_date);
                    try {
                        pre.executeUpdate();
                    } catch (SQLException sqle) {
                        ResultSet rs = state.executeQuery(sql);
                        while (rs.next()) {
                            count += rs.getInt(1);
                        }
                        task_id = image_date + "_" + count;
                        pre.setString(11, task_id);
                        pre.executeUpdate();
                    }
                    ResultSet rs = pre.getGeneratedKeys();
                    rs.next();
                } else {//update finished time
                    PreparedStatement pre = conn
                            .prepareStatement("update task_infos set finished_at='" + sdf.format(date) + "' where task_id='" + task_id + "'");
                    pre.executeUpdate();
                }
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return task_id;
    }

    public static void insertComponentsInfo(String name, String value, int power_record_id) {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {
                PreparedStatement pre = conn
                        .prepareStatement("insert into component_infos " +
                                "(name, value, power_record_id) values(?, ?, ?)");
                pre.setString(1, name);
                pre.setString(2, value);
                pre.setInt(3, power_record_id);
                pre.executeUpdate();
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static int insetPowerRecord(String scenario, String platform,
                                       String device, String branch, int submitter, String image_date,
                                       String run_type, String comments, String battery, String vcc_main, String vcc_main_power,
                                       String duty_cycle, String fps, String pt4_link, String task_id, String purpose) {

        int power_record_id = 0;
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            PreparedStatement pre = conn.prepareStatement("insert into power_records"
                    + " (power_scenario_id,platform,device,branch,submitter,image_date,verified,valid,run_type,comments,battery,vcc_main,vcc_main_power,duty_cycle,fps,pt4_link,task_id,purpose)" +
                    "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
            int scenario_id = insertOrGetScenario("power_scenarios", scenario);
            pre.setInt(1, scenario_id);
            pre.setString(2, platform);
            pre.setString(3, device);
            pre.setString(4, branch);
            pre.setInt(5, submitter);

            pre.setString(6, image_date);
            pre.setString(9, run_type);
            pre.setString(10, comments);
            pre.setString(11, battery);

            pre.setString(12, vcc_main);
            pre.setString(13, vcc_main_power);
            pre.setString(14, duty_cycle);
            pre.setString(15, fps);
            pre.setString(16, pt4_link);
            pre.setString(17, task_id);
            pre.setString(18, purpose);

            Statement state = conn.createStatement();

            String sql = "select battery from power_records where power_scenario_id="
                    + scenario_id + " AND platform='" + platform + "' AND device='" + device
                    + "' AND device='" + device + "' AND image_date<'" + image_date + "' "
                    + "AND valid='Y'" + " order by image_date desc LIMIT 10";

            ResultSet rs = state.executeQuery(sql);
            int totCount = 0;
            float sumOfOld = 0.0f;
            String oldData = "0";
            while (rs.next()) {
                oldData = rs.getString("battery");
                totCount++;
                sumOfOld += Float.parseFloat(oldData);
            }
            float old = sumOfOld / totCount;
            try {
                sql = "select error_rate from power_scenarios where name='" + scenario + "'";

                rs = state.executeQuery(sql);
                String delta = null;

                while (rs.next()) {
                    delta = rs.getString(1);
                }

                if (delta == null) {
                    delta = "5%";//set default delta is 5%
                }
                System.out.println("delta is " + delta + " old average is : " + old + " today's power is: " + battery);
                float avg = sumOfOld / totCount;
                if (delta.contains("%")) {
                    String dt = delta.substring(0, delta.length() - 1);
                    if (Math.abs(Float.parseFloat(battery) - old) / old * 100.0F <= Float
                            .parseFloat(dt)) {
                        pre.setString(7, "P");
                        pre.setString(8, "Y");
                    } else {
                        pre.setString(7, "F");
                        pre.setString(8, "N");
                    }
                } else {
                    float abs = Float.parseFloat(delta);
                    if (Math.abs(Float.parseFloat(battery) - avg) <= abs) {
                        pre.setString(7, "P");
                        pre.setString(8, "Y");
                    } else {
                        pre.setString(7, "F");
                        pre.setString(8, "N");
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                pre.setString(7, "TBD");
                pre.setString(8, "N");
            }


            pre.executeUpdate();
            ResultSet instRs = pre.getGeneratedKeys();
            instRs.next();
            power_record_id = instRs.getInt(1);
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return power_record_id;
    }

    public static int insertThermalRecord(String platform, String branch, String device, float max_temp, String image_date, String battery, String vcc_main, String vcc_main_power, String log_link, int thermal_scenario_id, String comments) {
        int thermal_record_id = 0;
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {
                PreparedStatement pre = conn
                        .prepareStatement("insert into thermal_records " +
                                "(platform, branch, device, max_temp, image_date, battery, vcc_main, vcc_main_power, log_link, thermal_scenario_id,comments)" +
                                "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)", Statement.RETURN_GENERATED_KEYS);
                pre.setString(1, platform);
                pre.setString(2, branch);
                pre.setString(3, device);
                pre.setString(4, Float.toString(max_temp));
                pre.setString(5, image_date);
                pre.setString(6, battery);
                pre.setString(7, vcc_main);
                pre.setString(8, vcc_main_power);
                pre.setString(9, log_link);
                pre.setInt(10, thermal_scenario_id);
                pre.setString(11, comments);
                pre.executeUpdate();
                ResultSet rs = pre.getGeneratedKeys();
                rs.next();
                thermal_record_id = rs.getInt(1);
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return thermal_record_id;
    }

    public static void insertThermalTempInfo(int thermal_record_id, String y_axis_val, String y_axis_name) {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {
                PreparedStatement pre = conn
                        .prepareStatement("insert into temp_infos " +
                                "(y_axis_val, y_axis_name, thermal_record_id)" +
                                "values(?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
                pre.setString(1, y_axis_val);
                pre.setString(2, y_axis_name);
                pre.setInt(3, thermal_record_id);
                pre.executeUpdate();
                ResultSet rs = pre.getGeneratedKeys();
                rs.next();
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void insertThermalFreqInfo(int thermal_record_id, String y_axis_val, String y_axis_name, int y_axis_idx) {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {
                PreparedStatement pre = conn
                        .prepareStatement("insert into thermal_freq_infos " +
                                "(y_axis_val, y_axis_name, thermal_record_id, y_axis_idx)" +
                                "values(?, ?, ?,?)", Statement.RETURN_GENERATED_KEYS);
                pre.setString(1, y_axis_val);
                pre.setString(2, y_axis_name);
                pre.setInt(3, thermal_record_id);
                pre.setInt(4, y_axis_idx);
                pre.executeUpdate();
                ResultSet rs = pre.getGeneratedKeys();
                rs.next();
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static int insertOrGetScenario(String table, String scenario) {
        int key = 0;
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {

                Statement state = conn.createStatement();

                String sql = "select id from " + table + " where name='" + scenario + "'";
                try {
                    ResultSet rs = state.executeQuery(sql);
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        key = id;
                    }
                } catch (Exception e) {//not found result
                    e.printStackTrace();
                }
                if (key == 0) {//need insert
                    PreparedStatement pre = conn
                            .prepareStatement("insert into " + table + " (name) values('" + scenario + "')", Statement.RETURN_GENERATED_KEYS);
                    pre.executeUpdate();
                    ResultSet rs = pre.getGeneratedKeys();
                    rs.next();
                    key = rs.getInt(1);
                }
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return key;
    }

    public static int insertOrGetUser(String emailAddr) {
        int key = 0;
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (!conn.isClosed()) {

                Statement state = conn.createStatement();

                String sql = "select id from users where email_addr='" + emailAddr + "'";
                try {
                    ResultSet rs = state.executeQuery(sql);
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        key = id;
                    }
                } catch (Exception e) {//not found result
                    e.printStackTrace();
                }
                if (key == 0) {//need insert
                    PreparedStatement pre = conn
                            .prepareStatement("insert into users (email_addr) values('" + emailAddr + "')", Statement.RETURN_GENERATED_KEYS);
                    pre.executeUpdate();
                    ResultSet rs = pre.getGeneratedKeys();
                    rs.next();
                    key = rs.getInt(1);
                }
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return key;
    }

}
