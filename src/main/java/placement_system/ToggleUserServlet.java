package placement_system;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ToggleUserServlet")
public class ToggleUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int targetUserId = Integer.parseInt(request.getParameter("userId"));
        String action = request.getParameter("action");
        int isActive = "activate".equalsIgnoreCase(action) ? 1 : 0;

        Connection con = null;
        PreparedStatement pst = null;

        try {
            con = DBConnection.getConnection();
            String query = "UPDATE users SET is_active=? WHERE user_id=?";
            pst = con.prepareStatement(query);
            pst.setInt(1, isActive);
            pst.setInt(2, targetUserId);
            pst.executeUpdate();

            response.sendRedirect("admin_dashboard.jsp?msg=User status successfully updated!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=Error updating user: " + e.getMessage());
        } finally {
            try { if (pst != null) pst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
