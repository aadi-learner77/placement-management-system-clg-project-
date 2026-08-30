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

@WebServlet("/UpdateStatusServlet")
public class UpdateStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"COORDINATOR".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int appId = Integer.parseInt(request.getParameter("appId"));
        String status = request.getParameter("status");
        String jobId = request.getParameter("jobId");

        Connection con = null;
        PreparedStatement pst = null;

        try {
            con = DBConnection.getConnection();
            String query = "UPDATE applications SET status=? WHERE application_id=?";
            pst = con.prepareStatement(query);
            pst.setString(1, status);
            pst.setInt(2, appId);
            pst.executeUpdate();

            response.sendRedirect("shortlist.jsp?jobId=" + jobId + "&msg=Candidate status updated to " + status + "!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("shortlist.jsp?jobId=" + jobId + "&error=Error updating status: " + e.getMessage());
        } finally {
            try { if (pst != null) pst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
