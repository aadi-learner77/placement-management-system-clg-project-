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
    
    // Retrieve filter parameters
    String filterBranch = request.getParameter("branch");
    String filterCgpaStr = request.getParameter("minCgpa");
    String searchQuery = request.getParameter("search");
    
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Students</title>
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
        <a href="coordinator_dashboard.jsp">Dashboard</a>
        <a href="add_job.jsp">Add Job</a>
        <a href="manage_students.jsp" class="active">Students</a>
        <a href="shortlist.jsp">Shortlist</a>
    </div>

    <div class="content">
        <h2>Student Profiles Directory</h2>
        
        <!-- Filters Box -->
        <div class="box" style="width: 100%;">
            <form method="get" action="manage_students.jsp" style="flex-direction: row; gap: 15px; flex-wrap: wrap; align-items: flex-end;">
                <div class="form-group" style="flex: 1; min-width: 200px;">
                    <label>Search Name / USN</label>
                    <input type="text" name="search" value="<%= searchQuery != null ? searchQuery : "" %>" placeholder="Type name or USN...">
                </div>

                <div class="form-group" style="width: 180px;">
                    <label>Filter Branch</label>
                    <select name="branch">
                        <option value="">All Branches</option>
                        <option value="Computer Science" <%= "Computer Science".equals(filterBranch) ? "selected" : "" %>>Computer Science</option>
                        <option value="Information Science" <%= "Information Science".equals(filterBranch) ? "selected" : "" %>>Information Science</option>
                        <option value="Electronics" <%= "Electronics".equals(filterBranch) ? "selected" : "" %>>Electronics</option>
                        <option value="Mechanical" <%= "Mechanical".equals(filterBranch) ? "selected" : "" %>>Mechanical</option>
                        <option value="Civil" <%= "Civil".equals(filterBranch) ? "selected" : "" %>>Civil</option>
                    </select>
                </div>

                <div class="form-group" style="width: 120px;">
                    <label>Min CGPA</label>
                    <input type="number" step="0.1" name="minCgpa" value="<%= filterCgpaStr != null ? filterCgpaStr : "" %>" placeholder="e.g. 8.0" min="0" max="10">
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn" style="padding: 12px 20px;">Apply</button>
                    <a href="manage_students.jsp" class="btn btn-secondary" style="padding: 12px 20px;">Reset</a>
                </div>
            </form>
        </div>

        <!-- Student Listing Table -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>USN</th>
                        <th>Student Name</th>
                        <th>Email</th>
                        <th>Branch</th>
                        <th>CGPA</th>
                        <th>Sem</th>
                        <th>Skills</th>
                        <th>Resume</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        con = DBConnection.getConnection();
                        
                        StringBuilder sql = new StringBuilder("SELECT u.name, u.email, u.usn, s.branch, s.current_sem, s.cgpa, s.skills, s.resume_path " +
                                                              "FROM users u JOIN students s ON u.user_id = s.student_id WHERE 1=1 ");
                        
                        if (filterBranch != null && !filterBranch.isEmpty()) {
                            sql.append("AND s.branch = ? ");
                        }
                        if (filterCgpaStr != null && !filterCgpaStr.isEmpty()) {
                            sql.append("AND s.cgpa >= ? ");
                        }
                        if (searchQuery != null && !searchQuery.isEmpty()) {
                            sql.append("AND (u.name LIKE ? OR u.usn LIKE ?) ");
                        }
                        
                        sql.append("ORDER BY u.name");
                        
                        pst = con.prepareStatement(sql.toString());
                        int paramIndex = 1;
                        
                        if (filterBranch != null && !filterBranch.isEmpty()) {
                            pst.setString(paramIndex++, filterBranch);
                        }
                        if (filterCgpaStr != null && !filterCgpaStr.isEmpty()) {
                            pst.setDouble(paramIndex++, Double.parseDouble(filterCgpaStr));
                        }
                        if (searchQuery != null && !searchQuery.isEmpty()) {
                            String searchPattern = "%" + searchQuery + "%";
                            pst.setString(paramIndex++, searchPattern);
                            pst.setString(paramIndex++, searchPattern);
                        }
                        
                        rs = pst.executeQuery();
                        
                        boolean hasData = false;
                        while(rs.next()) {
                            hasData = true;
                            String studentUsn = rs.getString("usn");
                            String sName = rs.getString("name");
                            String email = rs.getString("email");
                            String sBranch = rs.getString("branch");
                            double sCgpa = rs.getDouble("cgpa");
                            int sSem = rs.getInt("current_sem");
                            String sSkills = rs.getString("skills");
                            String resume = rs.getString("resume_path");
                %>
                    <tr>
                        <td style="font-family: monospace; font-weight: bold;"><%= studentUsn %></td>
                        <td style="font-weight: 600;"><%= sName %></td>
                        <td><%= email %></td>
                        <td><%= sBranch %></td>
                        <td style="color: var(--color-accent); font-weight: 700;"><%= sCgpa %></td>
                        <td><%= sSem %></td>
                        <td style="font-size: 0.85rem; max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<%= sSkills != null ? sSkills : "" %>">
                            <%= sSkills != null && !sSkills.isEmpty() ? sSkills : "-" %>
                        </td>
                        <td>
                            <% if (resume != null && !resume.isEmpty()) { %>
                                <a href="uploads/<%= resume %>" target="_blank" class="btn" style="padding: 6px 12px; font-size: 0.8rem; border-radius: 6px; text-decoration: none;">View PDF</a>
                            <% } else { %>
                                <span style="font-size: 0.85rem; color: var(--text-secondary);">No file</span>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                        
                        if(!hasData) {
                %>
                    <tr>
                        <td colspan="8" style="text-align: center; color: var(--text-secondary);">No student profiles found matching the filters.</td>
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
