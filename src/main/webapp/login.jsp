<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Portal Login</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="center-wrapper">
    <div class="card">
        <h2>System Login</h2>
        <p style="text-align: center; margin-bottom: 24px; color: var(--text-secondary);">
            Enter your credentials to access the placement portal
        </p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-text" style="margin-bottom: 16px;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getParameter("msg") != null) { %>
            <div class="success-text" style="margin-bottom: 16px;">
                <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <form action="LoginServlet" method="post">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" placeholder="email@gmail.com" required autocomplete="email">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>

            <button type="submit" style="margin-top: 10px;">Login</button>
        </form>

        <p style="text-align: center; margin-top: 24px; font-size: 0.95rem;">
            Don't have an account? 
            <a href="register.jsp" style="color: var(--color-accent); text-decoration: none; font-weight: 600;">Register here</a>
        </p>
        
        <div style="text-align: center; margin-top: 15px;">
            <a href="index.jsp" class="link-back">← Back to Home</a>
        </div>
    </div>
</div>

</body>
</html>