<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.duplicatedetector.util.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String formatBytes(long bytes) {
        if (bytes < 1024) return bytes + " bytes";

        if (bytes < 1024L * 1024) {
            return String.format(java.util.Locale.US,
                    "%.1f KB", bytes / 1024.0);
        }

        if (bytes < 1024L * 1024 * 1024) {
            return String.format(java.util.Locale.US,
                    "%.1f MB", bytes / (1024.0 * 1024));
        }

        return String.format(java.util.Locale.US,
                "%.2f GB", bytes / (1024.0 * 1024 * 1024));
    }
%>

<%
    response.setHeader("Cache-Control",
            "no-store, no-cache, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null ||
        !(session.getAttribute("userId") instanceof Number)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = ((Number) session.getAttribute("userId")).intValue();

    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "User";
    }

    String sql = "SELECT scan_id, total_files, duplicate_count, " +
                 "potential_space_saved, scan_status, scanned_at " +
                 "FROM scan_history WHERE user_id = ? ORDER BY scan_id DESC";

    int totalScans = 0;
    long totalFilesScanned = 0;
    long totalDuplicates = 0;
    long totalSpaceSaved = 0;

    boolean dbError = false;
    String dbErrorId = "";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                totalScans++;
                totalFilesScanned += rs.getLong("total_files");
                totalDuplicates += rs.getLong("duplicate_count");
                totalSpaceSaved += rs.getLong("potential_space_saved");
            }
        }
    } catch (SQLException e) {
        dbError = true;
        application.log("Unable to calculate scan history statistics", e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Scan History | DuplicateDetector</title>

<style>
:root {
    --bg: #080d1b;
    --panel: #111a2e;
    --border: rgba(148,163,184,.15);
    --text: #edf2ff;
    --muted: #94a3b8;
    --blue: #5685ff;
    --purple: #9b7bff;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    padding: 26px 20px;
    font-family: "Segoe UI", Arial, sans-serif;
    background: radial-gradient(ellipse at top left, #172554 0%, var(--bg) 48%);
    color: var(--text);
}

.container {
    width: 100%;
    max-width: 1250px;
    margin: 0 auto;
}

.navbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    padding: 17px 22px;
    margin-bottom: 34px;
    background: rgba(17,26,46,.92);
    border: 1px solid var(--border);
    border-radius: 16px;
}

.brand {
    color: var(--text);
    font-size: 20px;
    font-weight: 800;
}

.brand span {
    color: #82a4ff;
}

.nav-links {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 20px;
}

.nav-links a {
    color: #cbd5e1;
    text-decoration: none;
    font-size: 14px;
}

.nav-links a:hover,
.nav-links a.active {
    color: #91adff;
}

.logout-form {
    margin: 0;
}

.logout-btn {
    padding: 10px 15px;
    color: #ffb4c0;
    background: rgba(244,63,94,.08);
    border: 1px solid rgba(244,63,94,.3);
    border-radius: 9px;
    cursor: pointer;
    font-weight: 600;
}

.header {
    margin-bottom: 25px;
}

.eyebrow {
    color: #91adff;
    text-transform: uppercase;
    letter-spacing: 2px;
    font-size: 11px;
    font-weight: bold;
}

.header h1 {
    margin: 10px 0;
    font-size: clamp(28px, 4vw, 38px);
    letter-spacing: -1px;
}

.header p {
    color: var(--muted);
    line-height: 1.7;
    margin: 0;
}

.stats {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 15px;
    margin-bottom: 25px;
}

.stat-card {
    min-width: 0;
    padding: 21px;
    background: linear-gradient(145deg, #141e36, #101629);
    border: 1px solid var(--border);
    border-radius: 16px;
}

.stat-label {
    color: var(--muted);
    font-size: 13px;
    margin-bottom: 13px;
}

.stat-value {
    font-size: clamp(23px, 3vw, 31px);
    font-weight: 800;
    overflow-wrap: anywhere;
}

.stat-note {
    margin-top: 8px;
    color: #7787a5;
    font-size: 11px;
}

.blue { color: #86a5ff; }
.purple { color: #b9a2ff; }
.green { color: #6ee7b7; }
.red { color: #ff8799; }

.card {
    padding: 24px;
    background: linear-gradient(145deg, rgba(17,26,46,.98), rgba(13,20,37,.98));
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: 0 18px 50px rgba(0,0,0,.18);
}

.card-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}

.card-heading h2 {
    margin: 0;
    font-size: 20px;
}

.result-count {
    color: #a5b4fc;
    background: #202448;
    padding: 7px 11px;
    border-radius: 20px;
    font-size: 12px;
}

.card-description {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
    margin: 10px 0 22px;
}

.filters {
    display: grid;
    grid-template-columns: minmax(200px, 1fr) 190px;
    gap: 12px;
    margin-bottom: 20px;
}

.search-box,
.status-filter {
    width: 100%;
    padding: 13px 15px;
    color: #edf2ff;
    background: #0b1223;
    border: 1px solid #303c59;
    border-radius: 10px;
    outline: none;
    font: inherit;
    font-size: 13px;
}

.search-box:focus,
.status-filter:focus {
    border-color: #7195ff;
    box-shadow: 0 0 0 3px rgba(86,133,255,.12);
}

.status-filter option {
    background: #111a2e;
    color: white;
}

.table-wrap {
    width: 100%;
    overflow-x: auto;
    border: 1px solid var(--border);
    border-radius: 12px;
}

table {
    width: 100%;
    min-width: 850px;
    border-collapse: collapse;
}

th, td {
    padding: 16px 14px;
    text-align: left;
    border-bottom: 1px solid var(--border);
    font-size: 13px;
    white-space: nowrap;
}

th {
    background: #17233d;
    color: #b8c8f5;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: .7px;
}

tbody tr {
    transition: background .2s;
}

tbody tr:hover {
    background: rgba(86,133,255,.07);
}

tbody tr:last-child td {
    border-bottom: none;
}

.scan-id {
    color: #a8bdff;
    font-weight: bold;
}

.duplicate-count {
    color: #ff8799;
    font-weight: bold;
}

.space-value {
    color: #6ee7b7;
}

.badge {
    display: inline-block;
    padding: 6px 10px;
    border-radius: 20px;
    background: rgba(52,211,153,.12);
    border: 1px solid rgba(52,211,153,.2);
    color: #6ee7b7;
    font-size: 11px;
    font-weight: bold;
}

.badge.failed {
    color: #fda4af;
    background: rgba(244,63,94,.12);
    border-color: rgba(244,63,94,.25);
}

.badge.other {
    color: #c4b5fd;
    background: rgba(139,92,246,.12);
    border-color: rgba(139,92,246,.25);
}

.view-btn {
    display: inline-block;
    padding: 9px 12px;
    border-radius: 8px;
    background: linear-gradient(110deg, var(--blue), var(--purple));
    color: white;
    text-decoration: none;
    font-size: 12px;
    font-weight: bold;
    transition: transform .2s;
}

.view-btn:hover {
    transform: translateY(-1px);
}

.empty-message {
    text-align: center;
    color: var(--muted);
    padding: 35px 20px;
    line-height: 1.8;
    white-space: normal;
}

.error-message {
    padding: 16px;
    color: #fda4af;
    background: rgba(244,63,94,.1);
    border: 1px solid rgba(244,63,94,.2);
    border-radius: 10px;
    white-space: normal;
}

.back-btn {
    display: inline-block;
    margin-top: 24px;
    padding: 11px 15px;
    color: #b9caff;
    background: rgba(86,133,255,.1);
    border: 1px solid rgba(86,133,255,.22);
    border-radius: 9px;
    text-decoration: none;
    font-size: 13px;
    font-weight: bold;
}

.footer {
    text-align: center;
    color: #64748b;
    font-size: 12px;
    margin-top: 28px;
    padding: 15px;
}

@media (max-width: 950px) {
    .stats {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 600px) {
    body {
        padding: 14px 10px;
    }

    .navbar {
        padding: 15px;
        margin-bottom: 25px;
    }

    .nav-links {
        gap: 13px;
    }

    .card {
        padding: 16px 12px;
    }

    .stats {
        gap: 10px;
    }

    .stat-card {
        padding: 15px;
    }

    .filters {
        grid-template-columns: 1fr;
    }

    .header h1 {
        font-size: 28px;
    }
}
</style>
</head>

<body>
<div class="container">

    <%@ include file="/navbar.jsp" %>

    <header class="header">
        <div class="eyebrow">Your activity</div>
        <h1>Scan History</h1>
        <p>Welcome, <%= escapeHtml(fullName) %>. Review your previous file scans and duplicate results.</p>
    </header>

    <% if (!dbError) { %>
    <section class="stats">
        <div class="stat-card">
            <div class="stat-label">Total Scans</div>
            <div class="stat-value blue"><%= String.format(java.util.Locale.US, "%,d", totalScans) %></div>
            <div class="stat-note">Scans in your account</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Files Scanned</div>
            <div class="stat-value purple"><%= String.format(java.util.Locale.US, "%,d", totalFilesScanned) %></div>
            <div class="stat-note">Across your recorded scans</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Duplicates Found</div>
            <div class="stat-value red"><%= String.format(java.util.Locale.US, "%,d", totalDuplicates) %></div>
            <div class="stat-note">Across your recorded scans</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Potential Space Saved</div>
            <div class="stat-value green"><%= escapeHtml(formatBytes(totalSpaceSaved)) %></div>
            <div class="stat-note">Combined recorded estimate</div>
        </div>
    </section>
    <% } %>

    <section class="card">
        <div class="card-heading">
            <h2>Your Scan Records</h2>
            <span class="result-count" id="resultCount">Loading records...</span>
        </div>

        <p class="card-description">
            Search your records or filter them by status. Select View Details to inspect a scan.
        </p>

        <div class="filters">
            <input
                type="search"
                class="search-box"
                id="historySearch"
                placeholder="Search by scan ID, files, duplicates or status..."
                aria-label="Search scan history">

            <select class="status-filter" id="statusFilter" aria-label="Filter by scan status">
                <option value="all">All statuses</option>
                <option value="completed">Completed</option>
                <option value="failed">Failed</option>
                <option value="other">Other statuses</option>
            </select>
        </div>

        <div class="table-wrap">
            <table id="historyTable">
                <thead>
                    <tr>
                        <th>Scan ID</th>
                        <th>Total Files</th>
                        <th>Duplicates</th>
                        <th>Space Saved</th>
                        <th>Status</th>
                        <th>Scan Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="historyBody">

                <% if (dbError) { %>
                    <tr>
                        <td colspan="7">
                            <div class="error-message">
                                Unable to load scan history statistics. Please check your database connection and Tomcat logs.
                            </div>
                        </td>
                    </tr>
                <% } else {
                    try (Connection con = DBConnection.getConnection();
                         PreparedStatement ps = con.prepareStatement(sql)) {

                        ps.setInt(1, userId);

                        try (ResultSet rs = ps.executeQuery()) {
                            boolean found = false;

                            while (rs.next()) {
                                found = true;

                                int scanId = rs.getInt("scan_id");
                                long totalFiles = rs.getLong("total_files");
                                long duplicates = rs.getLong("duplicate_count");
                                long spaceSaved = rs.getLong("potential_space_saved");

                                String status = rs.getString("scan_status");
                                Timestamp scannedAt = rs.getTimestamp("scanned_at");

                                if (status == null || status.trim().isEmpty()) {
                                    status = "Unknown";
                                }

                                String normalizedStatus = status.trim().toLowerCase(Locale.ROOT);
                                String badgeClass = "other";

                                if ("completed".equals(normalizedStatus)) {
                                    badgeClass = "completed";
                                } else if ("failed".equals(normalizedStatus)) {
                                    badgeClass = "failed";
                                }
                %>
                    <tr class="history-row"
                        data-search="<%= escapeHtml(
                            ("#" + scanId + " " + totalFiles + " " +
                            duplicates + " " + status).toLowerCase(Locale.ROOT)
                        ) %>"
                        data-status="<%= escapeHtml(normalizedStatus) %>">

                        <td class="scan-id">#<%= scanId %></td>
                        <td><%= String.format(Locale.US, "%,d", totalFiles) %></td>
                        <td class="duplicate-count"><%= String.format(Locale.US, "%,d", duplicates) %></td>
                        <td class="space-value"><%= escapeHtml(formatBytes(spaceSaved)) %></td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= escapeHtml(status) %>
                            </span>
                        </td>
                        <td><%= scannedAt == null ? "N/A" : escapeHtml(scannedAt.toString()) %></td>
                        <td>
                            <a class="view-btn"
                               href="<%= request.getContextPath() %>/scan-details.jsp?scanId=<%= scanId %>">
                                View Details
                            </a>
                        </td>
                    </tr>
                <%
                            }

                            if (!found) {
                %>
                    <tr id="emptyHistory">
                        <td colspan="7" class="empty-message">
                            No scan history found for your account.<br><br>
                            <a class="view-btn" href="<%= request.getContextPath() %>/index.jsp">
                                Start Your First Scan
                            </a>
                        </td>
                    </tr>
                <%
                            }
                        }
                    } catch (SQLException e) {
                        application.log("Unable to load user scan history", e);
                %>
                    <tr>
                        <td colspan="7">
                            <div class="error-message">
                                Unable to load scan history. Check the database connection and Tomcat server logs.
                            </div>
                        </td>
                    </tr>
                <%
                    }
                } %>

                </tbody>
            </table>
        </div>

        <div id="noMatches" class="empty-message" style="display:none;">
            No scans match your search or selected status.
        </div>

        <a class="back-btn" href="<%= request.getContextPath() %>/dashboard.jsp">
            &#8592; Back to Dashboard
        </a>
    </section>

    <footer class="footer">DuplicateDetector &copy; 2026</footer>
</div>

<script>
(function () {
    const searchInput = document.getElementById("historySearch");
    const statusFilter = document.getElementById("statusFilter");
    const resultCount = document.getElementById("resultCount");
    const rows = Array.from(document.querySelectorAll(".history-row"));
    const noMatches = document.getElementById("noMatches");
    const emptyHistory = document.getElementById("emptyHistory");

    function filterHistory() {
        const query = searchInput.value.trim().toLowerCase();
        const selectedStatus = statusFilter.value;
        let visibleCount = 0;

        rows.forEach(function (row) {
            const searchableText =
                (row.getAttribute("data-search") || "").toLowerCase();

            const rowStatus =
                (row.getAttribute("data-status") || "").toLowerCase();

            let matchesStatus = false;

            if (selectedStatus === "all") {
                matchesStatus = true;
            } else if (selectedStatus === "completed") {
                matchesStatus = rowStatus === "completed";
            } else if (selectedStatus === "failed") {
                matchesStatus = rowStatus === "failed";
            } else {
                matchesStatus =
                    rowStatus !== "completed" && rowStatus !== "failed";
            }

            const matchesSearch = searchableText.includes(query);
            const visible = matchesSearch && matchesStatus;

            row.style.display = visible ? "" : "none";

            if (visible) {
                visibleCount++;
            }
        });

        resultCount.textContent =
            visibleCount + (visibleCount === 1 ? " scan" : " scans");

        noMatches.style.display =
            rows.length > 0 && visibleCount === 0 ? "block" : "none";

        if (emptyHistory) {
            emptyHistory.style.display =
                query === "" && selectedStatus === "all" ? "" : "none";
        }
    }

    searchInput.addEventListener("input", filterHistory);
    statusFilter.addEventListener("change", filterHistory);

    filterHistory();
})();
</script>

</body>
</html>
