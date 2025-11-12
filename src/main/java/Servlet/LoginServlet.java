package Servlet;

import daos.UserDAO;
import models.User;
import utils.PasswordUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // ✅ Validate input
        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "❌ Email and password are required.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        try {
            // ✅ Get user by email
            User user = userDAO.getUserByEmail(email.trim().toLowerCase());

            if (user == null) {
                request.setAttribute("errorMessage", "❌ No account found with that email.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            // ✅ Verify password (salt:hash stored in user.getPassword())
            boolean passwordMatched = PasswordUtil.verifyPassword(password, user.getPassword());

            if (!passwordMatched) {
                request.setAttribute("errorMessage", "❌ Invalid email or password.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            // ✅ Successful login — create session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getFirstName() + " " + user.getLastName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userEmail", user.getEmail());
            session.setMaxInactiveInterval(60 * 60); // 1 hour

            // ✅ Redirect based on role
            if ("FARMER".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("farmers_dashboard.jsp");
            } else if ("BUYER".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("buyer_dashboard.jsp");} 
            else if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("admin_dashboard.jsp");
            } else {
                response.sendRedirect("index.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "⚠️ Login error: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}
