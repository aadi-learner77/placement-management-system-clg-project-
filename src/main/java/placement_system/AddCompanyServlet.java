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

@WebServlet("/AddCompanyServlet")
public class AddCompanyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String companyName = request.getParameter("companyName");
        String description = request.getParameter("description");

        Connection con = null;
        PreparedStatement pst = null;

        try {
            con = DBConnection.getConnection();
            String query = "INSERT INTO companies (company_name, description) VALUES (?, ?)";
            pst = con.prepareStatement(query);
            pst.setString(1, companyName);
            pst.setString(2, description);
            pst.executeUpdate();

            response.sendRedirect("admin_dashboard.jsp?msg=Company successfully registered!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=Error adding company: " + e.getMessage());
        } finally {
            try { if (pst != null) pst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
