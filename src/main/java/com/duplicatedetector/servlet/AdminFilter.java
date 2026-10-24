
package com.duplicatedetector.servlet;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = {
        "/admin-dashboard.jsp",
        "/admin-users.jsp",
        "/admin-scans.jsp"
})
public class AdminFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest =
                (HttpServletRequest) request;

        HttpServletResponse httpResponse =
                (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {

            httpResponse.sendRedirect(
                    httpRequest.getContextPath() + "/login.jsp");
            return;
        }

        Object role = session.getAttribute("userRole");

        if (!(role instanceof String)
                || !"ADMIN".equals(role)) {

            httpResponse.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Admin permission is required.");
            return;
        }

        chain.doFilter(request, response);
    }
}
