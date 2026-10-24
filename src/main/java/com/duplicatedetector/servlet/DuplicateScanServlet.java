package com.duplicatedetector.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.duplicatedetector.util.DBConnection;

@SuppressWarnings("serial")
@WebServlet("/scan")
@MultipartConfig(
    location = "D:/DuplicateDetectorTemp",
    fileSizeThreshold = 0,
    maxFileSize = 1L * 1024 * 1024 * 1024,
    maxRequestSize = 5L * 1024 * 1024 * 1024 + 1024L * 1024
)
public class DuplicateScanServlet extends HttpServlet {

    private static final long MAX_FILE_SIZE = 1L * 1024 * 1024 * 1024;
    private static final long MAX_TOTAL_SIZE = 5L * 1024 * 1024 * 1024;

    private static class FileResult {
        String name;
        long size;
        String hash;

        FileResult(String name, long size, String hash) {
            this.name = name;
            this.size = size;
            this.hash = hash;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Verify login.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=login");
            return;
        }

        Object sessionUserId = session.getAttribute("userId");
        if (!(sessionUserId instanceof Number)) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=login");
            return;
        }
        int userId = ((Number) sessionUserId).intValue();

        List<FileResult> files = new ArrayList<>();
        Map<String, String> seenHashes = new HashMap<>();
        Map<String, String> statuses = new HashMap<>();
        int duplicateCount = 0;
        long spaceSaved = 0L;

        // 2. Let the Servlet container parse multipart data.
        final Collection<Part> uploadedParts;
        try {
            uploadedParts = request.getParts();
        } catch (IllegalStateException e) {
            response.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                "Upload limit exceeded: 1 GiB per file and 5 GiB total file content.");
            return;
        }

        // 3. Validate all file sizes before calculating hashes.
        long totalUploadSize = 0L;
        for (Part part : uploadedParts) {
            if (!"files".equals(part.getName()) || part.getSize() == 0L) {
                continue;
            }

            long size = part.getSize();
            if (size > MAX_FILE_SIZE) {
                response.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                    "Each file must be 1 GiB or smaller.");
                return;
            }

            // Avoid overflow by subtracting before adding.
            if (size > MAX_TOTAL_SIZE - totalUploadSize) {
                response.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                    "Total file content must not exceed 5 GiB per scan.");
                return;
            }
            totalUploadSize += size;
        }

        if (totalUploadSize == 0L) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                "Please select at least one non-empty file.");
            return;
        }

        // 4. Stream each file through SHA-256. Do not load the whole file into RAM.
        for (Part part : uploadedParts) {
            if (!"files".equals(part.getName()) || part.getSize() == 0L) {
                continue;
            }

            String fileName = getSafeFileName(part);
            String hash;
            try {
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                try (InputStream input = part.getInputStream()) {
                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    while ((bytesRead = input.read(buffer)) != -1) {
                        digest.update(buffer, 0, bytesRead);
                    }
                }
                hash = HexFormat.of().formatHex(digest.digest());
            } catch (NoSuchAlgorithmException e) {
                throw new ServletException("SHA-256 unavailable", e);
            }

            String firstFile = seenHashes.putIfAbsent(hash, fileName);
            String status;
            if (firstFile != null) {
                status = "Duplicate of " + firstFile;
                duplicateCount++;
                spaceSaved += part.getSize();
            } else {
                status = "Original";
            }

            files.add(new FileResult(fileName, part.getSize(), hash));
            statuses.put(String.valueOf(files.size() - 1), status);
        }

        // 5. Save history and file metadata in one transaction.
        int scanId;
        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String historySql =
                    "INSERT INTO scan_history " +
                    "(user_id, total_files, duplicate_count, potential_space_saved, scan_status) " +
                    "VALUES (?, ?, ?, ?, ?)";

                try (PreparedStatement ps = connection.prepareStatement(
                        historySql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, files.size());
                    ps.setInt(3, duplicateCount);
                    ps.setLong(4, spaceSaved);
                    ps.setString(5, "COMPLETED");
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new ServletException("Could not create scan history.");
                        }
                        scanId = keys.getInt(1);
                    }
                }

                String fileSql =
                    "INSERT INTO scanned_files " +
                    "(scan_id, file_name, file_size, sha256_hash, stored_path) " +
                    "VALUES (?, ?, ?, ?, NULL)";

                try (PreparedStatement ps = connection.prepareStatement(fileSql)) {
                    for (FileResult file : files) {
                        ps.setInt(1, scanId);
                        ps.setString(2, file.name);
                        ps.setLong(3, file.size);
                        ps.setString(4, file.hash);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                connection.commit();
            } catch (Exception e) {
                try {
                    connection.rollback();
                } catch (Exception rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            } finally {
                try {
                    connection.setAutoCommit(true);
                } catch (Exception ignored) {
                    // Connection is closing.
                }
            }
        } catch (Exception e) {
            throw new ServletException("Unable to save scan results to database.", e);
        }

        // 6. Display results.
        response.setContentType("text/html;charset=UTF-8");
        String contextPath = request.getContextPath();

        try (var out = response.getWriter()) {
            out.println("<!DOCTYPE html><html lang='en'><head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1'>");
            out.println("<title>Scan Results | DuplicateDetector</title>");
            out.println("<style>");
            out.println("""
                * {
                    box-sizing: border-box
                }
    
                body {
                    margin: 0;
                    min-height: 100vh;
                    font-family: 'Segoe UI', Arial, sans-serif;
                    background: #080d1b;
                    color: #eef2ff;
                    padding: 32px 20px
                }
    
                .container {
                    max-width: 1150px;
                    margin: 0 auto
                }
    
                .topbar {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    gap: 16px;
                    flex-wrap: wrap;
                    margin-bottom: 34px
                }
    
                .brand {
                    font-size: 21px;
                    font-weight: 800
                }
    
                .brand span {
                    color: #818cf8
                }
    
                .scan-label {
                    color: #a5b4fc;
                    background: #171d3b;
                    border: 1px solid #303866;
                    padding: 8px 13px;
                    border-radius: 30px;
                    font-size: 13px
                }
    
                .hero {
                    margin-bottom: 28px
                }
    
                .hero h1 {
                    font-size: clamp(28px, 4vw, 40px);
                    margin: 0 0 10px
                }
    
                .hero p {
                    color: #9ca9c5;
                    line-height: 1.7
                }
    
                .stats {
                    display: grid;
                    grid-template-columns: repeat(3, minmax(0, 1fr));
                    gap: 18px;
                    margin-bottom: 28px
                }
    
                .stat-card {
                    padding: 23px;
                    border: 1px solid #252e49;
                    border-radius: 18px;
                    background: linear-gradient(145deg, #141d35, #101629);
                    min-width: 0
                }
    
                .stat-label {
                    color: #a5b0ca;
                    font-size: 14px;
                    margin-bottom: 14px
                }
    
                .stat-value {
                    font-size: clamp(25px, 3vw, 34px);
                    font-weight: 800;
                    overflow-wrap: anywhere
                }
    
                .stat-note {
                    color: #8997b4;
                    font-size: 12px;
                    margin-top: 9px
                }
    
                .blue {
                    color: #7c9cff
                }
    
                .green {
                    color: #4adea5
                }
    
                .purple {
                    color: #c4a7ff
                }
    
                .panel {
                    background: #10172a;
                    border: 1px solid #252e49;
                    border-radius: 18px;
                    overflow: hidden
                }
    
                .panel-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    gap: 12px;
                    flex-wrap: wrap;
                    padding: 22px 24px;
                    border-bottom: 1px solid #252e49
                }
    
                .panel-header h2 {
                    font-size: 19px;
                    margin: 0
                }
    
                .panel-header span {
                    font-size: 13px;
                    color: #9ca9c5
                }
    
                .table-wrap {
                    width: 100%;
                    overflow-x: auto
                }
    
                table {
                    width: 100%;
                    border-collapse: collapse;
                    min-width: 560px
                }
    
                th,
                td {
                    padding: 17px 24px;
                    text-align: left;
                    border-bottom: 1px solid #222b42;
                    overflow-wrap: anywhere
                }
    
                th {
                    background: #151e35;
                    color: #aebcda;
                    font-size: 12px;
                    text-transform: uppercase;
                    letter-spacing: .7px
                }
    
                td {
                    color: #e2e8f8;
                    font-size: 14px
                }
    
                tbody tr:hover {
                    background: #151e35
                }
    
                .file-name {
                    font-weight: 600
                }
    
                .file-icon {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    width: 35px;
                    height: 35px;
                    margin-right: 11px;
                    border-radius: 10px;
                    background: #202c4c;
                    color: #9db5ff;
                    vertical-align: middle;
                    font-size: 10px;
                    font-weight: 800
                }
    
                .badge {
                    display: inline-block;
                    padding: 7px 11px;
                    border-radius: 30px;
                    font-size: 12px;
                    font-weight: 700
                }
    
                .original {
                    color: #4adea5;
                    background: #12372f;
                    border: 1px solid #205744
                }
    
                .duplicate {
                    color: #fda4af;
                    background: #401e2b;
                    border: 1px solid #713047
                }
    
                .empty {
                    padding: 35px 20px;
                    text-align: center;
                    color: #9ca9c5
                }
    
                .actions {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 12px;
                    margin-top: 25px
                }
    
                .btn {
                    display: inline-flex;
                    justify-content: center;
                    align-items: center;
                    padding: 12px 19px;
                    border-radius: 11px;
                    text-decoration: none;
                    font-weight: 700;
                    font-size: 14px
                }
    
                .btn-primary {
                    color: white;
                    background: linear-gradient(100deg, #4f6cf7, #8655ed)
                }
    
                .btn-secondary {
                    color: #dbe4ff;
                    background: #171f36;
                    border: 1px solid #34405f
                }
    
                .footer {
                    color: #65728e;
                    font-size: 12px;
                    text-align: center;
                    margin-top: 35px
                }
    
                @media(max-width:700px) {
                    body {
                        padding: 22px 13px
                    }
    
                    .stats {
                        grid-template-columns: 1fr;
                        gap: 12px
                    }
    
                    .stat-card {
                        padding: 18px
                    }
    
                    .panel-header {
                        padding: 18px
                    }
    
                    th,
                    td {
                        padding: 14px 16px
                    }
    
                    .actions {
                        flex-direction: column
                    }
    
                    .btn {
                        width: 100%
                    }
                }
                """);
            out.println("</style></head><body><main class='container'>");
            out.println("<header class='topbar'><div class='brand'>Duplicate<span>Detector</span></div>");
            out.println("<div class='scan-label'>Scan #" + scanId + " &middot; Completed</div></header>");
            out.println("<section class='hero'><h1>Scan Results</h1>");
            out.println("<p>Your file scan is complete. Here's a summary of the results.</p></section>");
            out.println("<section class='stats'>");
            out.println("<div class='stat-card'><div class='stat-label'>Total Files Scanned</div>");
            out.println("<div class='stat-value blue'>" + files.size() + "</div>");
            out.println("<div class='stat-note'>Files checked in this scan</div></div>");
            out.println("<div class='stat-card'><div class='stat-label'>Duplicate Files Found</div>");
            out.println("<div class='stat-value green'>" + duplicateCount + "</div>");
            out.println("<div class='stat-note'>Repeated file contents detected</div></div>");
            out.println("<div class='stat-card'><div class='stat-label'>Potential Space Saved</div>");
            out.println("<div class='stat-value purple'>" + escapeHtml(formatFileSize(spaceSaved)) + "</div>");
            out.println("<div class='stat-note'>Estimated duplicate file size</div></div></section>");
            out.println("<section class='panel'><div class='panel-header'><h2>Scanned Files</h2>");
            out.println("<span>" + files.size() + " file(s)</span></div>");

            if (files.isEmpty()) {
                out.println("<div class='empty'>No files were uploaded for this scan.</div>");
            } else {
                out.println("<div class='table-wrap'><table><thead><tr><th>File</th><th>Size</th><th>Status</th></tr></thead><tbody>");
                for (int i = 0; i < files.size(); i++) {
                    FileResult file = files.get(i);
                    String status = statuses.get(String.valueOf(i));
                    boolean isDuplicate = status != null && status.startsWith("Duplicate of ");
                    out.println("<tr><td><span class='file-icon'>FILE</span><span class='file-name'>"
                        + escapeHtml(file.name) + "</span></td>");
                    out.println("<td>" + escapeHtml(formatFileSize(file.size)) + "</td>");
                    if (isDuplicate) {
                        out.println("<td><span class='badge duplicate'>" + escapeHtml(status) + "</span></td>");
                    } else {
                        out.println("<td><span class='badge original'>Original</span></td>");
                    }
                    out.println("</tr>");
                }
                out.println("</tbody></table></div>");
            }

            out.println("</section><nav class='actions'>");
            out.println("<a class='btn btn-primary' href='" + contextPath + "/index.jsp'>Scan More Files</a>");
            out.println("<a class='btn btn-secondary' href='" + contextPath + "/scan-history.jsp'>View Scan History</a>");
            out.println("<a class='btn btn-secondary' href='" + contextPath + "/dashboard.jsp'>Back to Dashboard</a>");
            out.println("</nav><footer class='footer'>DuplicateDetector &middot; File scanning and duplicate analysis</footer>");
            out.println("</main></body></html>");
        }
    }

    private String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " bytes";
        if (bytes < 1024L * 1024) {
            return String.format(Locale.US, "%.1f KB", bytes / 1024.0);
        }
        if (bytes < 1024L * 1024 * 1024) {
            return String.format(Locale.US, "%.1f MB", bytes / (1024.0 * 1024));
        }
        return String.format(Locale.US, "%.2f GB", bytes / (1024.0 * 1024 * 1024));
    }

    private String getSafeFileName(Part part) {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.isBlank()) return "unnamed-file";
        submitted = submitted.replace('\\', '/');
        return submitted.substring(submitted.lastIndexOf('/') + 1);
    }

    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
}
