<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
.dd-navbar{box-sizing:border-box;width:calc(100% - 2 * clamp(24px, 5.5vw, 92px));max-width:1460px;min-height:76px;margin:0 auto 28px;padding:16px 4%;position:relative;top:0;z-index:1000;display:flex;align-items:center;justify-content:space-between;gap:18px;flex-wrap:wrap;background:rgba(17,26,46,.92);border:1px solid rgba(148,163,184,.16);border-radius:16px;box-shadow:none;backdrop-filter:blur(18px);font-family:Segoe UI,Arial,sans-serif}.dd-brand{font-size:20px;font-weight:800;color:#edf2ff;text-decoration:none;white-space:nowrap}.dd-brand span{color:#82a4ff}.dd-links{display:flex;align-items:center;justify-content:center;gap:8px;flex-wrap:wrap}.dd-links a{padding:10px 13px;border-radius:9px;color:#cbd5e1;text-decoration:none;font-size:14px;transition:background .2s,color .2s}.dd-links a:hover,.dd-links a.dd-active{background:#18243a;color:#91adff}.dd-logout{margin:0}.dd-logout button,.dd-auth-link{display:inline-block;border:1px solid rgba(248,113,113,.25);border-radius:9px;padding:10px 14px;background:rgba(225,29,72,.10);color:#ffb6c5;text-decoration:none;font-size:14px;cursor:pointer}.dd-auth-link{border-color:rgba(130,164,255,.3);background:rgba(86,133,255,.12);color:#a9c5ff}.dd-nav-actions{display:flex;align-items:center;gap:8px}@media(max-width:700px){.dd-navbar{width:calc(100% - 28px);max-width:none;margin:0 auto 22px;padding:15px 4%;gap:12px;min-height:76px;border-radius:16px}.dd-links{order:3;width:100%;justify-content:flex-start}.dd-links a{padding:8px 10px;font-size:13px}.dd-brand{font-size:18px}.dd-nav-actions{margin-left:auto}}
</style>
<% String ddCtx=request.getContextPath(); String ddUri=request.getRequestURI(); String ddRole=(String)session.getAttribute("userRole"); boolean ddLogged=session.getAttribute("userId")!=null; boolean ddAdmin="ADMIN".equalsIgnoreCase(ddRole); %>
<nav class="dd-navbar">
 <a class="dd-brand" href="<%=ddCtx%>/<%=ddAdmin?"admin-dashboard.jsp":(ddLogged?"dashboard.jsp":"index.jsp")%>">Duplicate<span>Detector</span></a>
 <div class="dd-links">
 <% if(ddAdmin){ %>
 <a class="<%=ddUri.endsWith("admin-dashboard.jsp")?"dd-active":""%>" href="<%=ddCtx%>/admin-dashboard.jsp">Dashboard</a>
 <a class="<%=ddUri.endsWith("admin-users.jsp")?"dd-active":""%>" href="<%=ddCtx%>/admin-users.jsp">Users</a>
 <a class="<%=ddUri.endsWith("admin-scans.jsp")?"dd-active":""%>" href="<%=ddCtx%>/admin-scans.jsp">Scan Records</a>
 <a class="<%=ddUri.endsWith("admin-account-requests.jsp")?"dd-active":""%>" href="<%=ddCtx%>/admin-account-requests.jsp">Account Requests</a>
 <% } else if(ddLogged){ %>
 <a class="<%=ddUri.endsWith("dashboard.jsp")?"dd-active":""%>" href="<%=ddCtx%>/dashboard.jsp">Dashboard</a>
 <a class="<%=ddUri.endsWith("index.jsp")?"dd-active":""%>" href="<%=ddCtx%>/index.jsp">Scanner</a>
 <a class="<%=ddUri.endsWith("scan-history.jsp")||ddUri.endsWith("scan-details.jsp")?"dd-active":""%>" href="<%=ddCtx%>/scan-history.jsp">History</a>
 <% } else { %>
 <a class="<%=ddUri.endsWith("index.jsp")?"dd-active":""%>" href="<%=ddCtx%>/index.jsp">Home</a>
 <a class="<%=ddUri.endsWith("login.jsp")?"dd-active":""%>" href="<%=ddCtx%>/login.jsp">Login</a>
 <a class="<%=ddUri.endsWith("register.jsp")?"dd-active":""%>" href="<%=ddCtx%>/register.jsp">Register</a>
 <% } %>
 </div>
 <div class="dd-nav-actions">
 <% if(ddLogged){ %><form class="dd-logout" action="<%=ddCtx%>/logout" method="post"><button type="submit">↗ Logout</button></form><% } %>
 </div>
</nav>
