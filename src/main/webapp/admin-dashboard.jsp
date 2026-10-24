
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*,
    com.duplicatedetector.util.DBConnection" %>

<%
    if (session.getAttribute("userId") == null ||
        !"ADMIN".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    long totalUsers = 0;
    long totalScans = 0;
    long totalDuplicates = 0;
    long storageSaved = 0;

    try (Connection con = DBConnection.getConnection()) {

        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE role = 'USER'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalUsers = rs.getLong(1);
        }

        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM scan_history");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalScans = rs.getLong(1);
        }

        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COALESCE(SUM(duplicate_count), 0), " +
                "COALESCE(SUM(potential_space_saved), 0) " +
                "FROM scan_history");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalDuplicates = rs.getLong(1);
                storageSaved = rs.getLong(2);
            }
        }

    } catch (SQLException e) {
        application.log("Admin dashboard database error", e);
    }

    String savedDisplay;
    if (storageSaved >= 1073741824L) {
        savedDisplay = String.format("%.2f GB",
            storageSaved / 1073741824.0);
    } else if (storageSaved >= 1048576L) {
        savedDisplay = String.format("%.2f MB",
            storageSaved / 1048576.0);
    } else if (storageSaved >= 1024L) {
        savedDisplay = String.format("%.2f KB",
            storageSaved / 1024.0);
    } else {
        savedDisplay = storageSaved + " Bytes";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard | DuplicateDetector</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #080d1b;
    color: #f1f5f9;
}

nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    padding: 20px 6%;
    background: #10182b;
    border-bottom: 1px solid #26334d;
}

.brand {
    font-size: 22px;
    font-weight: bold;
    color: #60a5fa;
}

nav a {
    color: #cbd5e1;
    text-decoration: none;
    margin-left: 16px;
}

nav a:hover {
    color: #60a5fa;
}

main {
    max-width: 1150px;
    margin: 45px auto;
    padding: 0 22px;
}

h1 {
    margin-bottom: 8px;
}

.subtitle {
    color: #94a3b8;
    margin-bottom: 32px;
}

.stats {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}

.card {
    background: linear-gradient(145deg, #151f35, #101729);
    border: 1px solid #293853;
    border-radius: 16px;
    padding: 26px;
}

.card h3 {
    color: #a5b4fc;
    font-size: 15px;
    font-weight: normal;
}

.number {
    font-size: 32px;
    font-weight: bold;
    color: #60a5fa;
    overflow-wrap: anywhere;
}

.actions {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    margin-top: 30px;
}

.btn {
    display: inline-block;
    padding: 12px 18px;
    background: #2563eb;
    border-radius: 9px;
    color: white;
    text-decoration: none;
}

.btn.secondary {
    background: #26334d;
}

footer {
    text-align: center;
    padding: 30px 15px;
    color: #64748b;
}

@media (max-width: 600px) {
    nav {
        padding: 18px;
    }

    nav a {
        margin-left: 0;
        margin-right: 12px;
    }

    main {
        margin-top: 28px;
        padding: 0 16px;
    }

    .stats {
        grid-template-columns: 1fr;
        gap: 14px;
    }

    .card {
        padding: 21px;
    }

    .number {
        font-size: 27px;
    }
}
</style>
</head>

<body>

<%@ include file="/navbar.jsp" %>

<main>
    <h1>Admin Dashboard</h1>
    <p class="subtitle">Monitor users, scans and duplicate-file statistics.</p>

    <section class="stats">
        <div class="card">
            <h3>Registered Users</h3>
            <div class="number"><%= totalUsers %></div>
        </div>

        <div class="card">
            <h3>Total Scans</h3>
            <div class="number"><%= totalScans %></div>
        </div>

        <div class="card">
            <h3>Duplicate Files Reported</h3>
            <div class="number"><%= totalDuplicates %></div>
        </div>

        <div class="card">
            <h3>Potential Storage Saved</h3>
            <div class="number"><%= savedDisplay %></div>
        </div>
    </section>

    <div class="actions">
        <a class="btn" href="<%= request.getContextPath() %>/admin-users.jsp">
            Manage Users
        </a>

        <a class="btn secondary"
           href="<%= request.getContextPath() %>/admin-scans.jsp">
            View All Scans
        </a>
    </div>
</main>

<footer>DuplicateDetector · Administration Panel</footer>

</body>
</html>
