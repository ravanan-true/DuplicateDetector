
package com.duplicatedetector.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.duplicatedetector.util.DBConnection;
import com.duplicatedetector.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        String loginPage =
                request.getContextPath() + "/login.jsp";

        if (email == null || password == null
                || email.trim().isEmpty()
                || password.isEmpty()) {

            response.sendRedirect(loginPage + "?error=invalid");
            return;
        }

        email = email.trim().toLowerCase();

        if (email.length() > 150 || password.length() > 128) {
            response.sendRedirect(loginPage + "?error=invalid");
            return;
        }

        String sql = "SELECT user_id, full_name, email, "
                + "password_hash, role, account_status "
                + "FROM users WHERE email = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, email);

            try (ResultSet result = statement.executeQuery()) {

                if (!result.next()) {
                    response.sendRedirect(
                            loginPage + "?error=invalid");
                    return;
                }

                String storedHash =
                        result.getString("password_hash");

                boolean passwordMatches;

                try {
                    passwordMatches =
                            PasswordUtil.verifyPassword(
                                    password, storedHash);
                } catch (Exception e) {
                    throw new ServletException(
                            "Unable to verify password.", e);
                }

                if (!passwordMatches) {
                    response.sendRedirect(
                            loginPage + "?error=invalid");
                    return;
                }

                String accountStatus = result.getString("account_status");

                if (accountStatus == null
                        || !"ACTIVE".equalsIgnoreCase(accountStatus.trim())) {

                    response.sendRedirect(
                            loginPage + "?error=account_inactive");
                    return;
                }
                
                int userId = result.getInt("user_id");
                String fullName = result.getString("full_name");
                String userEmail = result.getString("email");
                String role = result.getString("role");

                if (role == null) {
                    role = "USER";
                }

                role = role.trim().toUpperCase();

                // Only recognized roles are allowed.
                if (!role.equals("ADMIN")
                        && !role.equals("USER")) {
                    response.sendRedirect(
                            loginPage + "?error=invalid");
                    return;
                }

                HttpSession oldSession =
                        request.getSession(false);

                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session =
                        request.getSession(true);

                request.changeSessionId();

                session.setAttribute("userId", userId);
                session.setAttribute("fullName", fullName);
                session.setAttribute("userEmail", userEmail);
                session.setAttribute("userRole", role);

                session.setMaxInactiveInterval(30 * 60);

                if ("ADMIN".equals(role)) {
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/admin-dashboard.jsp");
                } else {
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/dashboard.jsp");
                }
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to log in.", e);
        }
    }
}
