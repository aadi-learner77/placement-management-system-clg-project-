<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, placement_system.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"COORDINATOR".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String name = (String) session.getAttribute("name");
    
    int totalStudents = 0;
    int totalJobs = 0;
    int placedStudents = 0;
    
    Connection con = null;
    PreparedStatement pstStud = null;
    PreparedStatement pstJobs = null;
    PreparedStatement pstPlaced = null;
    ResultSet rsStud = null;
    ResultSet rsJobs = null;
    ResultSet rsPlaced = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Total students
        String qStud = "SELECT COUNT(*) FROM students";
        pstStud = con.prepareStatement(qStud);
        rsStud = pstStud.executeQuery();
        if (rsStud.next()) totalStudents = rsStud.getInt(1);
        
        // Total jobs
        String qJobs = "SELECT COUNT(*) FROM job_postings";
        pstJobs = con.prepareStatement(qJobs);
        rsJobs = pstJobs.executeQuery();
        if (rsJobs.next()) totalJobs = rsJobs.getInt(1);
        
        // Placed students (with status = SELECTED)
        String qPlaced = "SELECT COUNT(DISTINCT student_id) FROM applications WHERE status = 'SELECTED'";
        pstPlaced = con.prepareStatement(qPlaced);
        rsPlaced = pstPlaced.executeQuery();
        if (rsPlaced.next()) placedStudents = rsPlaced.getInt(1);
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rsStud != null) rsStud.close(); } catch(Exception e) {}
        try { if (pstStud != null) pstStud.close(); } catch(Exception e) {}
        try { if (rsJobs != null) rsJobs.close(); } catch(Exception e) {}
        try { if (pstJobs != null) pstJobs.close(); } catch(Exception e) {}
        try { if (rsPlaced != null) rsPlaced.close(); } catch(Exception e) {}
        try { if (pstPlaced != null) pstPlaced.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Coordinator Dashboard</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="navbar">
    <h2>Coordinator Portal</h2>
    <div class="nav-links">
        <span style="font-weight: 600; color: var(--text-primary);">Welcome, <%= name %></span>
        <a href="LogoutServlet" class="btn-logout">Logout</a>
    </div>
</div>

<div class="dashboard">

    <div class="menu">
        <a href="coordinator_dashboard.jsp" class="active">Dashboard</a>
        <a href="add_job.jsp">Add Job</a>
        <a href="manage_students.jsp">Students</a>
        <a href="shortlist.jsp">Shortlist</a>
    </div>

    <div class="content">
        <h2>Dashboard Overview</h2>
        
        <div class="stats-grid">
            <div class="box">
                <h3>Total Students</h3>
                <p><%= totalStudents %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Registered student profiles</span>
            </div>

            <div class="box">
                <h3>Total Job Openings</h3>
                <p><%= totalJobs %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Active recruitment drives</span>
            </div>

            <div class="box">
                <h3>Placed Students</h3>
                <p><%= placedStudents %></p>
                <span style="color: var(--text-secondary); font-size: 0.85rem;">Selected in at least 1 drive</span>
            </div>
        </div>
        
        <div class="box" style="margin-top: 20px;">
            <h3 style="color: var(--color-accent); font-size: 1.1rem; margin-bottom: 12px;">Coordinator Quick Actions</h3>
            <div style="display: flex; gap: 15px; flex-wrap: wrap; margin-top: 15px;">
                <a href="add_job.jsp" class="btn">Post a New Job</a>
                <a href="manage_students.jsp" class="btn btn-secondary">Search Students</a>
                <a href="shortlist.jsp" class="btn btn-secondary" style="border-color: var(--color-accent); color: var(--color-accent);">Screen Applications</a>
            </div>
        </div>
    </div>

</div>

</body>
</html>