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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usn = request.getParameter("usn");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String branch = request.getParameter("branch");
        int sem = Integer.parseInt(request.getParameter("sem"));
        double cgpa = Double.parseDouble(request.getParameter("cgpa"));
        int gradYear = Integer.parseInt(request.getParameter("gradYear"));

        Connection con = null;
        PreparedStatement checkPst = null;
        PreparedStatement userPst = null;
        PreparedStatement studentPst = null;
        ResultSet rs = null;
        ResultSet genKeys = null;

        try {
            con = DBConnection.getConnection();
            if (con == null) {
                request.setAttribute("error", "Database connection error.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Check if user already exists
            String checkQuery = "SELECT user_id FROM users WHERE email=? OR (usn IS NOT NULL AND usn=?)";
            checkPst = con.prepareStatement(checkQuery);
            checkPst.setString(1, email);
            checkPst.setString(2, usn);
            rs = checkPst.executeQuery();

            if (rs.next()) {
                request.setAttribute("error", "Email or USN already registered.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            con.setAutoCommit(false); // Begin Transaction

            // Insert user
            String userQuery = "INSERT INTO users (usn, name, email, password, role, is_active) VALUES (?, ?, ?, ?, 'STUDENT', 1)";
            userPst = con.prepareStatement(userQuery, Statement.RETURN_GENERATED_KEYS);
            userPst.setString(1, usn);
            userPst.setString(2, name);
            userPst.setString(3, email);
            userPst.setString(4, password);
            userPst.executeUpdate();

            genKeys = userPst.getGeneratedKeys();
            int userId = -1;
            if (genKeys.next()) {
                userId = genKeys.getInt(1);
            }

            if (userId == -1) {
                throw new Exception("Creating user failed, no ID obtained.");
            }

            // Insert student profile
            String studentQuery = "INSERT INTO students (student_id, branch, current_sem, cgpa, graduation_year) VALUES (?, ?, ?, ?, ?)";
            studentPst = con.prepareStatement(studentQuery);
            studentPst.setInt(1, userId);
            studentPst.setString(2, branch);
            studentPst.setInt(3, sem);
            studentPst.setDouble(4, cgpa);
            studentPst.setInt(5, gradYear);
            studentPst.executeUpdate();

            con.commit(); // Commit Transaction
            response.sendRedirect("login.jsp?msg=Registration successful! Please login.");

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            request.setAttribute("error", "System Error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (genKeys != null) genKeys.close(); } catch (Exception e) {}
            try { if (checkPst != null) checkPst.close(); } catch (Exception e) {}
            try { if (userPst != null) userPst.close(); } catch (Exception e) {}
            try { if (studentPst != null) studentPst.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
