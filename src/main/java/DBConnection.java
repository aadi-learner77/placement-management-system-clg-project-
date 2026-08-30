import java.sql.*;

public class DBConnection {

    static String url =
        "jdbc:mysql://localhost:3306/placement_system";

    static String username = "root";
    static String password = "root";

    public static Connection getConnection() {

        Connection con = null;

        try {

            Class.forName(
                "com.mysql.cj.jdbc.Driver"
            );

            con = DriverManager.getConnection(
            		"jdbc:mysql://localhost:3306/placement_system",
                "root",
                "root"
            );

        } catch(Exception e) {
            e.printStackTrace();
        }

        return con;
    }
}