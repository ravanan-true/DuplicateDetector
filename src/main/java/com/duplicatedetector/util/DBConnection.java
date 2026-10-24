
package com.duplicatedetector.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        "jdbc:mysql://mysql-321c4149-ragul12905-22cc.d.aivencloud.com:23009/defaultdb?sslMode=REQUIRED";

    private static final String USER = "avnadmin";

    private static final String PASSWORD =
        System.getenv("DB_PASSWORD");

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL JDBC driver was not found. Check WEB-INF/lib.",
                e
            );
        }

        if (PASSWORD == null || PASSWORD.isBlank()) {
            throw new SQLException(
                "DB_PASSWORD environment variable is not configured."
            );
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
