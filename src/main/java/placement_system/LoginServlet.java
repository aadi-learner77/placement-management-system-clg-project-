package placement_system;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            if (con == null) {
                request.setAttribute("error", "Database connection error.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            String query = "SELECT * FROM users WHERE email=? AND password=?";
            pst = con.prepareStatement(query);
            pst.setString(1, email);
            pst.setString(2, password);
            rs = pst.executeQuery();
            if (rs.next()) {
                boolean isActive = rs.getBoolean("is_active");
                if (!isActive) {
                    request.setAttribute("error", "Your account is deactivated. Contact Admin.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                HttpSession session = request.getSession(true);
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("email",   rs.getString("email"));
                session.setAttribute("name",    rs.getString("name"));
                session.setAttribute("role",    rs.getString("role"));
                session.setAttribute("usn",     rs.getString("usn"));
                String role = rs.getString("role");
                if ("STUDENT".equalsIgnoreCase(role)) {
                    response.sendRedirect("student_dashboard.jsp");
                } else if ("COORDINATOR".equalsIgnoreCase(role)) {
                    response.sendRedirect("coordinator_dashboard.jsp");
                } else if ("ADMIN".equalsIgnoreCase(role)) {
                    response.sendRedirect("admin_dashboard.jsp");
                } else {
                    request.setAttribute("error", "Unknown role: " + role);
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Invalid Email or Password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System Error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            try { if (rs  != null) rs.close();  } catch (Exception e) {}
            try { if (pst != null) pst.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}