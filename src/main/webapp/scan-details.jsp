<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.duplicatedetector.util.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    if (session.getAttribute("userId") == null ||
        !(session.getAttribute("userId") instanceof Number)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = ((Number) session.getAttribute("userId")).intValue();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scan Details | DuplicateDetector</title>

    
	<style>
			
		* {
		    box-sizing: border-box;
		}
		
		:root {
		    color-scheme: dark;
		    --bg: #080d1a;
		    --surface: #111a2d;
		    --surface-light: #17233b;
		    --border: rgba(148, 163, 184, 0.16);
		    --text: #e8eefc;
		    --muted: #93a4c3;
		    --blue: #6595ff;
		    --purple: #a78bfa;
		    --green: #4ade80;
		    --pink: #fb7185;
		}
		
		body {
		    margin: 0;
		    padding: 30px 20px;
		    min-height: 100vh;
		    font-family: "Segoe UI", Arial, sans-serif;
		    background:
		        radial-gradient(ellipse at 10% 0%, rgba(59, 130, 246, .15), transparent 38%),
		        radial-gradient(ellipse at 95% 10%, rgba(139, 92, 246, .12), transparent 32%),
		        var(--bg);
		    color: var(--text);
		}
		
		.container {
		    width: 100%;
		    max-width: 1240px;
		    margin: 0 auto;
		}
		
		.header {
		    margin-bottom: 26px;
		}
		
		.header h1 {
		    margin: 0 0 8px;
		    font-size: clamp(26px, 4vw, 36px);
		    font-weight: 800;
		    letter-spacing: -1px;
		    color: #f8faff;
		}
		
		.header p {
		    color: var(--muted);
		    line-height: 1.7;
		    margin: 0;
		}
		
		.card {
		    padding: 28px;
		    overflow: hidden;
		    border: 1px solid var(--border);
		    border-radius: 20px;
		    background: linear-gradient(145deg, rgba(20, 31, 53, .97), rgba(12, 19, 34, .98));
		    box-shadow: 0 24px 70px rgba(0, 0, 0, .28);
		}
		
		h2 {
		    margin: 0 0 8px;
		    color: #f0f5ff;
		    font-size: 23px;
		}
		
		.summary {
		    display: grid;
		    grid-template-columns: repeat(3, minmax(0, 1fr));
		    gap: 16px;
		    margin: 24px 0;
		}
		
		.summary-item {
		    position: relative;
		    overflow: hidden;
		    padding: 22px;
		    border: 1px solid var(--border);
		    border-radius: 15px;
		    background: linear-gradient(135deg, #182844, #111b30);
		    transition: transform .2s ease, border-color .2s ease;
		}
		
		.summary-item:hover {
		    transform: translateY(-3px);
		    border-color: rgba(101, 149, 255, .55);
		}
		
		.summary-item span {
		    display: block;
		    margin-bottom: 12px;
		    color: var(--muted);
		    font-size: 13px;
		}
		
		.summary-item strong {
		    display: block;
		    color: var(--blue);
		    font-size: clamp(23px, 3vw, 30px);
		    overflow-wrap: anywhere;
		}
		
		.message {
		    padding: 15px 17px;
		    border: 1px solid rgba(101, 149, 255, .22);
		    border-radius: 12px;
		    background: rgba(59, 130, 246, .09);
		    color: #c7d9ff;
		    font-size: 13px;
		    line-height: 1.8;
		}
		
		.toolbar {
		    display: flex;
		    flex-wrap: wrap;
		    align-items: center;
		    gap: 12px;
		    margin: 24px 0;
		}
		
		.toolbar input,
		.toolbar select {
		    flex: 1 1 200px;
		    min-width: 0;
		    padding: 13px 15px;
		    border: 1px solid var(--border);
		    border-radius: 11px;
		    outline: none;
		    background: #0b1426;
		    color: var(--text);
		    font-size: 14px;
		    transition: border-color .2s, box-shadow .2s;
		}
		
		.toolbar input:focus,
		.toolbar select:focus {
		    border-color: var(--blue);
		    box-shadow: 0 0 0 3px rgba(101, 149, 255, .13);
		}
		
		.toolbar input::placeholder {
		    color: #7183a5;
		}
		
		.btn {
		    display: inline-flex;
		    align-items: center;
		    justify-content: center;
		    gap: 8px;
		    padding: 12px 17px;
		    border: 1px solid transparent;
		    border-radius: 11px;
		    background: linear-gradient(135deg, #477ff5, #7659e8);
		    color: white;
		    text-decoration: none;
		    font-size: 13px;
		    font-weight: 700;
		    cursor: pointer;
		    transition: transform .2s, filter .2s;
		}
		
		.btn:hover {
		    transform: translateY(-2px);
		    filter: brightness(1.12);
		}
		
		.btn-secondary {
		    border-color: var(--border);
		    background: #1b2942;
		    color: #dce7ff;
		}
		
		.btn-secondary:hover {
		    background: #263958;
		}
		
		.table-wrapper {
		    width: 100%;
		    overflow-x: auto;
		    border: 1px solid var(--border);
		    border-radius: 14px;
		}
		
		table {
		    width: 100%;
		    min-width: 760px;
		    margin: 0;
		    border-collapse: collapse;
		}
		
		th,
		td {
		    padding: 16px 14px;
		    border-bottom: 1px solid var(--border);
		    text-align: left;
		    vertical-align: top;
		}
		
		th {
		    background: #182640;
		    color: #b8cbf5;
		    font-size: 11px;
		    font-weight: 800;
		    letter-spacing: .8px;
		    text-transform: uppercase;
		    white-space: nowrap;
		}
		
		td {
		    color: #dce5f7;
		    font-size: 13px;
		    line-height: 1.7;
		}
		
		tbody tr {
		    transition: background .2s;
		}
		
		tbody tr:hover {
		    filter: brightness(1.16);
		}
		
		tbody tr:last-child td {
		    border-bottom: none;
		}
		
		.original-row {
		    background: rgba(34, 197, 94, .065);
		}
		
		.duplicate-row {
		    background: rgba(244, 63, 94, .075);
		}
		
		.unique-row {
		    background: rgba(148, 163, 184, .025);
		}
		
		.hash {
		    min-width: 220px;
		    max-width: 350px;
		    font-family: Consolas, monospace;
		    font-size: 11px;
		    color: #a9bce0;
		    overflow-wrap: anywhere;
		    word-break: break-word;
		}
		
		.badge {
		    display: inline-block;
		    padding: 6px 10px;
		    border: 1px solid transparent;
		    border-radius: 999px;
		    font-size: 11px;
		    font-weight: 800;
		    white-space: nowrap;
		}
		
		.original-badge {
		    background: rgba(34, 197, 94, .13);
		    border-color: rgba(74, 222, 128, .24);
		    color: var(--green);
		}
		
		.duplicate-badge {
		    background: rgba(244, 63, 94, .13);
		    border-color: rgba(251, 113, 133, .24);
		    color: var(--pink);
		}
		
		.unique-badge {
		    background: rgba(148, 163, 184, .12);
		    border-color: rgba(148, 163, 184, .2);
		    color: #cbd5e1;
		}
		
		.error {
		    padding: 16px;
		    border: 1px solid rgba(251, 113, 133, .3);
		    border-radius: 12px;
		    background: rgba(244, 63, 94, .1);
		    color: #fda4af;
		    line-height: 1.7;
		}
		
		.empty-message {
		    padding: 32px;
		    text-align: center;
		    color: var(--muted);
		}
		
		.footer {
		    margin-top: 25px;
		    text-align: center;
		    color: #7183a5;
		    font-size: 12px;
		}
		
		@media (max-width: 700px) {
		    body {
		        padding: 18px 10px;
		    }
		
		    .card {
		        padding: 17px 13px;
		        border-radius: 15px;
		    }
		
		    .summary {
		        grid-template-columns: 1fr;
		        gap: 11px;
		    }
		
		    .summary-item {
		        padding: 17px;
		    }
		
		    .toolbar {
		        flex-direction: column;
		        align-items: stretch;
		    }
		
		    .toolbar input,
		    .toolbar select,
		    .toolbar button {
		        width: 100%;
		        flex: auto;
		    }
		
		    .table-wrapper {
		        border-radius: 10px;
		    }
		
		    th,
		    td {
		        padding: 12px 10px;
		    }
		}
		
		@media (prefers-reduced-motion: reduce) {
		    *,
		    *::before,
		    *::after {
		        scroll-behavior: auto !important;
		        transition: none !important;
		        animation: none !important;
		    }
		}
	</style>

</head>

<body>
<%@ include file="/navbar.jsp" %>

<div class="container">

    <div class="header">
        <h1>DuplicateDetector</h1>
        <p>Analyze scanned files and identify duplicate content.</p>
    </div>

    <div class="card">

        <h2>Scan File Details</h2>

        <%
            String scanIdParam = request.getParameter("scanId");
            int scanId = -1;

            try {
                scanId = Integer.parseInt(scanIdParam);
            } catch (Exception e) {
                scanId = -1;
            }

            if (scanId <= 0) {
        %>

            <p class="error">
                Invalid scan ID. Please open this page using View Details
                from Scan History.
            </p>

        <%
            } else {

            	String sql =
            		    "SELECT sf.file_id, sf.file_name, sf.file_size, sf.sha256_hash " +
            		    "FROM scanned_files sf " +
            		    "INNER JOIN scan_history sh ON sf.scan_id = sh.scan_id " +
            		    "WHERE sf.scan_id = ? AND sh.user_id = ? " +
            		    "ORDER BY sf.file_id";
            	
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                	ps.setInt(1, scanId);
                	ps.setInt(2, userId);

                    try (ResultSet rs = ps.executeQuery()) {

                        List<Map<String, Object>> files = new ArrayList<>();
                        Map<String, Integer> hashCounts = new HashMap<>();

                        while (rs.next()) {

                            Map<String, Object> file = new HashMap<>();

                            String hash = rs.getString("sha256_hash");

                            file.put("fileId", rs.getLong("file_id"));
                            file.put("fileName", rs.getString("file_name"));
                            file.put("fileSize", rs.getLong("file_size"));
                            file.put("hash", hash);

                            files.add(file);

                            if (hash != null) {
                                hashCounts.put(
                                    hash,
                                    hashCounts.getOrDefault(hash, 0) + 1
                                );
                            }
                        }

                        Map<String, Boolean> originalSeen = new HashMap<>();

                        int duplicateCount = 0;
                        long duplicateBytes = 0;

                        for (Map<String, Object> file : files) {

                            String hash = (String) file.get("hash");

                            if (hash != null &&
                                hashCounts.getOrDefault(hash, 0) > 1) {

                                if (originalSeen.containsKey(hash)) {
                                    duplicateCount++;
                                    duplicateBytes += (Long) file.get("fileSize");
                                } else {
                                    originalSeen.put(hash, true);
                                }
                            }
                        }

                        originalSeen.clear();
        %>

        <div class="summary">

            <div class="summary-item">
                <span>Scan ID</span>
                <strong>#<%= scanId %></strong>
            </div>

            <div class="summary-item">
                <span>Total Files</span>
                <strong><%= files.size() %></strong>
            </div>

            <div class="summary-item">
                <span>Additional Duplicate Copies</span>
                <strong><%= duplicateCount %></strong>
            </div>

        </div>

        <p class="message">
            Green = Original Copy | Pink = Duplicate | White = Unique File.
            Duplicate identification is based on matching SHA-256 hashes.
        </p>

        <div class="toolbar">

            <input
                type="search"
                id="fileSearch"
                placeholder="Search file name..."
                aria-label="Search file name">

            <select id="fileFilter" aria-label="Filter files">
                <option value="all">All Files</option>
                <option value="duplicate">Duplicate Files</option>
                <option value="original">Original Copies</option>
                <option value="unique">Unique Files</option>
            </select>

            <button type="button" class="btn" onclick="downloadCSV()">
                Download CSV Report
            </button>

        </div>

        <div class="table-wrapper">

            <table id="filesTable">

                <thead>
                    <tr>
                        <th>File Name</th>
                        <th>File Size</th>
                        <th>SHA-256 Hash</th>
                        <th>Classification</th>
                    </tr>
                </thead>

                <tbody>

                <%
                    for (Map<String, Object> file : files) {

                        String fileName = (String) file.get("fileName");
                        Long fileSize = (Long) file.get("fileSize");
                        String hash = (String) file.get("hash");

                        boolean duplicateGroup = hash != null &&
                            hashCounts.getOrDefault(hash, 0) > 1;

                        boolean isOriginal = false;
                        String type;
                        String label;
                        String rowClass;
                        String badgeClass;

                        if (duplicateGroup) {

                            isOriginal = !originalSeen.containsKey(hash);
                            originalSeen.put(hash, true);

                            if (isOriginal) {
                                type = "original";
                                label = "Original Copy";
                                rowClass = "original-row";
                                badgeClass = "original-badge";
                            } else {
                                type = "duplicate";
                                label = "Duplicate";
                                rowClass = "duplicate-row";
                                badgeClass = "duplicate-badge";
                            }

                        } else {

                            type = "unique";
                            label = "Unique File";
                            rowClass = "unique-row";
                            badgeClass = "unique-badge";
                        }
                %>

                    <tr class="<%= rowClass %>" data-type="<%= type %>">

                        <td>
                            <%= fileName == null ? "" : fileName %>
                        </td>

                        <td>
                            <%= String.format("%,d", fileSize) %> bytes
                        </td>

                        <td class="hash">
                            <%= hash == null ? "N/A" : hash %>
                        </td>

                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= label %>
                            </span>
                        </td>

                    </tr>

                <%
                    }

                    if (files.isEmpty()) {
                %>

                    <tr>
                        <td colspan="4" class="empty-message">
                            No files found for this scan.
                        </td>
                    </tr>

                <%
                    }
                %>

                </tbody>

            </table>

        </div>

        <p>
            <strong>Potential duplicate space:</strong>
            <%= String.format("%,d", duplicateBytes) %> bytes
        </p>

        <%
                    }

                } catch (SQLException e) {

                    application.log(
                        "Unable to load DuplicateDetector scan details",
                        e
                    );
        %>

            <p class="error">
                Unable to load scan details. Please check the Tomcat
                console for the database error.
            </p>

        <%
                }
            }
        %>

        <a class="btn btn-secondary"
           href="<%= request.getContextPath() %>/scan-history.jsp">
            &larr; Back to Scan History
        </a>

        <a class="btn"
           href="<%= request.getContextPath() %>/index.jsp">
            Back to Scanner
        </a>

    </div>

    <div class="footer">
        DuplicateDetector &copy; 2026
    </div>

</div>

<script>
    const fileSearch = document.getElementById("fileSearch");
    const fileFilter = document.getElementById("fileFilter");

    function filterFiles() {

        const searchText = fileSearch.value.toLowerCase().trim();
        const filterType = fileFilter.value;

        document.querySelectorAll("#filesTable tbody tr").forEach(row => {

            const fileName =
                row.cells[0]?.textContent.toLowerCase() || "";

            const type = row.dataset.type || "";

            const matchesName = fileName.includes(searchText);

            const matchesType =
                filterType === "all" || type === filterType;

            row.hidden = !(matchesName && matchesType);
        });
    }

    fileSearch.addEventListener("input", filterFiles);
    fileFilter.addEventListener("change", filterFiles);

    function downloadCSV() {

        const table = document.getElementById("filesTable");

        // Export every file row, including rows hidden by the filter.
        const header = [...table.querySelectorAll("thead tr")];
        const rows = [...table.querySelectorAll("tbody tr")]
            .filter(row => row.cells.length === 4);

        const csvRows = [...header, ...rows];

        const csv = csvRows.map(row => {

            return [...row.cells].map((cell, index) => {

                let value = cell.innerText.trim();

                // Prevent spreadsheet formula injection in text fields.
                if (index === 0 && /^[=+\-@\t\r]/.test(value)) {
                    value = "'" + value;
                }

                return '"' + value.replace(/"/g, '""') + '"';

            }).join(",");

        }).join("\r\n");

        const blob = new Blob(["\uFEFF" + csv], {
            type: "text/csv;charset=utf-8;"
        });

        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");

        link.href = url;
        link.download = "duplicate-scan-report-" +
            <%= scanId > 0 ? scanId : 0 %> + ".csv";

        document.body.appendChild(link);
        link.click();
        link.remove();

        setTimeout(() => URL.revokeObjectURL(url), 1000);
    }
</script>

</body>
</html>
