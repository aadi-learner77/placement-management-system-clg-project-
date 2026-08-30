package placement_system;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        Connection con =
            DBConnection.getConnection();

        if(con != null) {

            System.out.println(
                "SUCCESS"
            );

        } else {

            System.out.println(
                "FAILED"
            );
        }
    }
}