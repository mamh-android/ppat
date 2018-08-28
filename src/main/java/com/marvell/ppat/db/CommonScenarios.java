package com.marvell.ppat.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;

public class CommonScenarios {

    public static HashMap<String, Integer> getScenarios(String table) throws ClassNotFoundException {
        HashMap<String, Integer> result = new HashMap<String, Integer>();

        String url = "jdbc:mysql://10.38.116.40:3306/power";
        String user = "root";
        String password = "marvell";
        try {
            Connection conn = DriverManager.getConnection(url, user, password);
            if (!conn.isClosed()) {

                Statement state = conn.createStatement();

                String sql = "select id,name from " + table;

                ResultSet rs = state.executeQuery(sql);
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String title = rs.getString("name");
                    result.put(title, id);

                }

            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

}
