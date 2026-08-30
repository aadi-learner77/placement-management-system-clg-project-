package placement_system;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String name = request.getParameter("name");
        String branch = request.getParameter("branch");
        double cgpa = Double.parseDouble(request.getParameter("cgpa"));
        int sem = Integer.parseInt(request.getParameter("sem"));
        int gradYear = Integer.parseInt(request.getParameter("gradYear"));
        String skills = request.getParameter("skills");
        String projects = request.getParameter("projects");
        String experience = request.getParameter("experience");

        // Paths for uploaded files
        String appPath = request.getServletContext().getRealPath("");
        String savePath = appPath + File.separator + UPLOAD_DIR;

        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        String resumeFileName = null;
        String certFileName = null;

        // Process Resume
        Part resumePart = request.getPart("resume");
        if (resumePart != null && resumePart.getSize() > 0) {
            resumeFileName = "resume_" + userId + ".pdf";
            resumePart.write(savePath + File.separator + resumeFileName);
        }

        // Process Certificates
        Part certPart = request.getPart("certificates");
        if (certPart != null && certPart.getSize() > 0) {
            certFileName = "certificates_" + userId + ".pdf";
            certPart.write(savePath + File.separator + certFileName);
        }

        Connection con = null;
        PreparedStatement userPst = null;
        PreparedStatement studentPst = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Update user name
            String userQuery = "UPDATE users SET name=? WHERE user_id=?";
            userPst = con.prepareStatement(userQuery);
            userPst.setString(1, name);
            userPst.setInt(2, userId);
            userPst.executeUpdate();
            
            // Update session name
            session.setAttribute("name", name);

            // Update student profile details
            String studentQuery = "UPDATE students SET branch=?, current_sem=?, cgpa=?, graduation_year=?, skills=?, projects=?, experience=?, " +
                                 "resume_path=COALESCE(?, resume_path), certificates_path=COALESCE(?, certificates_path) WHERE student_id=?";
            studentPst = con.prepareStatement(studentQuery);
            studentPst.setString(1, branch);
            studentPst.setInt(2, sem);
            studentPst.setDouble(3, cgpa);
            studentPst.setInt(4, gradYear);
            studentPst.setString(5, skills);
            studentPst.setString(6, projects);
            studentPst.setString(7, experience);
            studentPst.setString(8, resumeFileName);
            studentPst.setString(9, certFileName);
            studentPst.setInt(10, userId);
            studentPst.executeUpdate();

            con.commit();
            response.sendRedirect("profile.jsp?msg=Profile saved successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch(Exception ex) {}
            }
            request.setAttribute("error", "Error updating profile: " + e.getMessage());
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        } finally {
            try { if (userPst != null) userPst.close(); } catch(Exception e) {}
            try { if (studentPst != null) studentPst.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
}
