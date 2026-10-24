
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>DuplicateDetector | Smart File Scanner</title>

	<style>
		:root {
		    --bg: #080d1b;
		    --panel: #111a2e;
		    --panel-light: #15213a;
		    --border: rgba(148,163,184,.16);
		    --text: #f1f5f9;
		    --muted: #94a3b8;
		    --blue: #4f7cff;
		    --purple: #8b5cf6;
		}
		
		* {
		    box-sizing: border-box;
		    margin: 0;
		    padding: 0;
		}
		
		html {
		    scroll-behavior: smooth;
		    scroll-padding-top: 95px;
		}
		
		body {
		    font-family: "Segoe UI", Arial, sans-serif;
		    color: var(--text);
		    background:
		        radial-gradient(ellipse at 10% 5%, rgba(79,124,255,.12), transparent 35%),
		        radial-gradient(ellipse at 95% 35%, rgba(139,92,246,.10), transparent 30%),
		        var(--bg);
		    line-height: 1.6;
		}
		
		a {
		    color: inherit;
		}
		
		.navbar {
		    position: sticky;
		    top: 0;
		    z-index: 100;
		    min-height: 76px;
		    padding: 15px 6%;
		    display: flex;
		    align-items: center;
		    justify-content: space-between;
		    gap: 22px;
		    flex-wrap: wrap;
		    background: rgba(8,13,27,.91);
		    border-bottom: 1px solid var(--border);
		    backdrop-filter: blur(18px);
		}
		
		.logo {
		    display: flex;
		    align-items: center;
		    gap: 11px;
		    font-size: 21px;
		    font-weight: 800;
		    letter-spacing: -.6px;
		    text-decoration: none;
		    white-space: nowrap;
		}
		
		.logo-icon {
		    width: 39px;
		    height: 39px;
		    display: grid;
		    place-items: center;
		    border-radius: 12px;
		    background: linear-gradient(135deg,var(--blue),var(--purple));
		    color: white;
		    font-size: 21px;
		    box-shadow: 0 5px 20px rgba(79,124,255,.2);
		}
		
		.logo span {
		    color: #86a0ff;
		}
		
		.nav-links {
		    display: flex;
		    align-items: center;
		    justify-content: flex-end;
		    gap: 20px;
		    flex-wrap: wrap;
		}
		
		.nav-links > a {
		    color: #c0cadb;
		    font-size: 13px;
		    font-weight: 600;
		    text-decoration: none;
		    transition: color .2s;
		}
		
		.nav-links > a:hover {
		    color: #9bb2ff;
		}
		
		.welcome {
		    color: #c4b5fd;
		    font-size: 12px;
		    overflow-wrap: anywhere;
		}
		
		.logout-form {
		    display: inline;
		    margin: 0;
		}
		
		.logout-btn {
		    border: 1px solid rgba(248,113,113,.25);
		    border-radius: 9px;
		    padding: 9px 13px;
		    background: rgba(220,38,38,.12);
		    color: #fca5a5;
		    cursor: pointer;
		    font-size: 12px;
		    font-weight: 700;
		    transition: background .2s;
		}
		
		.logout-btn:hover {
		    background: rgba(220,38,38,.25);
		}
		
		main {
		    width: min(1120px, 100%);
		    margin: 0 auto;
		    padding: 45px 24px 60px;
		}
		
		.hero {
		    position: relative;
		    overflow: hidden;
		    padding: 55px 48px;
		    border: 1px solid rgba(129,140,248,.25);
		    border-radius: 24px;
		    background:
		        radial-gradient(circle at 90% 10%,rgba(139,92,246,.27),transparent 35%),
		        linear-gradient(125deg,#142448,#111a34 65%,#1a1940);
		    box-shadow: 0 22px 65px rgba(0,0,0,.2);
		    animation: rise .6s ease both;
		}
		
		.hero::after {
		    content: "";
		    position: absolute;
		    width: 260px;
		    height: 260px;
		    right: -90px;
		    bottom: -140px;
		    border: 1px solid rgba(147,164,255,.22);
		    border-radius: 50%;
		    box-shadow: 0 0 0 30px rgba(147,164,255,.025),
		                0 0 0 60px rgba(147,164,255,.02);
		    pointer-events: none;
		}
		
		.eyebrow {
		    display: inline-flex;
		    align-items: center;
		    gap: 8px;
		    margin-bottom: 20px;
		    padding: 7px 12px;
		    border: 1px solid rgba(129,140,248,.25);
		    border-radius: 30px;
		    background: rgba(79,124,255,.1);
		    color: #b8c7ff;
		    font-size: 11px;
		    font-weight: 700;
		    letter-spacing: 1px;
		    text-transform: uppercase;
		}
		
		.status-dot {
		    width: 7px;
		    height: 7px;
		    border-radius: 50%;
		    background: #6ee7b7;
		    box-shadow: 0 0 10px rgba(110,231,183,.6);
		}
		
		.hero h1 {
		    max-width: 700px;
		    margin-bottom: 18px;
		    font-size: clamp(32px,5vw,49px);
		    font-weight: 800;
		    letter-spacing: -1.6px;
		    line-height: 1.15;
		}
		
		.gradient-text {
		    color: #91a9ff;
		    background: linear-gradient(90deg,#8cb0ff,#c4a5ff);
		    -webkit-background-clip: text;
		    background-clip: text;
		    -webkit-text-fill-color: transparent;
		}
		
		.hero p {
		    max-width: 650px;
		    color: #b4c0d6;
		    font-size: 15px;
		    line-height: 1.9;
		}
		
		.hero-actions {
		    display: flex;
		    gap: 12px;
		    flex-wrap: wrap;
		    margin-top: 28px;
		}
		
		.btn {
		    display: inline-flex;
		    align-items: center;
		    justify-content: center;
		    gap: 9px;
		    min-height: 45px;
		    padding: 12px 19px;
		    border: 1px solid transparent;
		    border-radius: 10px;
		    background: white;
		    color: #10182a;
		    font-size: 13px;
		    font-weight: 750;
		    text-decoration: none;
		    cursor: pointer;
		    transition: transform .2s, box-shadow .2s, background .2s;
		}
		
		.btn:hover {
		    transform: translateY(-2px);
		}
		
		.btn-primary {
		    background: linear-gradient(100deg,var(--blue),var(--purple));
		    color: white;
		    box-shadow: 0 7px 22px rgba(79,124,255,.19);
		}
		
		.btn-primary:hover {
		    color: white;
		    box-shadow: 0 10px 28px rgba(79,124,255,.3);
		}
		
		.btn-outline {
		    border-color: rgba(148,163,184,.25);
		    background: rgba(15,23,42,.45);
		    color: #e2e8f0;
		}
		
		.btn-outline:hover {
		    background: rgba(148,163,184,.12);
		    color: white;
		}
		
		.section-heading {
		    margin: 38px 0 17px;
		}
		
		.section-heading h2 {
		    font-size: 21px;
		    font-weight: 750;
		    letter-spacing: -.4px;
		}
		
		.section-heading p {
		    margin-top: 5px;
		    color: var(--muted);
		    font-size: 13px;
		}
		
		.stats {
		    display: grid;
		    grid-template-columns: repeat(3,minmax(0,1fr));
		    gap: 17px;
		}
		
		.stat-card {
		    min-width: 0;
		    padding: 24px;
		    border: 1px solid var(--border);
		    border-radius: 17px;
		    background: linear-gradient(145deg,rgba(21,33,58,.94),rgba(15,23,42,.95));
		    transition: transform .25s,border-color .25s;
		    animation: rise .6s ease both;
		}
		
		.stat-card:hover {
		    transform: translateY(-4px);
		    border-color: rgba(129,140,248,.4);
		}
		
		.stat-top {
		    display: flex;
		    align-items: center;
		    justify-content: space-between;
		    gap: 10px;
		    margin-bottom: 19px;
		}
		
		.stat-label {
		    color: #a8b4c9;
		    font-size: 12px;
		    font-weight: 600;
		}
		
		.stat-icon {
		    width: 39px;
		    height: 39px;
		    display: grid;
		    place-items: center;
		    border-radius: 12px;
		    background: rgba(79,124,255,.13);
		    color: #9bb2ff;
		    font-size: 19px;
		}
		
		.stat-number {
		    font-size: 29px;
		    font-weight: 800;
		    letter-spacing: -.8px;
		}
		
		.stat-caption {
		    margin-top: 5px;
		    color: #7f8da5;
		    font-size: 11px;
		}
		
		.scanner {
		    margin-top: 30px;
		    padding: 30px;
		    border: 1px solid var(--border);
		    border-radius: 20px;
		    background: rgba(17,26,46,.91);
		    box-shadow: 0 15px 45px rgba(0,0,0,.13);
		}
		
		.scanner-heading {
		    display: flex;
		    align-items: flex-start;
		    gap: 14px;
		    margin-bottom: 23px;
		}
		
		.scanner-icon {
		    flex: 0 0 45px;
		    height: 45px;
		    display: grid;
		    place-items: center;
		    border-radius: 13px;
		    background: rgba(139,92,246,.14);
		    color: #c4b5fd;
		    font-size: 21px;
		}
		
		.scanner-heading h2 {
		    font-size: 20px;
		    font-weight: 750;
		}
		
		.scanner-heading p {
		    margin-top: 5px;
		    color: var(--muted);
		    font-size: 13px;
		}
		
		.notice {
		    margin-bottom: 20px;
		    padding: 14px 16px;
		    border: 1px solid rgba(96,165,250,.2);
		    border-radius: 11px;
		    background: rgba(59,130,246,.09);
		    color: #bfdbfe;
		    font-size: 13px;
		}
		
		.upload {
		    display: block;
		    padding: 34px 18px;
		    border: 2px dashed #3b4c6c;
		    border-radius: 15px;
		    background: rgba(8,13,27,.45);
		    text-align: center;
		    cursor: pointer;
		    transition: border-color .2s,background .2s;
		}
		
		.upload:hover,
		.upload.drag-over {
		    border-color: #829dff;
		    background: rgba(79,124,255,.07);
		}
		
		.upload-icon {
		    width: 53px;
		    height: 53px;
		    margin: 0 auto 14px;
		    display: grid;
		    place-items: center;
		    border-radius: 16px;
		    background: rgba(79,124,255,.13);
		    color: #9bb2ff;
		    font-size: 25px;
		}
		
		.upload strong {
		    display: block;
		    color: #e2e8f0;
		    font-size: 15px;
		}
		
		.upload .upload-subtitle {
		    display: block;
		    margin-top: 7px;
		    color: #8998b0;
		    font-size: 12px;
		}
		
		.upload input[type="file"] {
		    display: block;
		    width: 100%;
		    max-width: 330px;
		    margin: 18px auto 0;
		    color: #aab8d0;
		    font-size: 12px;
		    cursor: pointer;
		}
		
		.upload input[type="file"]::file-selector-button {
		    margin-right: 10px;
		    padding: 9px 12px;
		    border: 1px solid #3b4c6c;
		    border-radius: 8px;
		    background: #1a2945;
		    color: #e2e8f0;
		    cursor: pointer;
		}
		
		.file-summary {
		    margin-top: 16px;
		    padding: 13px 15px;
		    border: 1px solid var(--border);
		    border-radius: 10px;
		    background: rgba(8,13,27,.35);
		}
		
		.file-summary[hidden] {
		    display: none;
		}
		
		.file-summary-title {
		    margin-bottom: 8px;
		    color: #c4d2ea;
		    font-size: 12px;
		    font-weight: 700;
		}
		
		.file-list {
		    display: grid;
		    gap: 6px;
		    color: #94a3b8;
		    font-size: 12px;
		    overflow-wrap: anywhere;
		}
		
		.file-more {
		    color: #9bb2ff;
		    font-size: 12px;
		}
		
		.scan-actions {
		    display: flex;
		    align-items: center;
		    gap: 15px;
		    flex-wrap: wrap;
		    margin-top: 20px;
		}
		
		.scan-submit {
		    border: none;
		}
		
		#message {
		    margin-top: 14px;
		    color: #fbbf24;
		    font-size: 12px;
		    overflow-wrap: anywhere;
		}
		
		#message:empty {
		    display: none;
		}
		
		.scan-submit:disabled {
		    cursor: wait;
		    opacity: .7;
		    transform: none;
		}
		
		.info-grid {
		    display: grid;
		    grid-template-columns: repeat(3,minmax(0,1fr));
		    gap: 17px;
		    margin-top: 20px;
		}
		
		.info-card {
		    padding: 22px;
		    border: 1px solid var(--border);
		    border-radius: 15px;
		    background: rgba(17,26,46,.72);
		}
		
		.info-card .info-icon {
		    margin-bottom: 12px;
		    font-size: 23px;
		}
		
		.info-card h3 {
		    margin-bottom: 7px;
		    font-size: 14px;
		}
		
		.info-card p {
		    color: var(--muted);
		    font-size: 12px;
		    line-height: 1.8;
		}
		
		footer {
		    padding: 26px 20px;
		    border-top: 1px solid var(--border);
		    color: #7f8da5;
		    font-size: 12px;
		    text-align: center;
		}
		
		footer span {
		    color: #91a9ff;
		}
		
		@keyframes rise {
		    from {
		        opacity: 0;
		        transform: translateY(13px);
		    }
		    to {
		        opacity: 1;
		        transform: translateY(0);
		    }
		}
		
		@media (max-width: 850px) {
		    .navbar {
		        padding: 15px 4%;
		    }
		
		    .nav-links {
		        gap: 13px;
		    }
		
		    main {
		        padding: 30px 18px 45px;
		    }
		
		    .hero {
		        padding: 38px 30px;
		    }
		
		    .info-grid {
		        grid-template-columns: 1fr;
		    }
		}
		
		@media (max-width: 650px) {
		    .navbar {
		        position: relative;
		        align-items: flex-start;
		        flex-direction: column;
		        gap: 15px;
		    }
		
		    .nav-links {
		        justify-content: flex-start;
		        width: 100%;
		        gap: 12px 16px;
		    }
		
		    .nav-links > a {
		        font-size: 12px;
		    }
		
		    .welcome {
		        width: 100%;
		    }
		
		    main {
		        padding: 23px 15px 38px;
		    }
		
		    .hero {
		        padding: 29px 22px;
		        border-radius: 19px;
		    }
		
		    .hero h1 {
		        font-size: 32px;
		        letter-spacing: -.8px;
		    }
		
		    .hero p {
		        font-size: 13px;
		    }
		
		    .stats {
		        grid-template-columns: 1fr;
		        gap: 12px;
		    }
		
		    .stat-card {
		        padding: 19px;
		    }
		
		    .stat-top {
		        margin-bottom: 10px;
		    }
		
		    .stat-number {
		        font-size: 26px;
		    }
		
		    .scanner {
		        padding: 20px 16px;
		        border-radius: 16px;
		    }
		
		    .upload {
		        padding: 27px 12px;
		    }
		
		    .scan-actions .btn {
		        width: 100%;
		    }
		}
		
		@media (prefers-reduced-motion: reduce) {
		    *, *::before, *::after {
		        scroll-behavior: auto !important;
		        animation-duration: .01ms !important;
		        transition-duration: .01ms !important;
		    }
		}
		
		.file-list {
		    display: grid;
		    gap: 9px;
		    color: #cbd5e1;
		    font-size: 12px;
		    overflow-wrap: anywhere;
		}
		
		.file-item {
		    display: flex;
		    align-items: center;
		    justify-content: space-between;
		    gap: 12px;
		    padding: 11px 12px;
		    border: 1px solid var(--border);
		    border-radius: 9px;
		    background: rgba(21, 33, 58, .75);
		}
		
		.file-item-name {
		    flex: 1;
		    min-width: 0;
		    overflow-wrap: anywhere;
		}
		
		.file-remove-btn,
		.clear-files-btn {
		    flex-shrink: 0;
		    border: 1px solid rgba(248, 113, 113, .25);
		    border-radius: 7px;
		    padding: 7px 10px;
		    background: rgba(220, 38, 38, .12);
		    color: #fca5a5;
		    font-size: 11px;
		    font-weight: 700;
		    cursor: pointer;
		}
		
		.file-remove-btn:hover,
		.clear-files-btn:hover {
		    background: rgba(220, 38, 38, .25);
		}
		
		.file-summary-heading {
		    display: flex;
		    justify-content: space-between;
		    align-items: center;
		    gap: 10px;
		    flex-wrap: wrap;
		    margin-bottom: 12px;
		}
		
		.file-summary-title {
		    margin-bottom: 0;
		    color: #c4d2ea;
		    font-size: 12px;
		    font-weight: 700;
		}
		
		@media (max-width: 500px) {
		    .file-item {
		        align-items: flex-start;
		    }
		
		    .file-remove-btn {
		        padding: 7px 8px;
		    }
		}
	</style>
</head>

<body>

	<%
	    Object loggedInUserId = session.getAttribute("userId");
	    boolean loggedIn = loggedInUserId instanceof Number;
	    String displayName = "";
	
	    if (loggedIn) {
	        Object name = session.getAttribute("fullName");
	        if (name != null) {
	            displayName = name.toString();
	        }
	    }
	
	    String contextPath = request.getContextPath();
	%>
	
	<%@ include file="/navbar.jsp" %>
	
	<main>
	
	    <section class="hero">
	        <div class="eyebrow">
	            <span class="status-dot"></span>
	            Smart file analysis
	        </div>
	
	        <h1>
	            Find Duplicates.<br>
	            <span class="gradient-text">Save Your Space.</span>
	        </h1>
	
	        <p>
	            Discover identical files using SHA-256 hash comparison.
	            Organize your scan history and identify duplicate content
	            with your personal file scanning workspace.
	        </p>
	
	        <div class="hero-actions">
	            <% if (loggedIn) { %>
	
	                <a class="btn btn-primary"
	                   href="<%= contextPath %>/index.jsp#scanner">
	                    &#128269; Start Scanning
	                </a>
	
	                <a class="btn btn-outline"
	                   href="<%= contextPath %>/dashboard.jsp">
	                    Open Dashboard &#8594;
	                </a>
	
	            <% } else { %>
	
	                <a class="btn btn-primary"
	                   href="<%= contextPath %>/login.jsp">
	                    Login to Scan &#8594;
	                </a>
	
	                <a class="btn btn-outline"
	                   href="<%= contextPath %>/register.jsp">
	                    Create Account
	                </a>
	
	            <% } %>
	        </div>
	    </section>
	
	    <section>
	        <div class="section-heading">
	            <h2>Your scanning workspace</h2>
	            <p>Quick overview of your duplicate detection workflow.</p>
	        </div>
	
	        <div class="stats">
	            <div class="stat-card">
	                <div class="stat-top">
	                    <span class="stat-label">Files Scanned</span>
	                    <span class="stat-icon">&#128196;</span>
	                </div>
	                <div class="stat-number">&mdash;</div>
	                <div class="stat-caption">Files processed by your scans</div>
	            </div>
	
	            <div class="stat-card">
	                <div class="stat-top">
	                    <span class="stat-label">Duplicates Found</span>
	                    <span class="stat-icon">&#128465;</span>
	                </div>
	                <div class="stat-number">&mdash;</div>
	                <div class="stat-caption">Identical file contents detected</div>
	            </div>
	
	            <div class="stat-card">
	                <div class="stat-top">
	                    <span class="stat-label">Potential Space Savings</span>
	                    <span class="stat-icon">&#128190;</span>
	                </div>
	                <div class="stat-number">&mdash;</div>
	                <div class="stat-caption">Estimated duplicate file size</div>
	            </div>
	        </div>
	    </section>
	
	    <section class="scanner" id="scanner">
	        <div class="scanner-heading">
	            <div class="scanner-icon">&#128193;</div>
	            <div>
	                <h2>Start a New Scan</h2>
	                <p>Select files and prepare them for duplicate detection.</p>
	            </div>
	        </div>
	
	        <% if (loggedIn) { %>
	
	            <form id="scanForm"
	                  action="<%= contextPath %>/scan"
	                  method="post"
	                  enctype="multipart/form-data">
	
	                <label class="upload" id="uploadArea" for="files">
	                    <span class="upload-icon">&#8593;</span>
	                    <strong>Choose files or drag them here</strong>
	                    <span class="upload-subtitle">
	                        Select multiple files from your computer
	                    </span>
	
	                    <input type="file"
	                           id="files"
	                           name="files"
	                           multiple
	                           required>
	                </label>
	
	                <div class="file-summary" id="fileSummary"
					     style="display: none;">
					    <div class="file-summary-heading">
					        <div class="file-summary-title" id="fileCount"></div>
					        <button type="button" class="clear-files-btn" id="clearFilesButton">
					            Clear All
					        </button>
					    </div>
					    <div class="file-list" id="fileList"></div>
					</div>
	
	                <div class="scan-actions">
	                    <button type="submit"
	                            class="btn btn-primary scan-submit"
	                            id="scanButton">
	                        Prepare Scan &#8594;
	                    </button>
	
	                    <a class="btn btn-outline"
	                       href="<%= contextPath %>/scan-history.jsp">
	                        View Scan History
	                    </a>
	                </div>
	
	                <div id="message" role="status" aria-live="polite"></div>
	            </form>
	
	        <% } else { %>
	
	            <div class="notice">
	                Please sign in to your account before scanning files.
	                Your scan history is associated with your account.
	            </div>
	
	            <div class="hero-actions">
	                <a class="btn btn-primary"
	                   href="<%= contextPath %>/login.jsp">
	                    Login to Continue
	                </a>
	
	                <a class="btn btn-outline"
	                   href="<%= contextPath %>/register.jsp">
	                    Create Account
	                </a>
	            </div>
	
	        <% } %>
	    </section>
	
	    <section id="about">
	        <div class="section-heading">
	            <h2>How DuplicateDetector works</h2>
	            <p>A simple workflow for finding identical file content.</p>
	        </div>
	
	        <div class="info-grid">
	            <article class="info-card">
	                <div class="info-icon">&#128193;</div>
	                <h3>01. Select Files</h3>
	                <p>
	                    Choose multiple files from your computer to prepare
	                    a scan for duplicate detection.
	                </p>
	            </article>
	
	            <article class="info-card">
	                <div class="info-icon">&#128270;</div>
	                <h3>02. Compare Hashes</h3>
	                <p>
	                    SHA-256 hashes help identify files with identical
	                    content, even when their filenames differ.
	                </p>
	            </article>
	
	            <article class="info-card">
	                <div class="info-icon">&#128202;</div>
	                <h3>03. Review Results</h3>
	                <p>
	                    Review scan results and revisit previous scans
	                    through your personal scan history.
	                </p>
	            </article>
	        </div>
	    </section>
	
	</main>
	
	<footer>
	    DuplicateDetector &copy; 2026
	    <span>|</span> Smart File Management
	</footer>
	
	<script>

		const fileInput = document.getElementById("files");
		const message = document.getElementById("message");
		const uploadArea = document.getElementById("uploadArea");
		const fileSummary = document.getElementById("fileSummary");
		const fileCount = document.getElementById("fileCount");
		const fileList = document.getElementById("fileList");
		const clearFilesButton = document.getElementById("clearFilesButton");
		const scanForm = document.getElementById("scanForm");
		const scanButton = document.getElementById("scanButton");
	
		let selectedFiles = [];
	
		function formatFileSize(bytes) {
		    if (bytes < 1024) return bytes + " B";
		    if (bytes < 1024 * 1024) {
		        return (bytes / 1024).toFixed(1) + " KB";
		    }
		    if (bytes < 1024 * 1024 * 1024) {
		        return (bytes / (1024 * 1024)).toFixed(1) + " MB";
		    }
		    return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
		}
	
		function syncFileInput() {
		    const dataTransfer = new DataTransfer();
	
		    selectedFiles.forEach(function(file) {
		        dataTransfer.items.add(file);
		    });
	
		    fileInput.files = dataTransfer.files;
		}
	
		function updateFilePreview() {
		    fileList.replaceChildren();
	
		    if (selectedFiles.length === 0) {
		        fileSummary.style.display = "none";
		        fileCount.textContent = "";
	
		        if (message) message.textContent = "";
		        return;
		    }
	
		    fileSummary.style.display = "block";
		    fileCount.textContent =
		        selectedFiles.length + " file(s) selected";
	
		    selectedFiles.forEach(function(file, index) {
		        const item = document.createElement("div");
		        item.className = "file-item";
	
		        const name = document.createElement("span");
		        name.className = "file-item-name";
		        name.textContent =
		            file.name + " (" + formatFileSize(file.size) + ")";
	
		        const removeButton = document.createElement("button");
		        removeButton.type = "button";
		        removeButton.className = "file-remove-btn";
		        removeButton.textContent = "✕ Remove";
		        removeButton.setAttribute(
		            "aria-label", "Remove " + file.name
		        );
	
		        removeButton.addEventListener("click", function() {
		            selectedFiles.splice(index, 1);
		            syncFileInput();
		            updateFilePreview();
		        });
	
		        item.appendChild(name);
		        item.appendChild(removeButton);
		        fileList.appendChild(item);
		    });
	
		    if (message) message.textContent = "";
		}
	

		if (fileInput) {
		    fileInput.addEventListener("change", function() {
		        const newFiles = Array.from(fileInput.files);

		        newFiles.forEach(function(newFile) {
		            const alreadyAdded = selectedFiles.some(function(existingFile) {
		                return existingFile.name === newFile.name &&
		                       existingFile.size === newFile.size &&
		                       existingFile.lastModified === newFile.lastModified;
		            });

		            if (!alreadyAdded) {
		                selectedFiles.push(newFile);
		            }
		        });

		        syncFileInput();
		        updateFilePreview();
		    });
		}

	
		if (clearFilesButton) {
		    clearFilesButton.addEventListener("click", function() {
		        selectedFiles = [];
		        fileInput.value = "";
		        syncFileInput();
		        updateFilePreview();
		    });
		}
	
		if (uploadArea && fileInput) {
		    ["dragenter", "dragover"].forEach(function(eventName) {
		        uploadArea.addEventListener(eventName, function(event) {
		            event.preventDefault();
		            uploadArea.classList.add("drag-over");
		        });
		    });
	
		    ["dragleave", "drop"].forEach(function(eventName) {
		        uploadArea.addEventListener(eventName, function(event) {
		            event.preventDefault();
		            uploadArea.classList.remove("drag-over");
		        });
		    });
	

		    uploadArea.addEventListener("drop", function(event) {
		        if (event.dataTransfer &&
		            event.dataTransfer.files.length > 0) {

		            const droppedFiles = Array.from(event.dataTransfer.files);

		            droppedFiles.forEach(function(newFile) {
		                const alreadyAdded = selectedFiles.some(function(existingFile) {
		                    return existingFile.name === newFile.name &&
		                           existingFile.size === newFile.size &&
		                           existingFile.lastModified === newFile.lastModified;
		                });

		                if (!alreadyAdded) {
		                    selectedFiles.push(newFile);
		                }
		            });

		            syncFileInput();
		            updateFilePreview();
		        }
		    });

		}
	
		if (scanForm && scanButton && fileInput) {
		    scanForm.addEventListener("submit", function(event) {
		        syncFileInput();
	
		        if (selectedFiles.length === 0) {
		            event.preventDefault();
	
		            if (message) {
		                message.textContent =
		                    "Please select at least one file.";
		            }
		            return;
		        }
	
		        scanButton.disabled = true;
		        scanButton.textContent = "Uploading and scanning...";
		    });
		}

	</script>

</body>
</html>
