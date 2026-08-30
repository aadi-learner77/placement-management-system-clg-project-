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
    
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Job Posting</title>
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
        <a href="add_job.jsp" class="active">Add Job</a>
        <a href="manage_students.jsp">Students</a>
        <a href="shortlist.jsp">Shortlist</a>
    </div>

    <div class="content">
        <h2>Post a New Job Opening</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-text">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        <% if (request.getParameter("msg") != null) { %>
            <div class="success-text">
                <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <div class="box" style="width: 100%;">
            <form action="AddJobServlet" method="post">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    
                    <div class="form-group">
                        <label for="companySelect">Select Registered Company</label>
                        <select id="companySelect" name="companyId">
                            <option value="new" selected>-- Add a New Company instead --</option>
                            <%
                                try {
                                    con = DBConnection.getConnection();
                                    String query = "SELECT * FROM companies ORDER BY company_name";
                                    pst = con.prepareStatement(query);
                                    rs = pst.executeQuery();
                                    while(rs.next()) {
                            %>
                                <option value="<%= rs.getInt("company_id") %>"><%= rs.getString("company_name") %></option>
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
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="newCompanyName">Or Enter New Company Name</label>
                        <input type="text" id="newCompanyName" name="newCompanyName" placeholder="e.g. Apple Inc.">
                    </div>

                </div>

                <div class="form-group">
                    <label for="newCompanyDesc">New Company Description (Only if adding a new company)</label>
                    <textarea id="newCompanyDesc" name="newCompanyDesc" placeholder="Describe the company profile..." style="min-height: 80px;"></textarea>
                </div>

                <hr style="border: 0; border-top: 1px solid var(--glass-border); margin: 10px 0;">

                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label for="role">Job Role / Title</label>
                        <input type="text" id="role" name="role" placeholder="e.g. Software Engineer" required>
                    </div>

                    <div class="form-group">
                        <label for="package">Compensation Package (LPA)</label>
                        <input type="number" step="0.01" id="package" name="package" placeholder="e.g. 12.50" required>
                    </div>

                    <div class="form-group">
                        <label for="minCgpa">Minimum Eligible CGPA</label>
                        <input type="number" step="0.01" min="0" max="10" id="minCgpa" name="minCgpa" placeholder="e.g. 7.50" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="skills">Required Skills (comma-separated)</label>
                    <input type="text" id="skills" name="skills" placeholder="e.g. Java, Python, SQL, REST APIs">
                </div>

                <button type="submit" style="margin-top: 10px; align-self: flex-start;">Post Job Drive</button>
            </form>
        </div>
    </div>

</div>

<script>
    const companySelect = document.getElementById('companySelect');
    const newCompanyName = document.getElementById('newCompanyName');
    const newCompanyDesc = document.getElementById('newCompanyDesc');

    companySelect.addEventListener('change', function() {
        if(this.value === 'new') {
            newCompanyName.required = true;
            newCompanyName.disabled = false;
            newCompanyDesc.disabled = false;
        } else {
            newCompanyName.required = false;
            newCompanyName.disabled = true;
            newCompanyName.value = '';
            newCompanyDesc.disabled = true;
            newCompanyDesc.value = '';
        }
    });

    // trigger once
    companySelect.dispatchEvent(new Event('change'));
</script>

</body>
</html>