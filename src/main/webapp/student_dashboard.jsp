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
    
    int totalApplications = 0;
    int eligibleJobs = 0;
    int selectedCompanies = 0;
    
    Connection con = null;
    PreparedStatement pstApp = null;
    PreparedStatement pstElig = null;
    PreparedStatement pstSel = null;
    ResultSet rsApp = null;
    ResultSet rsElig = null;
    ResultSet rsSel = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Total applications
        String qApp = "SELECT COUNT(*) FROM applications WHERE student_id = ?";
        pstApp = con.prepareStatement(qApp);
        pstApp.setInt(1, userId);
        rsApp = pstApp.executeQuery();
        if (rsApp.next()) totalApplications = rsApp.getInt(1);
        
        // Eligible Jobs based on CGPA
        String qElig = "SELECT COUNT(*) FROM job_postings WHERE min_cgpa <= (SELECT cgpa FROM students WHERE student_id = ?)";
        pstElig = con.prepareStatement(qElig);
        pstElig.setInt(1, userId);
        rsElig = pstElig.executeQuery();
        if (rsElig.next()) eligibleJobs = rsElig.getInt(1);
        
        // Selected Companies
        String qSel = "SELECT COUNT(*) FROM applications WHERE student_id = ? AND status = 'SELECTED'";
        pstSel = con.prepareStatement(qSel);
        pstSel.setInt(1, userId);
        rsSel = pstSel.executeQuery();
        if (rsSel.next()) selectedCompanies = rsSel.getInt(1);
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rsApp != null) rsApp.close(); } catch(Exception e) {}
        try { if (pstApp != null) pstApp.close(); } catch(Exception e) {}
        try { if (rsElig != null) rsElig.close(); } catch(Exception e) {}
        try { if (pstElig != null) pstElig.close(); } catch(Exception e) {}
        try { if (rsSel != null) rsSel.close(); } catch(Exception e) {}
        try { if (pstSel != null) pstSel.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Student Dashboard</title>
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
        <a href="student_dashboard.jsp" class="active">Dashboard</a>
        <a href="profile.jsp">Profile</a>
        <a href="jobs.jsp">Jobs</a>
        <a href="applications.jsp">Applications</a>
        <a href="notifications.jsp">Notifications</a>
    </div>

    <div class="content">
        <h2>Dashboard Overview</h2>
        
        <div class="stats-grid">
            <div class="box">
                <h3>Total Applications</h3>
                <p><%= totalApplications %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Jobs you have applied for</span>
            </div>

            <div class="box">
                <h3>Eligible Jobs</h3>
                <p><%= eligibleJobs %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Based on your current CGPA</span>
            </div>

            <div class="box">
                <h3>Selected Offers</h3>
                <p><%= selectedCompanies %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Successful selections</span>
            </div>
        </div>
        
        <div class="box" style="margin-top: 20px;">
            <h3 style="color: var(--color-accent); font-size: 1.1rem; margin-bottom: 12px;">Quick Start Guide</h3>
            <p style="margin-bottom: 12px;">To maximize your placement opportunities, follow these simple steps:</p>
            <ol style="margin-left: 20px; color: var(--text-secondary); display: flex; flex-direction: column; gap: 8px;">
                <li>Complete your profile inside the <strong>Profile</strong> tab, specifying your skills and upload your resume.</li>
                <li>Go to the <strong>Jobs</strong> tab to scan all open job drives and see your eligibility status.</li>
                <li>Apply for jobs with a single click. Keep track of status updates inside the <strong>Applications</strong> page.</li>
            </ol>
        </div>
    </div>

</div>

</body>
</html>
