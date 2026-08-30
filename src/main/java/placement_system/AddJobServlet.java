package placement_system;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddJobServlet")
public class AddJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"COORDINATOR".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String companyIdParam = request.getParameter("companyId");
        String newCompanyName = request.getParameter("newCompanyName");
        String newCompanyDesc = request.getParameter("newCompanyDesc");
        String role = request.getParameter("role");
        double pkg = Double.parseDouble(request.getParameter("package"));
        double minCgpa = Double.parseDouble(request.getParameter("minCgpa"));
        String skills = request.getParameter("skills");

        Connection con = null;
        PreparedStatement compPst = null;
        PreparedStatement jobPst = null;
        ResultSet genKeys = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Transaction boundary

            int companyId = -1;

            if ("new".equalsIgnoreCase(companyIdParam)) {
                // Insert new company first
                String compQuery = "INSERT INTO companies (company_name, description) VALUES (?, ?)";
                compPst = con.prepareStatement(compQuery, Statement.RETURN_GENERATED_KEYS);
                compPst.setString(1, newCompanyName);
                compPst.setString(2, newCompanyDesc);
                compPst.executeUpdate();

                genKeys = compPst.getGeneratedKeys();
                if (genKeys.next()) {
                    companyId = genKeys.getInt(1);
                }
            } else {
                companyId = Integer.parseInt(companyIdParam);
            }

            if (companyId == -1) {
                throw new Exception("Unable to establish company profile.");
            }

            // Insert Job Posting
            String jobQuery = "INSERT INTO job_postings (company_id, role, package, min_cgpa, required_skills) VALUES (?, ?, ?, ?, ?)";
            jobPst = con.prepareStatement(jobQuery);
            jobPst.setInt(1, companyId);
            jobPst.setString(2, role);
            jobPst.setDouble(3, pkg);
            jobPst.setDouble(4, minCgpa);
            jobPst.setString(5, skills);
            jobPst.executeUpdate();

            con.commit(); // commit
            response.sendRedirect("add_job.jsp?msg=Job posting added successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) {}
            }
            request.setAttribute("error", "Error posting job: " + e.getMessage());
            request.getRequestDispatcher("add_job.jsp").forward(request, response);
        } finally {
            try { if (genKeys != null) genKeys.close(); } catch(Exception e) {}
            try { if (compPst != null) compPst.close(); } catch(Exception e) {}
            try { if (jobPst != null) jobPst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
