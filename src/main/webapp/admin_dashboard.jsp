<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*, placement_system.DBConnection" %>
        <% Integer userId=(Integer) session.getAttribute("user_id"); String role=(String) session.getAttribute("role");
            if (userId==null || !"ADMIN".equalsIgnoreCase(role)) { response.sendRedirect("login.jsp"); return; } String
            name=(String) session.getAttribute("name"); int totalStudents=0, totalCompanies=0, placedStudents=0,
            placementRate=0; Connection con=DBConnection.getConnection(); try { PreparedStatement ps; ResultSet rs;
            ps=con.prepareStatement("SELECT COUNT(*) FROM students"); rs=ps.executeQuery(); if (rs.next())
            totalStudents=rs.getInt(1); rs.close(); ps.close(); ps=con.prepareStatement("SELECT COUNT(*) FROM
            companies"); rs=ps.executeQuery(); if (rs.next()) totalCompanies=rs.getInt(1); rs.close(); ps.close();
            ps=con.prepareStatement("SELECT COUNT(DISTINCT student_id) FROM applications WHERE status='SELECTED'"); rs = ps.executeQuery();
    if (rs.next()) placedStudents = rs.getInt(1); rs.close(); ps.close();
    if (totalStudents > 0) placementRate = (int) Math.round(((double) placedStudents / totalStudents) * 100);
} catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset=" UTF-8">
            <title>Admin Dashboard</title>
            <link rel="stylesheet" href="css/style.css">
            <style>
                .tabs-nav {
                    display: flex;
                    border-bottom: 2px solid var(--glass-border);
                    margin-bottom: 20px;
                    gap: 15px;
                }

                .tab-link {
                    color: var(--text-secondary);
                    background: none;
                    border: none;
                    padding: 12px 20px;
                    font-weight: 700;
                    cursor: pointer;
                    transition: all var(--transition-fast);
                    border-bottom: 3px solid transparent;
                    box-shadow: none;
                    border-radius: 0;
                }

                .tab-link:hover {
                    color: var(--text-primary);
                    transform: none;
                    box-shadow: none;
                }

                .tab-link.active {
                    color: var(--color-accent);
                    border-bottom-color: var(--color-accent);
                }

                .tab-content {
                    display: none;
                }

                .tab-content.active {
                    display: block;
                }

                .btn-sm-danger {
                    padding: 6px 12px;
                    font-size: 0.75rem;
                    border-radius: 6px;
                    background: var(--color-danger);
                    border-color: var(--color-danger);
                }

                .btn-sm-success {
                    padding: 6px 12px;
                    font-size: 0.75rem;
                    border-radius: 6px;
                    background: var(--color-success);
                    border-color: var(--color-success);
                }
            </style>
            </head>

            <body>
                <div class="navbar">
                    <h2>Admin Dashboard</h2>
                    <div class="nav-links">
                        <span style="font-weight:600;color:var(--text-primary);">Welcome, <%= name %></span>
                        <a href="LogoutServlet" class="btn-logout">Logout</a>
                    </div>
                </div>
                <div class="dashboard">
                    <div class="menu" style="width:200px;">
                        <a href="admin_dashboard.jsp" class="active">Overview</a>
                        <a href="LogoutServlet">Logout</a>
                    </div>
                    <div class="content">
                        <h2>System Performance &amp; Controls</h2>
                        <% if (request.getParameter("msg") !=null) { %>
                            <div class="success-text">
                                <%= request.getParameter("msg") %>
                            </div>
                            <% } %>
                                <% if (request.getParameter("error") !=null) { %>
                                    <div class="error-text">
                                        <%= request.getParameter("error") %>
                                    </div>
                                    <% } %>
                                        <div class="stats-grid">
                                            <div class="box">
                                                <h3>Total Students</h3>
                                                <p>
                                                    <%= totalStudents %>
                                                </p><span
                                                    style="color:var(--text-secondary);font-size:0.85rem;">Registered
                                                    student profiles</span>
                                            </div>
                                            <div class="box">
                                                <h3>Total Companies</h3>
                                                <p>
                                                    <%= totalCompanies %>
                                                </p><span
                                                    style="color:var(--text-secondary);font-size:0.85rem;">Corporate
                                                    partners</span>
                                            </div>
                                            <div class="box">
                                                <h3>Placement Rate</h3>
                                                <p>
                                                    <%= placementRate %>%
                                                </p><span style="color:var(--text-secondary);font-size:0.85rem;">
                                                    <%= placedStudents %> placed students
                                                </span>
                                            </div>
                                        </div>
                                        <div class="tabs-nav" style="margin-top:20px;">
                                            <button class="tab-link active" onclick="switchTab(event,'usersTab')">User
                                                Accounts</button>
                                            <button class="tab-link" onclick="switchTab(event,'companiesTab')">Companies
                                                List</button>
                                            <button class="tab-link" onclick="switchTab(event,'jobsTab')">Job
                                                Postings</button>
                                        </div>
                                        <div id="usersTab" class="tab-content active">
                                            <div class="table-container">
                                                <table>
                                                    <thead>
                                                        <tr>
                                                            <th>User ID</th>
                                                            <th>USN</th>
                                                            <th>Name</th>
                                                            <th>Email</th>
                                                            <th>Role</th>
                                                            <th>Status</th>
                                                            <th>Action</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% try { PreparedStatement pstU=con.prepareStatement("SELECT *
                                                            FROM users ORDER BY role, name"); ResultSet
                                                            rsU=pstU.executeQuery(); while (rsU.next()) { int
                                                            uId=rsU.getInt("user_id"); String uUsn=rsU.getString("usn");
                                                            String uName=rsU.getString("name"); String
                                                            uEmail=rsU.getString("email"); String
                                                            uRole=rsU.getString("role"); boolean
                                                            active=rsU.getBoolean("is_active"); String badgeClass=active
                                                            ? "badge badge-eligible" : "badge badge-rejected" ; String
                                                            badgeLabel=active ? "Active" : "Inactive" ; String
                                                            btnAction=active ? "deactivate" : "activate" ; String
                                                            btnClass=active ? "btn btn-sm-danger" : "btn btn-sm-success"
                                                            ; String btnLabel=active ? "Deactivate" : "Activate" ; %>
                                                            <tr>
                                                                <td>
                                                                    <%= uId %>
                                                                </td>
                                                                <td style="font-family:monospace;">
                                                                    <%= uUsn !=null ? uUsn : "-" %>
                                                                </td>
                                                                <td style="font-weight:600;">
                                                                    <%= uName %>
                                                                </td>
                                                                <td>
                                                                    <%= uEmail %>
                                                                </td>
                                                                <td><span style="font-weight:bold;font-size:0.85rem;">
                                                                        <%= uRole %>
                                                                    </span></td>
                                                                <td><span class="<%= badgeClass %>">
                                                                        <%= badgeLabel %>
                                                                    </span></td>
                                                                <td>
                                                                    <% if (uId !=userId) { %>
                                                                        <form action="ToggleUserServlet" method="post"
                                                                            style="display:inline;">
                                                                            <input type="hidden" name="userId"
                                                                                value="<%= uId %>">
                                                                            <input type="hidden" name="action"
                                                                                value="<%= btnAction %>">
                                                                            <button type="submit"
                                                                                class="<%= btnClass %>">
                                                                                <%= btnLabel %>
                                                                            </button>
                                                                        </form>
                                                                        <% } else { %>
                                                                            <span
                                                                                style="font-size:0.85rem;color:var(--text-secondary);">Logged
                                                                                In</span>
                                                                            <% } %>
                                                                </td>
                                                            </tr>
                                                            <% } rsU.close(); pstU.close(); } catch (Exception e) {
                                                                e.printStackTrace(); } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div id="companiesTab" class="tab-content">
                                            <div
                                                style="display:grid;grid-template-columns:2fr 1fr;gap:30px;align-items:start;">
                                                <div class="table-container">
                                                    <table>
                                                        <thead>
                                                            <tr>
                                                                <th>ID</th>
                                                                <th>Company Name</th>
                                                                <th>Description</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <% try { PreparedStatement pstC=con.prepareStatement("SELECT
                                                                * FROM companies ORDER BY company_name"); ResultSet
                                                                rsC=pstC.executeQuery(); boolean hasComps=false; while
                                                                (rsC.next()) { hasComps=true; int
                                                                cId=rsC.getInt("company_id"); String
                                                                cName=rsC.getString("company_name"); String
                                                                cDesc=rsC.getString("description"); if (cDesc==null)
                                                                cDesc="" ; %>
                                                                <tr>
                                                                    <td>
                                                                        <%= cId %>
                                                                    </td>
                                                                    <td
                                                                        style="font-weight:700;color:var(--color-accent);">
                                                                        <%= cName %>
                                                                    </td>
                                                                    <td style="font-size:0.9rem;">
                                                                        <%= cDesc %>
                                                                    </td>
                                                                </tr>
                                                                <% } if (!hasComps) { %>
                                                                    <tr>
                                                                        <td colspan="3"
                                                                            style="text-align:center;color:var(--text-secondary);">
                                                                            No companies registered yet.</td>
                                                                    </tr>
                                                                    <% } rsC.close(); pstC.close(); } catch (Exception
                                                                        e) { e.printStackTrace(); } %>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <div class="box">
                                                    <h3>Register Company</h3>
                                                    <form action="AddCompanyServlet" method="post"
                                                        style="margin-top:15px;">
                                                        <div class="form-group"><label for="companyName">Company
                                                                Name</label><input type="text" id="companyName"
                                                                name="companyName" placeholder="e.g. Netflix" required>
                                                        </div>
                                                        <div class="form-group"><label for="description">Brief
                                                                Description</label><textarea id="description"
                                                                name="description"
                                                                placeholder="Specify sector, domain..." required
                                                                style="min-height:80px;"></textarea></div>
                                                        <button type="submit">Add Company</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="jobsTab" class="tab-content">
                                            <div class="table-container">
                                                <table>
                                                    <thead>
                                                        <tr>
                                                            <th>Job ID</th>
                                                            <th>Company</th>
                                                            <th>Role</th>
                                                            <th>Package</th>
                                                            <th>Min CGPA</th>
                                                            <th>Total Applicants</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% try { String
                                                            qJS="SELECT jp.job_id, c.company_name, jp.role, jp.package, jp.min_cgpa, (SELECT COUNT(*) FROM applications WHERE job_id=jp.job_id) AS applicants FROM job_postings jp JOIN companies c ON jp.company_id=c.company_id ORDER BY jp.job_id DESC"
                                                            ; PreparedStatement pstJ=con.prepareStatement(qJS);
                                                            ResultSet rsJ=pstJ.executeQuery(); boolean hasJobs=false;
                                                            while (rsJ.next()) { hasJobs=true; int
                                                            jId=rsJ.getInt("job_id"); String
                                                            cName=rsJ.getString("company_name"); String
                                                            jRole=rsJ.getString("role"); double
                                                            pkg=rsJ.getDouble("package"); double
                                                            minCgpa=rsJ.getDouble("min_cgpa"); int
                                                            applicants=rsJ.getInt("applicants"); %>
                                                            <tr>
                                                                <td>
                                                                    <%= jId %>
                                                                </td>
                                                                <td style="font-weight:700;color:var(--color-accent);">
                                                                    <%= cName %>
                                                                </td>
                                                                <td>
                                                                    <%= jRole %>
                                                                </td>
                                                                <td>
                                                                    <%= pkg %> LPA
                                                                </td>
                                                                <td>
                                                                    <%= minCgpa %>
                                                                </td>
                                                                <td style="font-weight:bold;color:var(--color-info);">
                                                                    <%= applicants %> candidates
                                                                </td>
                                                            </tr>
                                                            <% } if (!hasJobs) { %>
                                                                <tr>
                                                                    <td colspan="6"
                                                                        style="text-align:center;color:var(--text-secondary);">
                                                                        No job postings registered yet.</td>
                                                                </tr>
                                                                <% } rsJ.close(); pstJ.close(); } catch (Exception e) {
                                                                    e.printStackTrace(); } finally { try { if (con
                                                                    !=null) con.close(); } catch (Exception e) {} } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                    </div>
                </div>
                <script>
                    function switchTab(evt, tabId) {
                        var c = document.getElementsByClassName("tab-content");
                        for (var i = 0; i < c.length; i++)c[i].classList.remove("active");
                        var l = document.getElementsByClassName("tab-link");
                        for (var i = 0; i < l.length; i++)l[i].classList.remove("active");
                        document.getElementById(tabId).classList.add("active");
                        evt.currentTarget.classList.add("active");
                    }
                </script>
            </body>

            </html>