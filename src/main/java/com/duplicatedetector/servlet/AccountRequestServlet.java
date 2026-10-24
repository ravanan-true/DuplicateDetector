package com.duplicatedetector.servlet;

import com.duplicatedetector.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

@SuppressWarnings("serial")
@WebServlet("/account-request")
public class AccountRequestServlet extends HttpServlet {
    private void ensureTable() throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS account_status_requests (" +
            "request_id BIGINT PRIMARY KEY AUTO_INCREMENT," +
            "user_id INT NOT NULL, requested_status VARCHAR(20) NOT NULL," +
            "request_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'," +
            "requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "reviewed_at TIMESTAMP NULL, reviewed_by INT NULL," +
            "CONSTRAINT fk_account_request_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE)";
        try (Connection c=DBConnection.getConnection(); Statement s=c.createStatement()) { s.executeUpdate(sql); }
    }
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); String ctx=req.getContextPath(); String action=req.getParameter("action");
        HttpSession session=req.getSession(false);
        try {
            ensureTable();
            if ("review".equals(action)) {
                if(session==null || !"ADMIN".equals(session.getAttribute("userRole"))) { resp.sendError(403); return; }
                int rid=Integer.parseInt(req.getParameter("requestId")); String decision=req.getParameter("decision");
                if(!"APPROVE".equals(decision) && !"REJECT".equals(decision)) { resp.sendRedirect(ctx+"/admin-account-requests.jsp?message=Invalid+action"); return; }
                try(Connection c=DBConnection.getConnection()) {
                    c.setAutoCommit(false);
                    try {
                        int uid; String wanted; String q="SELECT user_id, requested_status FROM account_status_requests WHERE request_id=? AND request_status='PENDING' FOR UPDATE";
                        try(PreparedStatement p=c.prepareStatement(q)){p.setInt(1,rid);try(ResultSet r=p.executeQuery()){if(!r.next()){c.rollback();resp.sendRedirect(ctx+"/admin-account-requests.jsp?message=Request+not+found");return;}uid=r.getInt(1);wanted=r.getString(2);}}
                        if("APPROVE".equals(decision)) try(PreparedStatement p=c.prepareStatement("UPDATE users SET account_status=? WHERE user_id=? AND role='USER'")){p.setString(1,wanted);p.setInt(2,uid);p.executeUpdate();}
                        try(PreparedStatement p=c.prepareStatement("UPDATE account_status_requests SET request_status=?, reviewed_at=CURRENT_TIMESTAMP, reviewed_by=? WHERE request_id=?")){p.setString(1,"APPROVE".equals(decision)?"APPROVED":"REJECTED");p.setInt(2,(Integer)session.getAttribute("userId"));p.setInt(3,rid);p.executeUpdate();}
                        c.commit();
                    } catch(Exception e){c.rollback();throw e;}
                }
                resp.sendRedirect(ctx+"/admin-account-requests.jsp?message=Request+reviewed"); return;
            }
            int uid=-1; String wanted;
            if("DEACTIVATE".equals(action)) {
                if(session==null || session.getAttribute("userId")==null || !"USER".equals(session.getAttribute("userRole"))) {resp.sendError(403);return;}
                uid=(Integer)session.getAttribute("userId"); wanted="INACTIVE";
            } else if("ACTIVATE".equals(action)) {
                String email=req.getParameter("email"); if(email==null || email.isBlank()){resp.sendRedirect(ctx+"/login.jsp?request=invalid");return;}
                try(Connection c=DBConnection.getConnection();PreparedStatement p=c.prepareStatement("SELECT user_id, account_status, role FROM users WHERE email=?")){p.setString(1,email.trim());try(ResultSet r=p.executeQuery()){if(!r.next() || !"USER".equalsIgnoreCase(r.getString("role")) || "ACTIVE".equalsIgnoreCase(r.getString("account_status"))){resp.sendRedirect(ctx+"/login.jsp?request=unavailable");return;}uid=r.getInt("user_id");}}
                wanted="ACTIVE";
            } else {resp.sendError(400);return;}
            try(Connection c=DBConnection.getConnection()) {
                try(PreparedStatement p=c.prepareStatement("SELECT request_id FROM account_status_requests WHERE user_id=? AND request_status='PENDING'")){p.setInt(1,uid);try(ResultSet r=p.executeQuery()){if(r.next()){resp.sendRedirect(ctx+("ACTIVATE".equals(action)?"/login.jsp?request=pending":"/dashboard.jsp?request=pending"));return;}}}
                try(PreparedStatement p=c.prepareStatement("INSERT INTO account_status_requests(user_id,requested_status) VALUES(?,?)")){p.setInt(1,uid);p.setString(2,wanted);p.executeUpdate();}
            }
            resp.sendRedirect(ctx+("ACTIVATE".equals(action)?"/login.jsp?request=sent":"/dashboard.jsp?request=sent"));
        } catch(Exception e){getServletContext().log("Account status request failed",e);resp.sendRedirect(ctx+ ("review".equals(action)?"/admin-account-requests.jsp?message=Database+error":"ACTIVATE".equals(action)?"/login.jsp?request=error":"/dashboard.jsp?request=error"));}
    }
}
