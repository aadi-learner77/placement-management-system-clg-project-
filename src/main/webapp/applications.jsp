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
    PreparedStatement pst = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Applications</title>
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
        <a href="applications.jsp" class="active">Applications</a>
        <a href="notifications.jsp">Notifications</a>
    </div>

    <div class="content">
        <h2>My Applications</h2>
        
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Company</th>
                        <th>Role</th>
                        <th>Package</th>
                        <th>Min CGPA</th>
                        <th>Application Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        con = DBConnection.getConnection();
                        String query = "SELECT c.company_name, jp.role, jp.package, jp.min_cgpa, a.status " +
                                       "FROM applications a " +
                                       "JOIN job_postings jp ON a.job_id = jp.job_id " +
                                       "JOIN companies c ON jp.company_id = c.company_id " +
                                       "WHERE a.student_id = ? " +
                                       "ORDER BY a.application_id DESC";
                        pst = con.prepareStatement(query);
                        pst.setInt(1, userId);
                        rs = pst.executeQuery();
                        
                        boolean hasApp = false;
                        while(rs.next()) {
                            hasApp = true;
                            String company = rs.getString("company_name");
                            String jobRole = rs.getString("role");
                            double pkg = rs.getDouble("package");
                            double minCgpa = rs.getDouble("min_cgpa");
                            String status = rs.getString("status");
                %>
                    <tr>
                        <td style="font-weight: 700; color: var(--color-accent);"><%= company %></td>
                        <td><%= jobRole %></td>
                        <td><%= pkg %> LPA</td>
                        <td><%= minCgpa %></td>
                        <td>
                            <span class="badge badge-<%= status.toLowerCase() %>"><%= status %></span>
                        </td>
                    </tr>
                <%
                        }
                        
                        if(!hasApp) {
                %>
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--text-secondary);">You have not applied for any jobs yet.</td>
                    </tr>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); } catch(Exception e) {}
                        try { if (pst != null) pst.close(); } catch(Exception e) {}
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