package com.marvell.ppat.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;

public class CommonConsumptions {
	private static int get_max_id(String tableName) {
		int result = 0;
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			Connection conn = DriverManager.getConnection(url, user, password);
			if (!conn.isClosed()) {
				Statement state = conn.createStatement();

				String sql = "select max(id) from " + tableName;

				ResultSet rs = state.executeQuery(sql);
				while (rs.next()) {
					result = rs.getInt("max(id)");
				}
			}
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return result;
	}

	public static int insert_to_consumptions(String table,
			String scenarioTable, String scenario, String image_date,
			String power, String vcc, String duty_cycle_fps, String comments,
			String fps, String vccPower) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn.prepareStatement("insert into "
					+ table + " values(?,?,?,?,?,?,?,?,?,?,?,?,?)");
			pre.setInt(1, get_max_id(table) + 1);
			int scenario_id = ((Integer) CommonScenarios.getScenarios(
					scenarioTable).get(scenario)).intValue();
			pre.setInt(2, scenario_id);
			pre.setString(3, image_date);
			pre.setString(4, power);
			pre.setString(5, vcc);
			pre.setString(6, duty_cycle_fps);
			pre.setString(7, comments);
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(8, sdf.format(date));
			pre.setString(9, sdf.format(date));
			pre.setString(10, fps);
			pre.setString(12, "");
			pre.setString(13, vccPower);

			Statement state = conn.createStatement();

			String sql = "select power from " + table + " where scenario_id="
					+ scenario_id + " AND image_date<'" + image_date
					+ "' order by image_date desc LIMIT 1";

			ResultSet rs = state.executeQuery(sql);
			int totCount = 0;
			float sumOfOld = 0.0f;
			String oldData = "0";
			while (rs.next()) {
				oldData = rs.getString("power");
				totCount++;
				sumOfOld += Float.parseFloat(oldData);
			}
			float old = sumOfOld / totCount;
			try {
				String delta = PowerDataAnalysis.POWER_DELTA.get(scenario);
				float avg = sumOfOld / totCount;
				if (delta.contains("%")) {
					String dt = delta.substring(0, delta.length() - 1);
					if (Math.abs(Float.parseFloat(power) - old) / old * 100.0F <= Float
							.parseFloat(dt)) {
						pre.setString(11, "P");
					} else {
						pre.setString(11, "F");
					}
				} else {
					float abs = Float.parseFloat(delta);
					if (Math.abs(Float.parseFloat(power) - avg) <= abs) {
						pre.setString(11, "P");
					} else {
						pre.setString(11, "F");
					}
				}

			} catch (Exception e) {
				pre.setString(11, "TBD");
			}
			try {
				float act_fps = Float.parseFloat(fps);
				;
				if (act_fps < PowerDataAnalysis.PERFORMANCE_BASE.get(scenario)) {
					pre.setString(11, "F");
				}
			} catch (Exception e) {

			}

			pre.executeUpdate();

			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return 0;
	}

	public static int insertData(String table, String scenarioTable,
			String scenario, String image_date, String power, String vcc,
			String duty_cycle, String comments, String fps, String soc,
			String board, String os, String vccPower) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn
					.prepareStatement("insert into "
							+ table
							+ " (scenario_id,image_date,power,vcc_main,verify,duty_cycle,fps,ptf_link,created_at,updated_at,comments,soc,board,os,vccpower) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
			int scenario_id = ((Integer) CommonScenarios.getScenarios(
					scenarioTable).get(scenario)).intValue();
			pre.setInt(1, scenario_id);
			pre.setString(2, image_date);
			pre.setString(3, power);
			pre.setString(4, vcc);

			pre.setString(6, duty_cycle);
			pre.setString(7, fps);
			pre.setString(8, comments);
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(9, sdf.format(date));
			pre.setString(10, sdf.format(date));
			pre.setString(11, "");

			pre.setString(12, soc);
			pre.setString(13, board);
			pre.setString(14, os);
			pre.setString(15, vccPower);

			Statement state = conn.createStatement();

			String sql = "select power from " + table + " where scenario_id="
					+ scenario_id + " AND soc='" + soc + "' AND os='" + os
					+ "' AND image_date<'" + image_date + "' "
					+ "AND verify='P'" + " order by image_date desc LIMIT 10";

			ResultSet rs = state.executeQuery(sql);
			int totCount = 0;
			float sumOfOld = 0.0f;
			String oldData = "0";
			while (rs.next()) {
				oldData = rs.getString("power");
				totCount++;
				sumOfOld += Float.parseFloat(oldData);
			}
			float old = sumOfOld / totCount;
			try {
				String delta = PowerDataAnalysis.POWER_DELTA.get(scenario);
				if(delta == null){
					delta = "5%";//set default delta is 5%
				}
				System.out.println("delta is " + delta + " old average is : " + old + " today's power is: " + power);
				float avg = sumOfOld / totCount;
				if (delta.contains("%")) {
					String dt = delta.substring(0, delta.length() - 1);
					if (Math.abs(Float.parseFloat(power) - old) / old * 100.0F <= Float
							.parseFloat(dt)) {
						pre.setString(5, "P");
					} else {
						pre.setString(5, "F");
					}
				} else {
					float abs = Float.parseFloat(delta);
					if (Math.abs(Float.parseFloat(power) - avg) <= abs) {
						pre.setString(5, "P");
					} else {
						pre.setString(5, "F");
					}
				}

			} catch (Exception e) {
				e.printStackTrace();
				pre.setString(5, "TBD");
			}

			try {
				float act_fps = Float.parseFloat(fps);
				if (act_fps < PowerDataAnalysis.PERFORMANCE_BASE.get(scenario)) {
					pre.setString(5, "F");
				}
			} catch (Exception e) {

			}

			pre.executeUpdate();

			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return 0;
	}

	public static void insertAPMLPM(String table, String image_date,
			String branch, String os, String device, String assigner,
			String board, String purpose, String core, String ddr, String axi,
			String lpm, String vol, String vccCur, String vccVol,
			String batCur, String batVol, String status) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn.prepareStatement("insert into "
					+ table
					+ " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
			pre.setInt(1, get_max_id(table) + 1);
			pre.setString(2, image_date);
			pre.setString(3, branch);
			pre.setString(4, os);
			pre.setString(5, device);
			pre.setString(6, assigner);
			pre.setString(7, board);
			pre.setString(8, purpose);
			pre.setString(9, core);
			pre.setString(10, ddr);
			pre.setString(11, axi);
			pre.setString(12, lpm);
			pre.setString(13, vol);
			pre.setString(14, vccCur);
			pre.setString(15, vccVol);
			pre.setString(16, batCur);
			pre.setString(17, batVol);
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(18, sdf.format(date));
			pre.setString(19, sdf.format(date));
			pre.setString(20, status);

			pre.executeUpdate();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void insertAPMMOD(String table, String image_date,
			String branch, String os, String device, String assigner,
			String board, String purpose, String mod, String freq, String vol,
			String vccCur, String vccVol, String batCur, String batVol,
			String status) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn.prepareStatement("insert into "
					+ table + " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
			pre.setInt(1, get_max_id(table) + 1);
			pre.setString(2, image_date);
			pre.setString(3, branch);
			pre.setString(4, os);
			pre.setString(5, device);
			pre.setString(6, assigner);
			pre.setString(7, board);
			pre.setString(8, purpose);
			pre.setString(9, mod);
			pre.setString(10, freq);
			pre.setString(11, vol);
			pre.setString(12, vccCur);
			pre.setString(13, vccVol);
			pre.setString(14, batCur);
			pre.setString(15, batVol);
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(16, sdf.format(date));
			pre.setString(17, sdf.format(date));
			pre.setString(18, status);

			pre.executeUpdate();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void insert_to_ondemands(String scenario, String image_date,
			String power, String vcc, String duty_cycle, String purpose,
			String fps, String core, String gpu, String vpu, String ddr,
			String assigner, String platform, String pt4, String setting,
			String vccPower, String gpu1, String gpu2, String vpu1) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn
					.prepareStatement("insert into ondemands (power,duty_cycle,image_date,scenario,purpose,created_at,updated_at,ptf,core,ddr,vpu,gpu,fps,vcc_main,assigner,platform,setting,vccpower, gpu1, gpu2, vpu1) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, ?,?,?)");
			pre.setString(1, power);
			pre.setString(2, duty_cycle);
			pre.setString(3, image_date);
			pre.setString(4, scenario);
			pre.setString(5, purpose);// purpose
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(6, sdf.format(date));// created_at
			pre.setString(7, sdf.format(date));// updated_at
			pre.setString(8, pt4);// pt4 file path
			pre.setString(9, core);// core
			pre.setString(10, ddr);// ddr
			pre.setString(11, vpu);// vpu
			pre.setString(12, gpu);// gpu
			pre.setString(13, fps);// fps
			pre.setString(14, vcc);
			pre.setString(15, assigner);
			pre.setString(16, platform);
			pre.setString(17, setting);
			pre.setString(18, vccPower);
			pre.setString(19, gpu1);
			pre.setString(20, gpu2);
			pre.setString(21, vpu1);

			pre.executeUpdate();

			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void insert_to_performance(String caseName,
			String image_date, String perf, String fps, String battery,
			String vcc, String dutyCycle, String soc, String branch,
			String purpose) {
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://10.38.116.40:3306/power";
		String user = "root";
		String password = "marvell";
		try {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Connection conn = DriverManager.getConnection(url, user, password);

			PreparedStatement pre = conn
					.prepareStatement("insert into performances (image_date, caseName, perf, fps, power, vcc, duty_cycle, created_at, updated_at, soc, branch, purpose, isShow) values(?,?,?,?,?,?,?,?,?,?,?,?,?)");
			pre.setString(1, image_date);
			pre.setString(2, caseName);
			pre.setString(3, perf);
			pre.setString(4, fps);
			pre.setString(5, battery);
			pre.setString(6, vcc);
			pre.setString(7, dutyCycle);
			Date date = new Date(System.currentTimeMillis());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			pre.setString(8, sdf.format(date));// created_at
			pre.setString(9, sdf.format(date));// updated_at
			pre.setString(10, soc);
			pre.setString(11, branch);
			pre.setString(12, purpose);
			pre.setString(13, "Y");

			pre.executeUpdate();

			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static int insert_to_memory(String table, String scenarioTable,
	          int scenario_id, String image_date, String memory, String unit,
	          String verify, String comments, String soc, String board, String os, String link, String ddr_size) throws ClassNotFoundException {
	      String driver = "com.mysql.jdbc.Driver";
	      String url = "jdbc:mysql://10.38.116.40:3306/power";
	      String user = "root";
	      String password = "marvell";
	      try {
	          try {
	              Class.forName(driver);
	          } catch (ClassNotFoundException e) {
	              e.printStackTrace();
	          }
	          Connection conn = DriverManager.getConnection(url, user, password);

	          PreparedStatement pre = conn
	                  .prepareStatement("insert into "
	                          + table
	                          + " (scenario_id, image_date, memory, unit, verify, comments, created_at, updated_at, soc, board, os, link, ddr_size) "
	                          + "values(?,?,?,?,?,?,?,?,?,?,?,?,?)");

	         
	          pre.setInt(1, scenario_id);

	          pre.setString(2, image_date);
	          pre.setString(3, memory);
	          pre.setString(4, unit);
	          pre.setString(5, verify);
	          pre.setString(6, comments);

	          Date date = new Date(System.currentTimeMillis());
	          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	          pre.setString(7, sdf.format(date));
	          pre.setString(8, sdf.format(date));

	          pre.setString(9, soc);
	          pre.setString(10, board);
	          pre.setString(11, os);
	          pre.setString(12, link);
	          pre.setString(13, ddr_size);

	          pre.executeUpdate();

	          conn.close();
	      } catch (SQLException e) {
	          e.printStackTrace();
	      }
	      return 0;
	  }
}
