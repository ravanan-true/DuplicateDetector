
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.duplicatedetector.util.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
        if (bytes < 0) bytes = 0;
        if (bytes < 1024) return bytes + " B";

        double size = bytes;
        String[] units = {"B", "KB", "MB", "GB", "TB"};
        int unit = 0;

        while (size >= 1024 && unit < units.length - 1) {
            size /= 1024.0;
            unit++;
        }

        return String.format(java.util.Locale.US, "%.2f %s", size, units[unit]);
    }
%>

<%
    response.setHeader("Cache-Control",
            "no-store, no-cache, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession currentSession = request.getSession(false);

    if (currentSession == null ||
        !(currentSession.getAttribute("userId") instanceof Number)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = ((Number) currentSession.getAttribute("userId")).intValue();

    String fullName = (String) currentSession.getAttribute("fullName");
    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "User";
    }

    long totalScans = 0;
    long totalFiles = 0;
    long totalDuplicates = 0;
    long totalSpaceSaved = 0;

    boolean databaseError = false;

    String statsSql =
        "SELECT COUNT(*) AS total_scans, " +
        "COALESCE(SUM(total_files), 0) AS total_files, " +
        "COALESCE(SUM(duplicate_count), 0) AS total_duplicates, " +
        "COALESCE(SUM(potential_space_saved), 0) AS total_space_saved " +
        "FROM scan_history WHERE user_id = ?";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(statsSql)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalScans = rs.getLong("total_scans");
                totalFiles = rs.getLong("total_files");
                totalDuplicates = rs.getLong("total_duplicates");
                totalSpaceSaved = rs.getLong("total_space_saved");
            }
        }
    } catch (SQLException e) {
        databaseError = true;
        application.log("Dashboard statistics error", e);
    }

    // Prepare the last 7 calendar days, including days with zero scans.
    String[] chartLabels = new String[7];
    long[] chartValues = new long[7];
    String[] chartDates = new String[7];

    Calendar calendar = Calendar.getInstance();
    calendar.set(Calendar.HOUR_OF_DAY, 0);
    calendar.set(Calendar.MINUTE, 0);
    calendar.set(Calendar.SECOND, 0);
    calendar.set(Calendar.MILLISECOND, 0);
    calendar.add(Calendar.DAY_OF_MONTH, -6);

    SimpleDateFormat dateKeyFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat chartLabelFormat = new SimpleDateFormat("dd MMM");

    Map<String, Long> scansByDate = new HashMap<String, Long>();

    String chartSql =
        "SELECT DATE(scanned_at) AS scan_date, COUNT(*) AS scan_count " +
        "FROM scan_history WHERE user_id = ? " +
        "AND scanned_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
        "AND scanned_at < DATE_ADD(CURDATE(), INTERVAL 1 DAY) " +
        "GROUP BY DATE(scanned_at)";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(chartSql)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
            	java.sql.Date scanDate = rs.getDate("scan_date");
                if (scanDate != null) {
                    scansByDate.put(
                        dateKeyFormat.format(scanDate),
                        rs.getLong("scan_count")
                    );
                }
            }
        }
    } catch (SQLException e) {
        databaseError = true;
        application.log("Dashboard chart error", e);
    }

    long maxDailyScans = 0;

    for (int i = 0; i < 7; i++) {
    	java.util.Date day = calendar.getTime();
        chartDates[i] = dateKeyFormat.format(day);
        chartLabels[i] = chartLabelFormat.format(day);
        chartValues[i] = scansByDate.containsKey(chartDates[i])
            ? scansByDate.get(chartDates[i]) : 0;

        if (chartValues[i] > maxDailyScans) {
            maxDailyScans = chartValues[i];
        }

        calendar.add(Calendar.DAY_OF_MONTH, 1);
    }

    if (maxDailyScans == 0) maxDailyScans = 1;

    double duplicateRate = totalFiles > 0
        ? (totalDuplicates * 100.0 / totalFiles) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard | DuplicateDetector</title>

<style>
:root {
    --bg: #080d1b;
    --panel: #111a2e;
    --panel-light: #16223a;
    --border: rgba(148, 163, 184, .14);
    --text: #f1f5ff;
    --muted: #94a3bd;
    --blue: #60a5fa;
    --purple: #a78bfa;
    --green: #34d399;
    --red: #fb7185;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Inter, "Segoe UI", Arial, sans-serif;
    background:
        radial-gradient(ellipse at 10% 0%, rgba(37, 99, 235, .15), transparent 35%),
        radial-gradient(ellipse at 90% 10%, rgba(124, 58, 237, .10), transparent 32%),
        var(--bg);
    color: var(--text);
    min-height: 100vh;
}

a { color: inherit; }

.navbar {
    min-height: 76px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    flex-wrap: wrap;
    padding: 16px 5%;
    background: rgba(8, 13, 27, .88);
    border-bottom: 1px solid var(--border);
}

.brand {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 19px;
    font-weight: 800;
    letter-spacing: -.5px;
}

.brand-icon {
    width: 39px;
    height: 39px;
    display: grid;
    place-items: center;
    border-radius: 12px;
    color: white;
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    box-shadow: 0 5px 22px rgba(59, 130, 246, .24);
}

.brand span:last-child { color: var(--blue); }

.nav-links {
    display: flex;
    align-items: center;
    gap: 9px;
    flex-wrap: wrap;
}

.nav-links a {
    color: var(--muted);
    text-decoration: none;
    font-size: 13px;
    padding: 10px 13px;
    border-radius: 9px;
    transition: .2s ease;
}

.nav-links a:hover,
.nav-links a.active {
    color: white;
    background: rgba(96, 165, 250, .12);
}

.logout-form { margin: 0; }

.logout-btn {
    padding: 10px 15px;
    color: #fecdd3;
    border: 1px solid rgba(251, 113, 133, .28);
    background: rgba(251, 113, 133, .06);
    border-radius: 10px;
    cursor: pointer;
    transition: .2s ease;
}

.logout-btn:hover { background: rgba(225, 29, 72, .2); }

.container {
    width: 90%;
    max-width: 1350px;
    margin: 38px auto;
}

.eyebrow {
    color: var(--blue);
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 2px;
    margin-bottom: 12px;
}

.welcome {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 20px;
    flex-wrap: wrap;
    margin-bottom: 29px;
}

.welcome h1 {
    font-size: clamp(26px, 3vw, 36px);
    letter-spacing: -1.2px;
    margin: 0 0 10px;
    line-height: 1.2;
}

.welcome h1 span {
    background: linear-gradient(90deg, #93c5fd, #c4b5fd);
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
}

.welcome p {
    margin: 0;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}

.primary-btn, .secondary-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-decoration: none;
    border-radius: 10px;
    padding: 12px 16px;
    font-size: 13px;
    font-weight: 700;
    transition: transform .2s, box-shadow .2s, background .2s;
}

.primary-btn {
    color: white;
    background: linear-gradient(110deg, #2563eb, #6366f1);
    box-shadow: 0 7px 20px rgba(37, 99, 235, .22);
    border: 0;
}

.primary-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(37, 99, 235, .3);
}

.secondary-btn {
    background: rgba(148, 163, 184, .07);
    color: #dbeafe;
    border: 1px solid var(--border);
}

.secondary-btn:hover { background: rgba(148, 163, 184, .13); }

.error {
    padding: 14px 16px;
    color: #fecdd3;
    background: rgba(225, 29, 72, .12);
    border: 1px solid rgba(251, 113, 133, .25);
    border-radius: 12px;
    margin-bottom: 22px;
    font-size: 13px;
}

.stats {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 17px;
    margin-bottom: 24px;
}

.stat-card {
    position: relative;
    overflow: hidden;
    padding: 22px;
    background: linear-gradient(145deg, rgba(22, 34, 58, .98), rgba(15, 24, 42, .98));
    border: 1px solid var(--border);
    border-radius: 17px;
    min-width: 0;
    transition: transform .22s, border-color .22s, box-shadow .22s;
    animation: rise .5s ease both;
}

.stat-card:nth-child(2) { animation-delay: .06s; }
.stat-card:nth-child(3) { animation-delay: .12s; }
.stat-card:nth-child(4) { animation-delay: .18s; }

.stat-card:hover {
    transform: translateY(-4px);
    border-color: rgba(96, 165, 250, .38);
    box-shadow: 0 12px 30px rgba(0, 0, 0, .15);
}

.stat-card::after {
    content: "";
    position: absolute;
    width: 105px;
    height: 105px;
    border-radius: 50%;
    right: -40px;
    top: -45px;
    background: var(--glow, rgba(96, 165, 250, .13));
    filter: blur(2px);
}

.stat-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 22px;
}

.stat-label { color: var(--muted); font-size: 13px; }

.stat-icon {
    width: 39px;
    height: 39px;
    border-radius: 12px;
    display: grid;
    place-items: center;
    font-size: 18px;
    background: var(--icon-bg, rgba(96, 165, 250, .13));
    color: var(--icon-color, #93c5fd);
}

.stat-number {
    margin: 0;
    font-size: clamp(24px, 2.3vw, 32px);
    font-weight: 800;
    letter-spacing: -1px;
    overflow-wrap: anywhere;
}

.stat-foot {
    color: #8291ac;
    font-size: 11px;
    margin-top: 10px;
}

.content-grid {
    display: grid;
    grid-template-columns: minmax(0, 1.1fr) minmax(0, .9fr);
    gap: 20px;
    margin-bottom: 22px;
}

.panel {
    min-width: 0;
    padding: 24px;
    background: linear-gradient(145deg, rgba(17, 26, 46, .98), rgba(13, 21, 38, .98));
    border: 1px solid var(--border);
    border-radius: 17px;
    box-shadow: 0 10px 35px rgba(0, 0, 0, .08);
}

.panel-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 24px;
}

.panel-header h2 {
    font-size: 16px;
    margin: 0 0 7px;
    letter-spacing: -.3px;
}

.panel-header p {
    font-size: 12px;
    color: var(--muted);
    margin: 0;
}

.pill {
    color: #bfdbfe;
    background: rgba(59, 130, 246, .12);
    border: 1px solid rgba(96, 165, 250, .17);
    border-radius: 20px;
    padding: 7px 10px;
    font-size: 11px;
}

.chart {
    height: 205px;
    display: flex;
    align-items: stretch;
    gap: clamp(7px, 2vw, 17px);
    padding-top: 5px;
}

.chart-column {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 9px;
}

.bar-area {
    height: 165px;
    width: 100%;
    display: flex;
    align-items: flex-end;
    justify-content: center;
    border-bottom: 1px solid var(--border);
    background: repeating-linear-gradient(
        to top,
        transparent 0,
        transparent 40px,
        rgba(148, 163, 184, .055) 41px,
        transparent 42px
    );
}

.bar {
    position: relative;
    width: min(33px, 72%);
    min-height: 4px;
    border-radius: 7px 7px 2px 2px;
    background: linear-gradient(180deg, #818cf8 0%, #3b82f6 100%);
    box-shadow: 0 0 17px rgba(59, 130, 246, .13);
    transition: height .45s ease, filter .2s;
}

.bar:hover { filter: brightness(1.25); }

.bar-value {
    position: absolute;
    top: -23px;
    left: 50%;
    transform: translateX(-50%);
    color: #cbd5e1;
    font-size: 10px;
    white-space: nowrap;
}

.chart-day {
    color: var(--muted);
    font-size: 10px;
    white-space: nowrap;
}

.chart-note {
    margin-top: 18px;
    color: var(--muted);
    font-size: 12px;
}

.chart-note strong { color: #c4b5fd; }

.insight {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 18px;
    margin-bottom: 14px;
    border-radius: 13px;
    background: rgba(96, 165, 250, .07);
    border: 1px solid rgba(96, 165, 250, .13);
}

.insight-icon {
    width: 45px;
    height: 45px;
    flex-shrink: 0;
    display: grid;
    place-items: center;
    border-radius: 13px;
    background: rgba(96, 165, 250, .13);
    font-size: 21px;
}

.insight-label { color: var(--muted); font-size: 12px; margin-bottom: 6px; }

.insight-value {
    font-size: 23px;
    font-weight: 800;
    overflow-wrap: anywhere;
}

.progress-track {
    height: 7px;
    overflow: hidden;
    background: #26334c;
    border-radius: 20px;
    margin-top: 12px;
}

.progress-fill {
    height: 100%;
    border-radius: inherit;
    background: linear-gradient(90deg, #3b82f6, #a78bfa);
}

.insight-copy {
    color: var(--muted);
    font-size: 12px;
    line-height: 1.8;
    margin: 13px 0 0;
}

.actions {
    display: flex;
    flex-wrap: wrap;
    gap: 11px;
}

.table-panel { padding: 0; overflow: hidden; }

.table-panel .panel-header { padding: 24px 24px 0; }

.table-wrap { width: 100%; overflow-x: auto; }

table {
    width: 100%;
    min-width: 650px;
    border-collapse: collapse;
}

th, td {
    text-align: left;
    padding: 15px 22px;
    border-bottom: 1px solid var(--border);
    font-size: 12px;
    white-space: nowrap;
}

th {
    background: rgba(148, 163, 184, .045);
    color: #9eacc5;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .8px;
    text-transform: uppercase;
}

td { color: #dbe5f5; }

tbody tr { transition: background .2s; }
tbody tr:hover { background: rgba(96, 165, 250, .045); }
tbody tr:last-child td { border-bottom: 0; }

.scan-id { color: #93c5fd; font-weight: 800; }

.status {
    display: inline-flex;
    padding: 6px 9px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: 700;
    background: rgba(52, 211, 153, .1);
    color: #6ee7b7;
    border: 1px solid rgba(52, 211, 153, .15);
}

.status.failed, .status.error {
    background: rgba(251, 113, 133, .1);
    color: #fda4af;
}

.status.pending, .status.processing {
    background: rgba(251, 191, 36, .1);
    color: #fcd34d;
}

.details-link {
    color: #93c5fd;
    text-decoration: none;
    font-weight: 700;
}

.details-link:hover { color: white; }

.empty {
    text-align: center;
    padding: 35px 20px;
    color: var(--muted);
    white-space: normal;
}

.empty a { color: #93c5fd; }

.footer {
    text-align: center;
    padding: 24px;
    color: #66748e;
    font-size: 11px;
    border-top: 1px solid rgba(148, 163, 184, .08);
}

@keyframes rise {
    from { opacity: 0; transform: translateY(9px); }
    to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 1050px) {
    .stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .content-grid { grid-template-columns: 1fr; }
}

@media (max-width: 620px) {
    .navbar { padding: 15px 4%; }
    .brand { font-size: 17px; }
    .nav-links { width: 100%; gap: 3px; }
    .nav-links a { padding: 9px; font-size: 12px; }
    .logout-btn { padding: 9px 11px; font-size: 12px; }
    .container { width: 92%; margin: 26px auto; }
    .welcome h1 { font-size: 27px; }
    .welcome .primary-btn { width: 100%; }
    .stats { gap: 11px; }
    .stat-card { padding: 15px; border-radius: 14px; }
    .stat-top { margin-bottom: 17px; }
    .stat-icon { width: 33px; height: 33px; }
    .stat-label { font-size: 11px; }
    .stat-number { font-size: 23px; }
    .panel { padding: 17px; }
    .table-panel { padding: 0; }
    .table-panel .panel-header { padding: 19px 17px 0; }
    .chart { gap: 6px; }
    .chart-day { font-size: 9px; }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: .01ms !important;
        transition-duration: .01ms !important;
    }
}
</style>
</head>

<body>

<%@ include file="/navbar.jsp" %>

<main class="container">

    <section class="welcome">
        <div>
            <div class="eyebrow">Workspace overview</div>
            <h1>Welcome back, <span><%= escapeHtml(fullName) %></span></h1>
            <p>Your file intelligence at a glance. Track scans, duplicates and storage savings.</p>
        </div>

        <a class="primary-btn" href="<%= request.getContextPath() %>/index.jsp">
            <span>＋</span> Start New Scan
        </a>
    </section>

    <% if (databaseError) { %>
        <div class="error">
            Some dashboard data could not be loaded. Check the database connection and Tomcat logs.
        </div>
    <% } %>

    <section class="stats">

        <div class="stat-card" style="--glow:rgba(96,165,250,.15)">
            <div class="stat-top">
                <span class="stat-label">Total Scans</span>
                <div class="stat-icon">⌕</div>
            </div>
            <h2 class="stat-number"><%= String.format("%,d", totalScans) %></h2>
            <div class="stat-foot">All scans in your account</div>
        </div>

        <div class="stat-card"
             style="--glow:rgba(52,211,153,.13);--icon-bg:rgba(52,211,153,.12);--icon-color:#6ee7b7">
            <div class="stat-top">
                <span class="stat-label">Files Scanned</span>
                <div class="stat-icon">▤</div>
            </div>
            <h2 class="stat-number"><%= String.format("%,d", totalFiles) %></h2>
            <div class="stat-foot">Files processed across your scans</div>
        </div>

        <div class="stat-card"
             style="--glow:rgba(251,113,133,.13);--icon-bg:rgba(251,113,133,.12);--icon-color:#fda4af">
            <div class="stat-top">
                <span class="stat-label">Duplicate Copies</span>
                <div class="stat-icon">⧉</div>
            </div>
            <h2 class="stat-number"><%= String.format("%,d", totalDuplicates) %></h2>
            <div class="stat-foot">Additional copies identified</div>
        </div>

        <div class="stat-card"
             style="--glow:rgba(167,139,250,.15);--icon-bg:rgba(167,139,250,.12);--icon-color:#c4b5fd">
            <div class="stat-top">
                <span class="stat-label">Potential Savings</span>
                <div class="stat-icon">↗</div>
            </div>
            <h2 class="stat-number"><%= formatBytes(totalSpaceSaved) %></h2>
            <div class="stat-foot">Estimated duplicate storage</div>
        </div>

    </section>

    <section class="content-grid">

        <div class="panel">
            <div class="panel-header">
                <div>
                    <h2>Scan Activity</h2>
                    <p>Your scanning activity over the last 7 days</p>
                </div>
                <span class="pill">Last 7 days</span>
            </div>

            <div class="chart">
                <% for (int i = 0; i < 7; i++) {
                    int barHeight = (int) Math.round(
                        (chartValues[i] * 100.0) / maxDailyScans
                    );
                    if (barHeight < 4) barHeight = 4;
                %>
                    <div class="chart-column">
                        <div class="bar-area">
                            <div class="bar"
                                 style="height:<%= barHeight %>%"
                                 title="<%= chartValues[i] %> scan(s) on <%= chartDates[i] %>">
                                <span class="bar-value"><%= chartValues[i] %></span>
                            </div>
                        </div>
                        <span class="chart-day"><%= chartLabels[i] %></span>
                    </div>
                <% } %>
            </div>

            <div class="chart-note">
                Total scans: <strong><%= String.format("%,d", Arrays.stream(chartValues).sum()) %></strong>
                during this period
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div>
                    <h2>Storage Insights</h2>
                    <p>A quick look at your duplicate detection results</p>
                </div>
                <span class="pill">Overview</span>
            </div>

            <div class="insight">
                <div class="insight-icon">◈</div>
                <div>
                    <div class="insight-label">Duplicate copies / files scanned</div>
                    <div class="insight-value"><%= String.format(java.util.Locale.US, "%.1f%%", duplicateRate) %></div>
                </div>
            </div>

            <div class="progress-track">
                <div class="progress-fill"
                     style="width:<%= Math.min(100.0, duplicateRate) %>%"></div>
            </div>

            <p class="insight-copy">
                <strong><%= formatBytes(totalSpaceSaved) %></strong> potential storage savings recorded across
                <strong><%= String.format("%,d", totalScans) %></strong> scans.
                Savings are estimates based on your recorded scan results.
            </p>

            <div class="actions">
                <a class="primary-btn" href="<%= request.getContextPath() %>/index.jsp">Scan Files</a>
                <a class="secondary-btn" href="<%= request.getContextPath() %>/scan-history.jsp">View History →</a>
            </div>
        </div>

    </section>

    <section class="panel table-panel">
        <div class="panel-header">
            <div>
                <h2>Recent Scans</h2>
                <p>Your latest scan activity and reports</p>
            </div>
            <a class="secondary-btn" href="<%= request.getContextPath() %>/scan-history.jsp">
                All scans →
            </a>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Scan ID</th>
                        <th>Total Files</th>
                        <th>Duplicates</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Report</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    String recentSql =
                        "SELECT scan_id, total_files, duplicate_count, " +
                        "scan_status, scanned_at FROM scan_history " +
                        "WHERE user_id = ? ORDER BY scan_id DESC LIMIT 5";

                    try (Connection con = DBConnection.getConnection();
                         PreparedStatement ps = con.prepareStatement(recentSql)) {

                        ps.setInt(1, userId);

                        try (ResultSet rs = ps.executeQuery()) {
                            boolean found = false;

                            while (rs.next()) {
                                found = true;
                                int scanId = rs.getInt("scan_id");
                                String status = rs.getString("scan_status");
                                if (status == null || status.trim().isEmpty()) {
                                    status = "Unknown";
                                }

                                String statusClass = status.toLowerCase(java.util.Locale.ROOT);
                                if (!statusClass.matches("[a-z_-]+")) {
                                    statusClass = "";
                                }
                %>
                    <tr>
                        <td class="scan-id">#<%= scanId %></td>
                        <td><%= String.format("%,d", rs.getLong("total_files")) %></td>
                        <td><%= String.format("%,d", rs.getLong("duplicate_count")) %></td>
                        <td>
                            <span class="status <%= escapeHtml(statusClass) %>">
                                <%= escapeHtml(status) %>
                            </span>
                        </td>
                        <td>
                            <%
                                Timestamp scannedAt = rs.getTimestamp("scanned_at");
                                out.print(scannedAt == null
                                    ? "N/A"
                                    : new SimpleDateFormat("dd MMM yyyy, hh:mm a")
                                        .format(scannedAt));
                            %>
                        </td>
                        <td>
                            <a class="details-link"
                               href="<%= request.getContextPath() %>/scan-details.jsp?scanId=<%= scanId %>">
                                View Details →
                            </a>
                        </td>
                    </tr>
                <%
                            }

                            if (!found) {
                %>
                    <tr>
                        <td colspan="6" class="empty">
                            No scans available yet. <a href="<%= request.getContextPath() %>/index.jsp">Start your first scan →</a>
                        </td>
                    </tr>
                <%
                            }
                        }
                    } catch (SQLException e) {
                        application.log("Recent scans loading error", e);
                %>
                    <tr>
                        <td colspan="6" class="empty">
                            Recent scans could not be loaded. Check the Tomcat logs.
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </section>

    <section style="margin:28px 0;padding:22px;border:1px solid #293853;border-radius:14px;background:#10182b;">
        <h2 style="margin-top:0;">Account Status Request</h2>
        <p style="color:#94a3b8;">Need to deactivate your account? Send a request to the administrator. Your account status will change only after admin approval.</p>
        <% String accountRequestMessage = request.getParameter("request"); %>
        <% if ("sent".equals(accountRequestMessage)) { %><p style="color:#86efac;">Your request was sent to the administrator.</p><% } else if ("pending".equals(accountRequestMessage)) { %><p style="color:#fcd34d;">You already have a pending account request.</p><% } else if ("error".equals(accountRequestMessage)) { %><p style="color:#fca5a5;">Could not submit your request. Please try again.</p><% } %>
        <form method="post" action="<%= request.getContextPath() %>/account-request" onsubmit="return confirm('Send a request to deactivate your account?');">
            <input type="hidden" name="action" value="DEACTIVATE">
            <button type="submit" style="padding:11px 16px;border:0;border-radius:8px;background:#7f1d35;color:#fff;cursor:pointer;">Request Account Deactivation</button>
        </form>
    </section>
</main>

<footer class="footer">
    DuplicateDetector © 2026 · Smart file analysis
</footer>

</body>
</html>
