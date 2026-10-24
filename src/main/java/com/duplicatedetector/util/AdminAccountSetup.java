
package com.duplicatedetector.util;

import java.io.Console;
import java.util.Scanner;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminAccountSetup {

    public static void main(String[] args) {

        Console console = System.console();
        Scanner scanner = null;

        try {
            String fullName;
            String email;
            String password;
            String confirmPassword;

            if (console != null) {
                fullName = console.readLine("Admin full name: ");
                email = console.readLine("Admin email: ");
                password = new String(
                        console.readPassword("Admin password: "));
                confirmPassword = new String(
                        console.readPassword("Confirm password: "));
            } else {
                // Eclipse Console may not support hidden password input.
                scanner = new Scanner(System.in);

                System.out.print("Admin full name: ");
                fullName = scanner.nextLine().trim();

                System.out.print("Admin email: ");
                email = scanner.nextLine().trim();

                System.out.print("Admin password: ");
                password = scanner.nextLine();

                System.out.print("Confirm password: ");
                confirmPassword = scanner.nextLine();

                System.out.println(
                    "Note: Eclipse console input may display the password.");
            }

            fullName = fullName.trim();
            email = email.trim().toLowerCase();

            if (fullName.isEmpty()
                    || fullName.length() > 100
                    || email.length() > 150
                    || !email.matches(
                      "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
                    || password.length() < 8
                    || password.length() > 128
                    || !password.equals(confirmPassword)) {

                System.out.println(
                        "Invalid details. Check the name, email and password.");
                return;
            }

            try (Connection connection = DBConnection.getConnection()) {

                // This setup utility creates only the first admin.
                try (PreparedStatement checkAdmin =
                        connection.prepareStatement(
                                "SELECT user_id FROM users "
                              + "WHERE role = 'ADMIN' LIMIT 1");
                     ResultSet rs = checkAdmin.executeQuery()) {

                    if (rs.next()) {
                        System.out.println(
                                "An admin already exists. No changes made.");
                        return;
                    }
                }

                // Never promote an existing account automatically.
                try (PreparedStatement checkEmail =
                        connection.prepareStatement(
                                "SELECT user_id FROM users WHERE email = ?")) {

                    checkEmail.setString(1, email);

                    try (ResultSet rs = checkEmail.executeQuery()) {
                        if (rs.next()) {
                            System.out.println(
                                "This email already exists. "
                              + "Use a new email for the initial admin.");
                            return;
                        }
                    }
                }

                String passwordHash =
                        PasswordUtil.hashPassword(password);

                String sql = "INSERT INTO users "
                           + "(full_name, email, password_hash, role) "
                           + "VALUES (?, ?, ?, 'ADMIN')";

                try (PreparedStatement insert =
                        connection.prepareStatement(sql)) {

                    insert.setString(1, fullName);
                    insert.setString(2, email);
                    insert.setString(3, passwordHash);

                    insert.executeUpdate();
                }

                System.out.println(
                        "Admin account created successfully.");
                System.out.println("Email: " + email);
                System.out.println(
                        "Now log in through your existing login page.");
            }

        } catch (Exception e) {
            System.err.println(
                    "Admin setup failed: " + e.getMessage());
        } finally {
            // Do not retain password values longer than necessary.
            // Java Strings cannot be reliably erased from memory.
        }
    }
}
