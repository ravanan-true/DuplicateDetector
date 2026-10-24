
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*,
    com.duplicatedetector.util.DBConnection" %>

<%!
    public String escapeScanHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("userId") == null ||
        !"ADMIN".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String search = request.getParameter("search");
    if (search == null) search = "";
    search = search.trim();

    int totalRows = 0;
    String errorMessage = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>All Scans | DuplicateDetector Admin</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #080d1b;
    color: #f1f5f9;
}

nav {
    padding: 20px 5%;
    background: #10182b;
    border-bottom: 1px solid #293853;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
}

.brand {
    color: #60a5fa;
    font-size: 21px;
    font-weight: bold;
}

nav a {
    color: #cbd5e1;
    text-decoration: none;
    margin-left: 15px;
}

main {
    max-width: 1250px;
    margin: 35px auto;
    padding: 0 20px;
}

.subtitle { color: #94a3b8; }

.toolbar {
    display: flex;
    gap: 12px;
    margin: 25px 0;
}

input {
    flex: 1;
    min-width: 0;
    padding: 13px;
    border-radius: 8px;
    border: 1px solid #334155;
    background: #111b30;
    color: white;
}

button, .btn {
    padding: 12px 16px;
    border: 0;
    border-radius: 8px;
    background: #2563eb;
    color: white;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
}

.table-wrap {
    overflow-x: auto;
    background: #10182b;
    border: 1px solid #293853;
    border-radius: 12px;
}

table {
    width: 100%;
    min-width: 850px;
    border-collapse: collapse;
}

th, td {
    padding: 14px;
    text-align: left;
    border-bottom: 1px solid #293853;
}

th {
    background: #151f35;
    color: #93c5fd;
}

tr:hover td { background: #142039; }

.status {
    display: inline-block;
    padding: 5px 9px;
    border-radius: 20px;
    background: #1e3a5f;
    color: #bfdbfe;
    font-size: 12px;
}

.empty {
    text-align: center;
    padding: 30px;
    color: #94a3b8;
}

.error {
    background: #451d2b;
    color: #fecaca;
    padding: 14px;
    border-radius: 8px;
    margin: 15px 0;
}

footer {
    text-align: center;
    padding: 30px;
    color: #64748b;
}

@media(max-width: 600px) {
    nav { padding: 18px; }
    nav a { margin-left: 0; margin-right: 12px; }
    main { padding: 0 12px; }
    .toolbar { flex-direction: column; }
    .toolbar button { width: 100%; }
}
</style>
</head>

<body>

<%@ include file="/navbar.jsp" %>

<main>
    <h1>All Scan History</h1>
    <p class="subtitle">Review scan activity across registered accounts.</p>

    <form class="toolbar" method="get"
          action="<%= request.getContextPath() %>/admin-scans.jsp">
        <input type="search" name="search"
               placeholder="Search by user name, email or scan status..."
               value="<%= escapeScanHtml(search) %>">
        <button type="submit">Search</button>
        <a class="btn" href="<%= request.getContextPath() %>/admin-scans.jsp">Reset</a>
    </form>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Scan ID</th>
                    <th>User</th>
                    <th>Email</th>
                    <th>Total Files</th>
                    <th>Duplicates</th>
                    <th>Potential Space Saved</th>
                    <th>Status</th>
                    <th>Scanned At</th>
                </tr>
            </thead>
            <tbody>
            <%
                String sql =
                    "SELECT sh.scan_id, sh.user_id, " +
                    "u.full_name, u.email, sh.total_files, " +
                    "sh.duplicate_count, sh.potential_space_saved, " +
                    "sh.scan_status, sh.scanned_at " +
                    "FROM scan_history sh " +
                    "LEFT JOIN users u ON sh.user_id = u.user_id " +
                    "WHERE COALESCE(u.full_name, '') LIKE ? " +
                    "OR COALESCE(u.email, '') LIKE ? " +
                    "OR COALESCE(sh.scan_status, '') LIKE ? " +
                    "ORDER BY sh.scanned_at DESC, sh.scan_id DESC";

                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                    String pattern = "%" + search + "%";
                    ps.setString(1, pattern);
                    ps.setString(2, pattern);
                    ps.setString(3, pattern);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            totalRows++;

                            long bytes = rs.getLong("potential_space_saved");
                            String saved;

                            if (bytes >= 1073741824L) {
                                saved = String.format("%.2f GB", bytes / 1073741824.0);
                            } else if (bytes >= 1048576L) {
                                saved = String.format("%.2f MB", bytes / 1048576.0);
                            } else if (bytes >= 1024L) {
                                saved = String.format("%.2f KB", bytes / 1024.0);
                            } else {
                                saved = bytes + " Bytes";
                            }

                            String userName = rs.getString("full_name");
                            String email = rs.getString("email");
                            String status = rs.getString("scan_status");
            %>
                <tr>
                    <td><%= rs.getLong("scan_id") %></td>
                    <td><%= escapeScanHtml(
                        userName == null ? "Unknown / Deleted User" : userName) %></td>
                    <td><%= escapeScanHtml(
                        email == null ? "—" : email) %></td>
                    <td><%= rs.getLong("total_files") %></td>
                    <td><%= rs.getLong("duplicate_count") %></td>
                    <td><%= escapeScanHtml(saved) %></td>
                    <td>
                        <span class="status">
                            <%= escapeScanHtml(
                                status == null ? "Unknown" : status) %>
                        </span>
                    </td>
                    <td><%= escapeScanHtml(
                        String.valueOf(rs.getTimestamp("scanned_at"))) %></td>
                </tr>
            <%
                        }
                    }
                } catch (SQLException e) {
                    application.log("Admin scan history query failed", e);
                    errorMessage = "Unable to load scan history. Check the Eclipse Console and database schema.";
                }

                if (totalRows == 0 && errorMessage == null) {
            %>
                <tr>
                    <td colspan="8" class="empty">No scan records found.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <p class="subtitle">Scan records displayed: <strong><%= totalRows %></strong></p>

	<% if (errorMessage != null) { %>
	    <div class="error">
        	<%= escapeScanHtml(errorMessage) %>
    	</div>
	<% } %>


</main>

<footer>DuplicateDetector · Administrative Scan Monitoring</footer>

</body>
</html>
