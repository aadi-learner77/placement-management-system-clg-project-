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

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        int jobId = Integer.parseInt(request.getParameter("jobId"));

        Connection con = null;
        PreparedStatement checkPst = null;
        PreparedStatement eligPst = null;
        PreparedStatement applyPst = null;
        ResultSet checkRs = null;
        ResultSet eligRs = null;

        try {
            con = DBConnection.getConnection();

            // 1. Check if already applied
            String checkQuery = "SELECT application_id FROM applications WHERE student_id=? AND job_id=?";
            checkPst = con.prepareStatement(checkQuery);
            checkPst.setInt(1, userId);
            checkPst.setInt(2, jobId);
            checkRs = checkPst.executeQuery();

            if (checkRs.next()) {
                request.setAttribute("error", "You have already applied for this job.");
                request.getRequestDispatcher("jobs.jsp").forward(request, response);
                return;
            }

            // 2. Check CGPA eligibility
            String eligQuery = "SELECT jp.min_cgpa, s.cgpa FROM job_postings jp, students s " +
                               "WHERE jp.job_id=? AND s.student_id=?";
            eligPst = con.prepareStatement(eligQuery);
            eligPst.setInt(1, jobId);
            eligPst.setInt(2, userId);
            eligRs = eligPst.executeQuery();

            if (eligRs.next()) {
                double minCgpa = eligRs.getDouble("min_cgpa");
                double studentCgpa = eligRs.getDouble("cgpa");

                if (studentCgpa < minCgpa) {
                    request.setAttribute("error", "You do not meet the minimum CGPA requirement for this job.");
                    request.getRequestDispatcher("jobs.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("error", "Invalid Job or Student profile.");
                request.getRequestDispatcher("jobs.jsp").forward(request, response);
                return;
            }

            // 3. Apply
            String applyQuery = "INSERT INTO applications (student_id, job_id, status) VALUES (?, ?, 'APPLIED')";
            applyPst = con.prepareStatement(applyQuery);
            applyPst.setInt(1, userId);
            applyPst.setInt(2, jobId);
            applyPst.executeUpdate();

            response.sendRedirect("jobs.jsp?msg=Successfully applied for the job!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error applying for job: " + e.getMessage());
            request.getRequestDispatcher("jobs.jsp").forward(request, response);
        } finally {
            try { if (checkRs != null) checkRs.close(); } catch(Exception e) {}
            try { if (checkPst != null) checkPst.close(); } catch(Exception e) {}
            try { if (eligRs != null) eligRs.close(); } catch(Exception e) {}
            try { if (eligPst != null) eligPst.close(); } catch(Exception e) {}
            try { if (applyPst != null) applyPst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
