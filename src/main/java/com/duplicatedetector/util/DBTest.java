package com.duplicatedetector.util;

import java.sql.Connection;
import java.sql.SQLException;

public class DBTest {

    public static void main(String[] args) {

        try (Connection connection = DBConnection.getConnection()) {

            System.out.println("MySQL Connected Successfully!");
            System.out.println("Database: " + connection.getCatalog());

        } 
        catch (SQLException e) {
            System.out.println("Database connection failed!");
            e.printStackTrace();
        }
    }
}
