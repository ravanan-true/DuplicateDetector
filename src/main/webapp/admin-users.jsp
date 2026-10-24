
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*,
    com.duplicatedetector.util.DBConnection" %>

<%!
    public String escapeHtml(String value) {
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

    String statusMessage = request.getParameter("message");
    String errorMessage = null;
    int displayedUsers = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Users | DuplicateDetector</title>

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
    font-size: 21px;
    font-weight: bold;
    color: #60a5fa;
}

nav a {
    color: #cbd5e1;
    text-decoration: none;
    margin-left: 15px;
}

main {
    max-width: 1200px;
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
    border: 0;
    border-radius: 8px;
    padding: 12px 16px;
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
    border-collapse: collapse;
    min-width: 680px;
}

th, td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #293853;
}

th {
    color: #93c5fd;
    background: #151f35;
}

tr:hover td { background: #142039; }

.role {
    display: inline-block;
    padding: 5px 9px;
    border-radius: 20px;
    font-size: 12px;
    background: #1e3a5f;
    color: #bfdbfe;
}

.role.admin {
    background: #42245e;
    color: #e9d5ff;
}

.notice {
    padding: 13px;
    margin: 15px 0;
    background: #153b30;
    border-radius: 8px;
    color: #bbf7d0;
}

.error {
    padding: 13px;
    margin: 15px 0;
    background: #451d2b;
    border-radius: 8px;
    color: #fecaca;
}

.empty {
    text-align: center;
    padding: 30px;
    color: #94a3b8;
}

footer {
    text-align: center;
    padding: 30px;
    color: #64748b;
}

@media(max-width: 600px) {
    main { padding: 0 12px; }
    nav { padding: 18px; }
    nav a { margin-left: 0; margin-right: 12px; }
    .toolbar { flex-direction: column; }
    .toolbar button { width: 100%; }
}
</style>
</head>

<body>

<%@ include file="/navbar.jsp" %>

<main>
    <h1>Manage Users</h1>
    <p class="subtitle">View registered accounts and their assigned roles.</p>

    <% if (statusMessage != null && !statusMessage.isBlank()) { %>
        <div class="notice"><%= escapeHtml(statusMessage) %></div>
    <% } %>

    <form class="toolbar" method="get"
          action="<%= request.getContextPath() %>/admin-users.jsp">
        <input type="search" name="search"
               placeholder="Search by name or email..."
               value="<%= escapeHtml(search) %>">
        <button type="submit">Search Users</button>
        <a class="btn" href="<%= request.getContextPath() %>/admin-users.jsp">Reset</a>
    </form>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Role</th>
					<th>Account Status</th>
					<th>Action</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
            <%
	            String sql =
		            "SELECT user_id, full_name, email, role, account_status, created_at " +
		            "FROM users " +
		            "WHERE full_name LIKE ? OR email LIKE ? " +
		            "ORDER BY user_id DESC";

                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                    String searchPattern = "%" + search + "%";
                    ps.setString(1, searchPattern);
                    ps.setString(2, searchPattern);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            displayedUsers++;
                            String role = rs.getString("role");
                            if (role == null) role = "USER";
            %>
                <tr>
                    <td><%= rs.getInt("user_id") %></td>
                    <td><%= escapeHtml(rs.getString("full_name")) %></td>
                    <td><%= escapeHtml(rs.getString("email")) %></td>                 
					<td>
					    <span class="role <%= "ADMIN".equals(role) ? "admin" : "" %>">
					        <%= escapeHtml(role) %>
					    </span>
					</td>
					
					<td>
					    <%= escapeHtml(rs.getString("account_status")) %>
					</td>
					
					<td>
					    <% if ("USER".equals(role)) {
					        String status = rs.getString("account_status");
					        boolean active = "ACTIVE".equalsIgnoreCase(status);
					    %>
					        <form method="post"
					              action="<%= request.getContextPath() %>/admin-user-status"
					              onsubmit="return confirm('Change this user account status?');">
					
					            <input type="hidden"
					                   name="userId"
					                   value="<%= rs.getInt("user_id") %>">
					
					            <input type="hidden"
					                   name="status"
					                   value="<%= active ? "INACTIVE" : "ACTIVE" %>">
					
					            <button type="submit">
					                <%= active ? "Deactivate" : "Activate" %>
					            </button>
					        </form>
					    <% } else { %>
					        Admin account
					    <% } %>
					</td>
					
					<td>
					    <%= escapeHtml(String.valueOf(rs.getTimestamp("created_at"))) %>
					</td>
				</tr>
            <%
                        }
                    }
                } catch (SQLException e) {
                    application.log("Unable to load admin user list", e);
                    errorMessage = "Unable to load users. Check the database connection and server logs.";
                }

                if (displayedUsers == 0 && errorMessage == null) {
            %>
                <tr>
                    <td colspan="7" class="empty">No users found.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <p class="subtitle">
        Total accounts displayed: <strong><%= displayedUsers %></strong>
    </p>
    
    <% if (errorMessage != null) { %>
	    <div class="error">
        	<%= escapeHtml(errorMessage) %>
    	</div>
	<% } %>

</main>

<footer>DuplicateDetector · User Administration</footer>

</body>
</html>
