<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.duplicatedetector.util.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
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
	    --bg: #080d1b;
	    --panel: #111a2e;
	    --panel-light: #17233d;
	    --border: rgba(148, 163, 184, .16);
	    --text: #edf2ff;
	    --muted: #94a3b8;
	    --blue: #5685ff;
	    --purple: #9b7bff;
	}
	
	body {
	    margin: 0;
	    padding: 28px 20px;
	    min-height: 100vh;
	    font-family: Arial, sans-serif;
	    background: radial-gradient(ellipse at top left, #172554 0%, var(--bg) 48%);
	    color: var(--text);
	}
	
	.container {
	    width: 100%;
	    max-width: 1250px;
	    margin: 0 auto;
	}
	
	.header {
	    margin-bottom: 25px;
	}
	
	.header h1 {
	    margin-bottom: 8px;
	    color: #f1f5ff;
	    font-size: clamp(27px, 4vw, 36px);
	    letter-spacing: -1px;
	}
	
	.header p {
	    color: var(--muted);
	    line-height: 1.7;
	}
	
	.card {
	    padding: 25px;
	    background: linear-gradient(145deg, #111a2e, #0e1628);
	    border: 1px solid var(--border);
	    border-radius: 18px;
	    box-shadow: 0 18px 50px rgba(0, 0, 0, .2);
	    overflow: hidden;
	}
	
	h2 {
	    color: #e5edff;
	    margin-top: 0;
	}
	
	.summary {
	    display: grid;
	    grid-template-columns: repeat(3, minmax(0, 1fr));
	    gap: 15px;
	    margin: 22px 0;
	}
	
	.summary-item {
	    background: linear-gradient(145deg, #192846, #141e34);
	    border: 1px solid rgba(86, 133, 255, .2);
	    padding: 20px;
	    border-radius: 13px;
	    min-width: 0;
	}
	
	.summary-item span {
	    display: block;
	    color: var(--muted);
	    font-size: 13px;
	    margin-bottom: 10px;
	}
	
	.summary-item strong {
	    font-size: 25px;
	    color: #a9bdff;
	    overflow-wrap: anywhere;
	}
	
	.toolbar {
	    display: flex;
	    flex-wrap: wrap;
	    gap: 12px;
	    margin: 22px 0;
	}
	
	.toolbar input,
	.toolbar select {
	    flex: 1;
	    min-width: 180px;
	    padding: 12px 14px;
	    border: 1px solid var(--border);
	    border-radius: 9px;
	    background: #0c1426;
	    color: var(--text);
	    font-size: 14px;
	    outline: none;
	}
	
	.toolbar input:focus,
	.toolbar select:focus {
	    border-color: var(--blue);
	    box-shadow: 0 0 0 3px rgba(86, 133, 255, .12);
	}
	
	.toolbar input::placeholder {
	    color: #71809a;
	}
	
	.btn {
	    display: inline-block;
	    padding: 11px 15px;
	    border: none;
	    border-radius: 9px;
	    background: linear-gradient(110deg, var(--blue), var(--purple));
	    color: white;
	    text-decoration: none;
	    font-size: 13px;
	    font-weight: 600;
	    cursor: pointer;
	    transition: transform .2s, box-shadow .2s;
	}
	
	.btn:hover {
	    transform: translateY(-1px);
	    box-shadow: 0 5px 18px rgba(86, 133, 255, .25);
	}
	
	.btn-secondary {
	    background: #1b2943;
	    border: 1px solid var(--border);
	    color: #c5d3f5;
	}
	
	.btn-secondary:hover {
	    background: #253653;
	}
	
	.table-wrapper {
	    width: 100%;
	    overflow-x: auto;
	    border: 1px solid var(--border);
	    border-radius: 12px;
	}
	
	table {
	    width: 100%;
	    min-width: 760px;
	    border-collapse: collapse;
	    margin-top: 0;
	}
	
	th,
	td {
	    padding: 14px 12px;
	    border-bottom: 1px solid var(--border);
	    text-align: left;
	    vertical-align: top;
	}
	
	th {
	    background: #192642;
	    color: #b8c8f5;
	    font-size: 12px;
	    text-transform: uppercase;
	    letter-spacing: .5px;
	}
	
	td {
	    color: #dbe5f8;
	    font-size: 13px;
	    line-height: 1.6;
	}
	
	tbody tr:last-child td {
	    border-bottom: none;
	}
	
	tbody tr:hover {
	    filter: brightness(1.12);
	}
	
	.original-row {
	    background: rgba(16, 185, 129, .09);
	}
	
	.duplicate-row {
	    background: rgba(244, 63, 94, .09);
	}
	
	.unique-row {
	    background: rgba(148, 163, 184, .035);
	}
	
	.hash {
	    font-family: Consolas, monospace;
	    overflow-wrap: anywhere;
	    min-width: 220px;
	    max-width: 350px;
	    color: #a9baff;
	}
	
	.badge {
	    display: inline-block;
	    padding: 6px 9px;
	    border-radius: 20px;
	    font-size: 11px;
	    font-weight: bold;
	    white-space: nowrap;
	}
	
	.original-badge {
	    background: rgba(52, 211, 153, .13);
	    border: 1px solid rgba(52, 211, 153, .2);
	    color: #6ee7b7;
	}
	
	.duplicate-badge {
	    background: rgba(251, 113, 133, .13);
	    border: 1px solid rgba(251, 113, 133, .2);
	    color: #fda4af;
	}
	
	.unique-badge {
	    background: rgba(148, 163, 184, .12);
	    border: 1px solid var(--border);
	    color: #cbd5e1;
	}
	
	.message {
	    padding: 14px 16px;
	    background: rgba(86, 133, 255, .09);
	    border: 1px solid rgba(86, 133, 255, .18);
	    color: #b9ccff;
	    border-radius: 10px;
	    font-size: 13px;
    	line-height: 1.8;
	}

	.error {
	    padding: 15px;
    	color: #fda4af;
	    background: rgba(244, 63, 94, .1);
    	border: 1px solid rgba(244, 63, 94, .2);
	    border-radius: 9px;
    	line-height: 1.6;
	}	
	
	.empty-message {
    	text-align: center;
    	color: var(--muted);
    	padding: 28px;
	}

	.card > p {
    	line-height: 1.7;
	}

	.card > p strong {
    	color: #c5d3f5;
	}

	.footer {
    	margin-top: 25px;
    	text-align: center;
	    color: #64748b;
    	font-size: 12px;
	}

	@media (max-width: 700px) {
	    body {
        	padding: 15px 9px;
    	}

	    .card {
        	padding: 16px 12px;
    	    border-radius: 13px;
	    }

	    .header h1 {
    	    font-size: 27px;
	    }

	    .summary {
        	grid-template-columns: 1fr;
        	gap: 10px;
    	}

    	.summary-item {
        	padding: 16px;
    	}

	    .summary-item strong {
        	font-size: 22px;
    	}

	    .toolbar {
        	flex-direction: column;
    	}

    	.toolbar input,
    	.toolbar select,
    	.toolbar button {
        	width: 100%;
        	min-width: 0;
    	}

    	.table-wrapper {
    	    border-radius: 9px;
    	}

    	.btn {
	        text-align: center;
    	}
	}
	</style>

</head>

<body>

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
