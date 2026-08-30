<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, placement_system.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"STUDENT".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String name = (String) session.getAttribute("name");
    
    Connection con = null;
    PreparedStatement pstStatus = null;
    PreparedStatement pstNew = null;
    ResultSet rsStatus = null;
    ResultSet rsNew = null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Notifications</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="navbar">
    <h2>Student Portal</h2>
    <div class="nav-links">
        <span style="font-weight: 600; color: var(--text-primary);">Welcome, <%= name %></span>
        <a href="LogoutServlet" class="btn-logout">Logout</a>
    </div>
</div>

<div class="dashboard">

    <div class="menu">
        <a href="student_dashboard.jsp">Dashboard</a>
        <a href="profile.jsp">Profile</a>
        <a href="jobs.jsp">Jobs</a>
        <a href="applications.jsp">Applications</a>
        <a href="notifications.jsp" class="active">Notifications</a>
    </div>

    <div class="content">
        <h2>Notifications</h2>
        
        <div class="notification-list">
        <%
            int count = 0;
            try {
                con = DBConnection.getConnection();
                
                // 1. Get status changes
                String qStatus = "SELECT c.company_name, jp.role, a.status FROM applications a " +
                                 "JOIN job_postings jp ON a.job_id = jp.job_id " +
                                 "JOIN companies c ON jp.company_id = c.company_id " +
                                 "WHERE a.student_id = ? AND a.status IN ('SHORTLISTED', 'SELECTED', 'REJECTED')";
                pstStatus = con.prepareStatement(qStatus);
                pstStatus.setInt(1, userId);
                rsStatus = pstStatus.executeQuery();
                
                while(rsStatus.next()) {
                    count++;
                    String company = rsStatus.getString("company_name");
                    String jobRole = rsStatus.getString("role");
                    String status = rsStatus.getString("status");
                    
                    String message = "";
                    String borderClass = "blue";
                    String emoji = "🔔";
                    if("SELECTED".equals(status)) {
                        message = "Congratulations! You have been <strong>SELECTED</strong> at " + company + " for " + jobRole + "!";
                        borderClass = "var(--color-success)";
                        emoji = "🎉";
                    } else if ("SHORTLISTED".equals(status)) {
                        message = "Great news! You have been <strong>SHORTLISTED</strong> for the interview process at " + company + " (" + jobRole + "). Schedule details will follow.";
                        borderClass = "var(--color-info)";
                        emoji = "🚀";
                    } else {
                        message = "Update: Your application for the " + jobRole + " role at " + company + " was not selected. Don't lose hope, keep applying!";
                        borderClass = "var(--color-danger)";
                        emoji = "📉";
                    }
        %>
            <div class="notification" style="border-left-color: <%= borderClass %>;">
                <span class="notification-icon"><%= emoji %></span>
                <div>
                    <p style="color: var(--text-primary);"><%= message %></p>
                    <span style="font-size: 0.8rem; color: var(--text-secondary);">Recruitment Drive Alert</span>
                </div>
            </div>
        <%
                }
                
                // 2. Get new eligible jobs
                String qNew = "SELECT c.company_name, jp.role, jp.package FROM job_postings jp " +
                              "JOIN companies c ON jp.company_id = c.company_id " +
                              "WHERE jp.min_cgpa <= (SELECT cgpa FROM students WHERE student_id = ?) " +
                              "AND jp.job_id NOT IN (SELECT job_id FROM applications WHERE student_id = ?)";
                pstNew = con.prepareStatement(qNew);
                pstNew.setInt(1, userId);
                pstNew.setInt(2, userId);
                rsNew = pstNew.executeQuery();
                
                while(rsNew.next()) {
                    count++;
                    String company = rsNew.getString("company_name");
                    String jobRole = rsNew.getString("role");
                    double pkg = rsNew.getDouble("package");
        %>
            <div class="notification" style="border-left-color: var(--color-accent);">
                <span class="notification-icon">🔥</span>
                <div>
                    <p style="color: var(--text-primary);">New Job Opportunity: You are eligible for <strong><%= company %></strong> - <strong><%= jobRole %></strong> (Package: <%= pkg %> LPA). Apply now!</p>
                    <span style="font-size: 0.8rem; color: var(--text-secondary);">Eligibility Alert</span>
                </div>
            </div>
        <%
                }
                
                if (count == 0) {
        %>
            <div class="box" style="text-align: center; padding: 40px;">
                <p>No new notifications at this time. Check back later!</p>
            </div>
        <%
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                try { if (rsStatus != null) rsStatus.close(); } catch(Exception e) {}
                try { if (pstStatus != null) pstStatus.close(); } catch(Exception e) {}
                try { if (rsNew != null) rsNew.close(); } catch(Exception e) {}
                try { if (pstNew != null) pstNew.close(); } catch(Exception e) {}
                try { if (con != null) con.close(); } catch(Exception e) {}
            }
        %>
        </div>
    </div>

</div>

</body>
</html>