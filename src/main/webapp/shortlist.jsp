<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, placement_system.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"COORDINATOR".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String name = (String) session.getAttribute("name");
    
    String jobIdParam = request.getParameter("jobId");
    int selectedJobId = -1;
    if (jobIdParam != null && !jobIdParam.isEmpty()) {
        selectedJobId = Integer.parseInt(jobIdParam);
    }
    
    Connection con = null;
    PreparedStatement pstJobs = null;
    PreparedStatement pstJobDetail = null;
    PreparedStatement pstApplied = null;
    PreparedStatement pstEligible = null;
    ResultSet rsJobs = null;
    ResultSet rsJobDetail = null;
    ResultSet rsApplied = null;
    ResultSet rsEligible = null;

    double jobMinCgpa = 0.0;
    String jobSkills = "";
    String jobCompany = "";
    String jobRole = "";

    try {
        con = DBConnection.getConnection();
        
        // 1. Get job details if selected
        if (selectedJobId != -1) {
            String qDetail = "SELECT jp.min_cgpa, jp.required_skills, c.company_name, jp.role FROM job_postings jp " +
                             "JOIN companies c ON jp.company_id = c.company_id WHERE jp.job_id = ?";
            pstJobDetail = con.prepareStatement(qDetail);
            pstJobDetail.setInt(1, selectedJobId);
            rsJobDetail = pstJobDetail.executeQuery();
            if (rsJobDetail.next()) {
                jobMinCgpa = rsJobDetail.getDouble("min_cgpa");
                jobSkills = rsJobDetail.getString("required_skills");
                if (jobSkills == null) jobSkills = "";
                jobCompany = rsJobDetail.getString("company_name");
                jobRole = rsJobDetail.getString("role");
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<%!
    // Helper method to calculate skill match percentage
    private int calculateMatch(String studentSkills, String jobSkills) {
        if(jobSkills == null || jobSkills.trim().isEmpty()) {
            return 100; // No requirements -> 100% match
        }
        if(studentSkills == null || studentSkills.trim().isEmpty()) {
            return 0; // Requirements exist, student has no skills
        }
        
        String[] jArr = jobSkills.toLowerCase().split("\\s*,\\s*");
        String[] sArr = studentSkills.toLowerCase().split("\\s*,\\s*");
        
        Set<String> sSet = new HashSet<>(Arrays.asList(sArr));
        int matches = 0;
        for(String js : jArr) {
            // Partial match check
            for(String ss : sSet) {
                if(ss.contains(js) || js.contains(ss)) {
                    matches++;
                    break;
                }
            }
        }
        
        return (int) Math.round(((double) matches / jArr.length) * 100);
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Shortlist Candidates</title>
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
</style>
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
        <a href="manage_students.jsp">Students</a>
        <a href="shortlist.jsp" class="active">Shortlist</a>
    </div>

    <div class="content">
        <h2>Eligibility Scanner & Shortlisting</h2>
        
        <% if (request.getParameter("msg") != null) { %>
            <div class="success-text">
                <%= request.getParameter("msg") %>
            </div>
        <% } %>
        
        <!-- Job selector -->
        <div class="box" style="width: 100%;">
            <form method="get" action="shortlist.jsp" style="flex-direction: row; gap: 15px; align-items: flex-end;">
                <div class="form-group" style="flex: 1;">
                    <label>Select Job Recruitment Drive</label>
                    <select name="jobId" onchange="this.form.submit()" required>
                        <option value="" disabled <%= selectedJobId == -1 ? "selected" : "" %>>Choose a Job Posting...</option>
                        <%
                            try {
                                String qJobs = "SELECT jp.job_id, c.company_name, jp.role FROM job_postings jp JOIN companies c ON jp.company_id = c.company_id";
                                pstJobs = con.prepareStatement(qJobs);
                                rsJobs = pstJobs.executeQuery();
                                while(rsJobs.next()) {
                                    int id = rsJobs.getInt("job_id");
                                    String cName = rsJobs.getString("company_name");
                                    String roleName = rsJobs.getString("role");
                        %>
                                    <option value="<%= id %>" <% if(selectedJobId == id){ %> selected <% } %>>
                                        <%= cName %> - <%= roleName %>
                                    </option>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                try { if (rsJobs != null) rsJobs.close(); } catch(Exception e) {}
                                try { if (pstJobs != null) pstJobs.close(); } catch(Exception e) {}
                            }
                        %>
                    </select>
                </div>
            </form>
        </div>

        <% if (selectedJobId != -1) { %>
            <!-- Job Criteria Overview -->
            <div class="box" style="width: 100%; border-left: 4px solid var(--color-accent);">
                <h3 style="margin-bottom: 8px;">Target Drive: <span style="color: var(--color-accent);"><%= jobCompany %> - <%= jobRole %></span></h3>
                <p><strong>Min CGPA Requirement:</strong> <%= jobMinCgpa %> | <strong>Required Skills:</strong> <%= jobSkills.isEmpty() ? "None listed" : jobSkills %></p>
            </div>

            <!-- Tab Navigation -->
            <div class="tabs-nav">
                <button class="tab-link active" onclick="switchTab(event, 'appliedTab')">Applied Candidates</button>
                <button class="tab-link" onclick="switchTab(event, 'eligibleTab')">Auto-Eligible Pool (Not Applied)</button>
            </div>

            <!-- Tab Content: Applied -->
            <div id="appliedTab" class="tab-content active">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>USN</th>
                                <th>Candidate Name</th>
                                <th>Branch</th>
                                <th>CGPA</th>
                                <th>Skills</th>
                                <th>Match %</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                String qApplied = "SELECT a.application_id, u.name, u.usn, s.cgpa, s.branch, s.skills, a.status " +
                                                  "FROM applications a JOIN users u ON a.student_id = u.user_id " +
                                                  "JOIN students s ON u.user_id = s.student_id " +
                                                  "WHERE a.job_id = ?";
                                pstApplied = con.prepareStatement(qApplied);
                                pstApplied.setInt(1, selectedJobId);
                                rsApplied = pstApplied.executeQuery();
                                
                                boolean hasApplied = false;
                                while(rsApplied.next()) {
                                    hasApplied = true;
                                    int appId = rsApplied.getInt("application_id");
                                    String sUsn = rsApplied.getString("usn");
                                    String sName = rsApplied.getString("name");
                                    String sBranch = rsApplied.getString("branch");
                                    double sCgpa = rsApplied.getDouble("cgpa");
                                    String sSkills = rsApplied.getString("skills");
                                    if (sSkills == null) sSkills = "";
                                    String appStatus = rsApplied.getString("status");
                                    
                                    // Calculate skills match percentage
                                    int matchPercent = calculateMatch(sSkills, jobSkills);
                        %>
                            <tr>
                                <td style="font-family: monospace;"><%= sUsn %></td>
                                <td style="font-weight: 600;"><%= sName %></td>
                                <td><%= sBranch %></td>
                                <td style="font-weight: 700; color: var(--color-accent);"><%= sCgpa %></td>
                                <td style="font-size: 0.85rem;"><%= sSkills.isEmpty() ? "-" : sSkills %></td>
                                <td>
                                    <span style="font-weight: bold; color: <%= matchPercent >= 70 ? "var(--color-success)" : matchPercent >= 40 ? "var(--color-warning)" : "var(--text-secondary)" %>">
                                        <%= matchPercent %>%
                                    </span>
                                </td>
                                <td>
                                    <span class="badge badge-<%= appStatus.toLowerCase() %>"><%= appStatus %></span>
                                </td>
                                <td style="display: flex; gap: 8px;">
                                    <form action="UpdateStatusServlet" method="post" style="display:inline-block;">
                                        <input type="hidden" name="jobId" value="<%= selectedJobId %>">
                                        <input type="hidden" name="appId" value="<%= appId %>">
                                        <input type="hidden" name="status" value="SHORTLISTED">
                                        <button type="submit" class="btn" style="padding: 6px 12px; font-size: 0.75rem; border-radius: 6px; background: var(--color-info); border-color: var(--color-info);">Shortlist</button>
                                    </form>
                                    
                                    <form action="UpdateStatusServlet" method="post" style="display:inline-block;">
                                        <input type="hidden" name="jobId" value="<%= selectedJobId %>">
                                        <input type="hidden" name="appId" value="<%= appId %>">
                                        <input type="hidden" name="status" value="SELECTED">
                                        <button type="submit" class="btn" style="padding: 6px 12px; font-size: 0.75rem; border-radius: 6px; background: var(--color-success); border-color: var(--color-success);">Select</button>
                                    </form>
                                    
                                    <form action="UpdateStatusServlet" method="post" style="display:inline-block;">
                                        <input type="hidden" name="jobId" value="<%= selectedJobId %>">
                                        <input type="hidden" name="appId" value="<%= appId %>">
                                        <input type="hidden" name="status" value="REJECTED">
                                        <button type="submit" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.75rem; border-radius: 6px; color: var(--color-danger); border-color: rgba(239, 68, 68, 0.3); background: rgba(239, 68, 68, 0.1);">Reject</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                                }
                                
                                if(!hasApplied) {
                        %>
                            <tr>
                                <td colspan="8" style="text-align: center; color: var(--text-secondary);">No applications received for this job posting yet.</td>
                            </tr>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Tab Content: Eligible Non-Applied -->
            <div id="eligibleTab" class="tab-content">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>USN</th>
                                <th>Candidate Name</th>
                                <th>Branch</th>
                                <th>CGPA</th>
                                <th>Skills</th>
                                <th>Match %</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                // Find students that meet min cgpa and did not apply yet
                                String qEligible = "SELECT u.name, u.usn, s.cgpa, s.branch, s.skills FROM students s " +
                                                   "JOIN users u ON s.student_id = u.user_id " +
                                                   "WHERE s.cgpa >= ? AND s.student_id NOT IN (SELECT student_id FROM applications WHERE job_id = ?)";
                                pstEligible = con.prepareStatement(qEligible);
                                pstEligible.setDouble(1, jobMinCgpa);
                                pstEligible.setInt(2, selectedJobId);
                                rsEligible = pstEligible.executeQuery();
                                
                                boolean hasEligible = false;
                                while(rsEligible.next()) {
                                    hasEligible = true;
                                    String eUsn = rsEligible.getString("usn");
                                    String eName = rsEligible.getString("name");
                                    String eBranch = rsEligible.getString("branch");
                                    double eCgpa = rsEligible.getDouble("cgpa");
                                    String eSkills = rsEligible.getString("skills");
                                    if(eSkills == null) eSkills = "";
                                    
                                    int matchPercent = calculateMatch(eSkills, jobSkills);
                        %>
                            <tr>
                                <td style="font-family: monospace;"><%= eUsn %></td>
                                <td style="font-weight: 600;"><%= eName %></td>
                                <td><%= eBranch %></td>
                                <td style="font-weight: 700; color: var(--color-accent);"><%= eCgpa %></td>
                                <td style="font-size: 0.85rem;"><%= eSkills.isEmpty() ? "-" : eSkills %></td>
                                <td>
                                    <span style="font-weight: bold; color: <%= matchPercent >= 70 ? "var(--color-success)" : matchPercent >= 40 ? "var(--color-warning)" : "var(--text-secondary)" %>">
                                        <%= matchPercent %>%
                                    </span>
                                </td>
                                <td>
                                    <span class="badge badge-eligible">Eligible (Auto scanned)</span>
                                </td>
                            </tr>
                        <%
                                }
                                
                                if(!hasEligible) {
                        %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-secondary);">No matching eligible students found who haven't applied.</td>
                            </tr>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                try { if (rsEligible != null) rsEligible.close(); } catch(Exception e) {}
                                try { if (pstEligible != null) pstEligible.close(); } catch(Exception e) {}
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } else { %>
            <div class="box" style="text-align: center; padding: 60px;">
                <p style="font-size: 1.1rem; color: var(--text-secondary);">Select a recruitment drive from the dropdown to run the eligibility checks and shortlist candidates.</p>
            </div>
        <% } %>
        <%
            // Cleanup all remaining resources
            try { if (rsJobDetail != null) rsJobDetail.close(); } catch(Exception e) {}
            try { if (pstJobDetail != null) pstJobDetail.close(); } catch(Exception e) {}
            try { if (rsApplied != null) rsApplied.close(); } catch(Exception e) {}
            try { if (pstApplied != null) pstApplied.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        %>
    </div>

</div>

<script>
    function switchTab(evt, tabId) {
        // Hide all tabs
        const tabContents = document.getElementsByClassName("tab-content");
        for (let i = 0; i < tabContents.length; i++) {
            tabContents[i].classList.remove("active");
        }
        
        // Remove active class from buttons
        const tabLinks = document.getElementsByClassName("tab-link");
        for (let i = 0; i < tabLinks.length; i++) {
            tabLinks[i].classList.remove("active");
        }
        
        // Show current tab and set active class
        document.getElementById(tabId).classList.add("active");
        evt.currentTarget.classList.add("active");
    }
</script>

</body>
</html>