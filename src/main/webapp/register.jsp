<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Student Registration</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="center-wrapper">
    <div class="card large-card">
        <h2>Student Sign Up</h2>
        <p style="text-align: center; margin-bottom: 30px; color: var(--text-secondary);">
            Create your profile to explore job postings and track recruitment
        </p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-text" style="margin-bottom: 20px;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="RegisterServlet" method="post">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div class="form-group">
                    <label for="usn">USN (University Seat Number)</label>
                    <input type="text" id="usn" name="usn" placeholder="e.g. 1RV21CS001" required>
                </div>
                
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" placeholder="e.g. Aaditya V" required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="e.g. student@gmail.com" required autocomplete="email">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="••••••••" required>
                </div>

                <div class="form-group">
                    <label for="branch">Branch / Department</label>
                    <select id="branch" name="branch" required>
                        <option value="" disabled selected>Select Branch</option>
                        <option value="Computer Science">Computer Science</option>
                        <option value="Information Science">Information Science</option>
                        <option value="Electronics">Electronics</option>
                        <option value="Mechanical">Mechanical</option>
                        <option value="Civil">Civil</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="sem">Current Semester</label>
                    <input type="number" id="sem" name="sem" min="1" max="8" value="8" required>
                </div>

                <div class="form-group">
                    <label for="cgpa">Current CGPA</label>
                    <input type="number" id="cgpa" name="cgpa" step="0.01" min="0" max="10" placeholder="e.g. 9.15" required>
                </div>

                <div class="form-group">
                    <label for="gradYear">Graduation Year</label>
                    <input type="number" id="gradYear" name="gradYear" min="2020" max="2035" value="2026" required>
                </div>
            </div>

            <button type="submit" style="margin-top: 10px;">Create Account</button>
        </form>

        <p style="text-align: center; margin-top: 24px; font-size: 0.95rem;">
            Already registered? 
            <a href="login.jsp" style="color: var(--color-accent); text-decoration: none; font-weight: 600;">Sign in here</a>
        </p>
        
        <div style="text-align: center; margin-top: 15px;">
            <a href="index.jsp" class="link-back">← Back to Home</a>
        </div>
    </div>
</div>

</body>
</html>