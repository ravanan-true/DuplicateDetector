package com.duplicatedetector.servlet;

import com.duplicatedetector.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@SuppressWarnings("serial")
@WebServlet("/admin-user-status")
public class AdminUserStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        // Verify admin session
        if (session == null
                || session.getAttribute("userId") == null
                || !"ADMIN".equals(session.getAttribute("userRole"))) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Admin access required.");
            return;
        }

        String userIdParam = request.getParameter("userId");
        String newStatus = request.getParameter("status");

        int userId;

        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(contextPath
                    + "/admin-users.jsp?message=Invalid+user");
            return;
        }

        if (!"ACTIVE".equals(newStatus)
                && !"INACTIVE".equals(newStatus)) {

            response.sendRedirect(contextPath
                    + "/admin-users.jsp?message=Invalid+status");
            return;
        }

        int adminId = (Integer) session.getAttribute("userId");

        // Prevent changing the currently logged-in admin's account
        if (userId == adminId) {
            response.sendRedirect(contextPath
                    + "/admin-users.jsp?message=Cannot+change+your+own+status");
            return;
        }

        String sql = "UPDATE users SET account_status = ? "
                   + "WHERE user_id = ? AND role = 'USER'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, userId);

            int updated = ps.executeUpdate();

            String message = updated == 1
                    ? "Account+status+updated"
                    : "User+not+found";

            response.sendRedirect(contextPath
                    + "/admin-users.jsp?message=" + message);

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to update user account status", e);

            response.sendRedirect(contextPath
                    + "/admin-users.jsp?message=Database+error");
        }
    }
}
