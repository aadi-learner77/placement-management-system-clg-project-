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
    double studentCgpa = 0.0;

    Connection con = null;
    PreparedStatement cgpaPst = null;
    PreparedStatement jobsPst = null;
    ResultSet cgpaRs = null;
    ResultSet jobsRs = null;

    try {
        con = DBConnection.getConnection();
        
        // Get student's CGPA
        String cgpaQuery = "SELECT cgpa FROM students WHERE student_id = ?";
        cgpaPst = con.prepareStatement(cgpaQuery);
        cgpaPst.setInt(1, userId);
        cgpaRs = cgpaPst.executeQuery();
        if (cgpaRs.next()) {
            studentCgpa = cgpaRs.getDouble("cgpa");
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Board</title>
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
        <a href="jobs.jsp" class="active">Jobs</a>
        <a href="applications.jsp">Applications</a>
        <a href="notifications.jsp">Notifications</a>
    </div>

    <div class="content">
        <h2>Available Job Postings</h2>
        
        <% if (request.getParameter("msg") != null) { %>
            <div class="success-text">
                <%= request.getParameter("msg") %>
            </div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-text">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Company</th>
                        <th>Role</th>
                        <th>Package</th>
                        <th>Min CGPA</th>
                        <th>Required Skills</th>
                        <th>Your Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        String jobsQuery = "SELECT jp.job_id, c.company_name, jp.role, jp.package, jp.min_cgpa, jp.required_skills, a.status AS app_status " +
                                           "FROM job_postings jp JOIN companies c ON jp.company_id = c.company_id " +
                                           "LEFT JOIN applications a ON jp.job_id = a.job_id AND a.student_id = ?";
                        jobsPst = con.prepareStatement(jobsQuery);
                        jobsPst.setInt(1, userId);
                        jobsRs = jobsPst.executeQuery();
                        
                        boolean hasJobs = false;
                        while (jobsRs.next()) {
                            hasJobs = true;
                            int jobId = jobsRs.getInt("job_id");
                            String company = jobsRs.getString("company_name");
                            String jobRole = jobsRs.getString("role");
                            double pkg = jobsRs.getDouble("package");
                            double minCgpa = jobsRs.getDouble("min_cgpa");
                            String skills = jobsRs.getString("required_skills");
                            String appStatus = jobsRs.getString("app_status");
                            
                            boolean isEligible = studentCgpa >= minCgpa;
                %>
                    <tr>
                        <td style="font-weight: 700; color: var(--color-accent);"><%= company %></td>
                        <td><%= jobRole %></td>
                        <td><%= pkg %> LPA</td>
                        <td><%= minCgpa %></td>
                        <td><%= skills != null ? skills : "N/A" %></td>
                        <td>
                            <% if (appStatus != null) { %>
                                <span class="badge badge-<%= appStatus.toLowerCase() %>"><%= appStatus %></span>
                            <% } else { %>
                                <span class="badge <%= isEligible ? "badge-eligible" : "badge-rejected" %>">
                                    <%= isEligible ? "Eligible" : "Ineligible" %>
                                </span>
                            <% } %>
                        </td>
                        <td>
                            <% if (appStatus != null) { %>
                                <button class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.85rem;" disabled>Applied</button>
                            <% } else if (isEligible) { %>
                                <form action="ApplyJobServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="jobId" value="<%= jobId %>">
                                    <button type="submit" class="btn" style="padding: 8px 16px; font-size: 0.85rem; border-radius: 8px;">Apply Now</button>
                                </form>
                            <% } else { %>
                                <button class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.85rem; cursor: not-allowed;" disabled>Low CGPA</button>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                        if (!hasJobs) {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--text-secondary);">No job postings available at the moment.</td>
                    </tr>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (jobsRs != null) jobsRs.close(); } catch(Exception e) {}
                        try { if (jobsPst != null) jobsPst.close(); } catch(Exception e) {}
                        try { if (cgpaRs != null) cgpaRs.close(); } catch(Exception e) {}
                        try { if (cgpaPst != null) cgpaPst.close(); } catch(Exception e) {}
                        try { if (con != null) con.close(); } catch(Exception e) {}
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

</div>

</body>
</html>