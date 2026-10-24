package com.duplicatedetector.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.duplicatedetector.util.DBConnection;
import com.duplicatedetector.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword =
                request.getParameter("confirmPassword");

        if (fullName == null || email == null
                || password == null || confirmPassword == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=invalid");
            return;
        }

        fullName = fullName.trim();
        email = email.trim().toLowerCase();

        if (fullName.isEmpty() || email.isEmpty()
                || password.isEmpty()
                || confirmPassword.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=empty");
            return;
        }

        if (fullName.length() > 100 || email.length() > 150 || password.length() < 8 || password.length() > 128) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=invalid");
            return;
        }

        if (!email.matches(
                "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=email");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=password");
            return;
        }

        String sql = "INSERT INTO users "
                + "(full_name, email, password_hash) "
                + "VALUES (?, ?, ?)";

        try {
            String passwordHash =
                    PasswordUtil.hashPassword(password);

            try (Connection connection =
                        DBConnection.getConnection();
                 PreparedStatement statement =
                        connection.prepareStatement(sql)) {

                statement.setString(1, fullName);
                statement.setString(2, email);
                statement.setString(3, passwordHash);

                statement.executeUpdate();
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?registered=1");

        } catch (SQLException e) {

            if ("23000".equals(e.getSQLState())) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/register.jsp?error=exists");
            } else {
                throw new ServletException(
                        "Unable to register user.", e);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to secure the password.", e);
        }
    }
}
