<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, placement_system.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"STUDENT".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String name = "";
    String branch = "";
    int sem = 1;
    double cgpa = 0.0;
    int gradYear = 2026;
    String skills = "";
    String projects = "";
    String experience = "";
    String resumePath = null;
    String certPath = null;

    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String query = "SELECT u.name, s.branch, s.current_sem, s.cgpa, s.graduation_year, s.skills, s.projects, s.experience, s.resume_path, s.certificates_path " +
                       "FROM users u JOIN students s ON u.user_id = s.student_id WHERE u.user_id = ?";
        pst = con.prepareStatement(query);
        pst.setInt(1, userId);
        rs = pst.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            branch = rs.getString("branch");
            sem = rs.getInt("current_sem");
            cgpa = rs.getDouble("cgpa");
            gradYear = rs.getInt("graduation_year");
            skills = rs.getString("skills") != null ? rs.getString("skills") : "";
            projects = rs.getString("projects") != null ? rs.getString("projects") : "";
            experience = rs.getString("experience") != null ? rs.getString("experience") : "";
            resumePath = rs.getString("resume_path");
            certPath = rs.getString("certificates_path");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (pst != null) pst.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Student Profile</title>
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
        <a href="profile.jsp" class="active">Profile</a>
        <a href="jobs.jsp">Jobs</a>
        <a href="applications.jsp">Applications</a>
        <a href="notifications.jsp">Notifications</a>
    </div>

    <div class="content">
        <h2>My Profile</h2>

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
            <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="name" value="<%= name %>" required>
                    </div>

                    <div class="form-group">
                        <label>Branch / Department</label>
                        <select name="branch" required>
                            <option value="Computer Science" <%= "Computer Science".equals(branch) ? "selected" : "" %>>Computer Science</option>
                            <option value="Information Science" <%= "Information Science".equals(branch) ? "selected" : "" %>>Information Science</option>
                            <option value="Electronics" <%= "Electronics".equals(branch) ? "selected" : "" %>>Electronics</option>
                            <option value="Mechanical" <%= "Mechanical".equals(branch) ? "selected" : "" %>>Mechanical</option>
                            <option value="Civil" <%= "Civil".equals(branch) ? "selected" : "" %>>Civil</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Current CGPA</label>
                        <input type="number" step="0.01" min="0" max="10" name="cgpa" value="<%= cgpa %>" required>
                    </div>

                    <div class="form-group">
                        <label>Current Semester</label>
                        <input type="number" min="1" max="8" name="sem" value="<%= sem %>" required>
                    </div>

                    <div class="form-group">
                        <label>Graduation Year</label>
                        <input type="number" min="2020" max="2035" name="gradYear" value="<%= gradYear %>" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Key Skills (comma-separated)</label>
                    <input type="text" name="skills" value="<%= skills %>" placeholder="e.g. Java, SQL, Python, Git">
                </div>

                <div class="form-group">
                    <label>Academic Projects</label>
                    <textarea name="projects" placeholder="Describe your college projects..."><%= projects %></textarea>
                </div>

                <div class="form-group">
                    <label>Work Experience / Internships</label>
                    <textarea name="experience" placeholder="Describe prior internships or experiences..."><%= experience %></textarea>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label>Upload Resume (PDF only)</label>
                        <input type="file" name="resume" accept="application/pdf">
                        <% if (resumePath != null && !resumePath.isEmpty()) { %>
                            <span style="font-size: 0.85rem; color: var(--color-accent); margin-top: 5px;">
                                Current Resume: <a href="uploads/<%= resumePath %>" target="_blank" style="color: var(--color-accent); text-decoration: underline;">View Resume</a>
                            </span>
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label>Upload Certificates (PDF only)</label>
                        <input type="file" name="certificates" accept="application/pdf">
                        <% if (certPath != null && !certPath.isEmpty()) { %>
                            <span style="font-size: 0.85rem; color: var(--color-accent); margin-top: 5px;">
                                Current Certificates: <a href="uploads/<%= certPath %>" target="_blank" style="color: var(--color-accent); text-decoration: underline;">View Certificates</a>
                            </span>
                        <% } %>
                    </div>
                </div>

                <button type="submit" style="margin-top: 20px; align-self: flex-start; min-width: 200px;">Save Profile</button>
            </form>
        </div>
    </div>

</div>

</body>
</html>