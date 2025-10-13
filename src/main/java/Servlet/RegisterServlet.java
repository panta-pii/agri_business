package Servlet;

import daos.UserDAO;
import models.User;
import utils.PasswordUtil;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response type to JSON for AJAX requests
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject jsonResponse = new JSONObject();
        PrintWriter out = response.getWriter();
        
        try {
            // Get form parameters
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String phoneNumber = request.getParameter("phoneNumber");
            String role = request.getParameter("role");
            String location = request.getParameter("location");
            
            // Validate required fields
            if (firstName == null || firstName.trim().isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "First name is required");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (lastName == null || lastName.trim().isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Last name is required");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (email == null || email.trim().isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email address is required");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (password == null || password.trim().isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Password is required");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Validate email format
            if (!isValidEmail(email)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Please enter a valid email address");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Validate password strength
            if (password.length() < 6) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Password must be at least 6 characters long");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Check if passwords match
            if (!password.equals(confirmPassword)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Passwords do not match");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Check if email already exists
            if (userDAO.emailExists(email)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email address is already registered");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Hash the password
            String[] passwordData = PasswordUtil.hashPassword(password);
            String hashedPassword = passwordData[0];
            String salt = passwordData[1];
            String passwordWithSalt = salt + ":" + hashedPassword;
            
            // Create new user object
            User newUser = new User();
            newUser.setFirstName(firstName.trim());
            newUser.setLastName(lastName.trim());
            newUser.setEmail(email.trim().toLowerCase());
            newUser.setPassword(passwordWithSalt);
            newUser.setPhoneNumber(phoneNumber != null ? phoneNumber.trim() : null);
            newUser.setRole(role != null ? role : "FARMER");
            newUser.setLocation(location != null ? location.trim() : null);
            newUser.setVerified(false); // New users are not verified by default
            
            // Save user to database
            boolean registrationSuccess = userDAO.addUser(newUser);
            
            if (registrationSuccess) {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Registration successful! You can now login.");
                jsonResponse.put("redirect", false);
                
                // Log the registration (you can remove this in production)
                System.out.println("New user registered: " + email);
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Registration failed. Please try again.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "An error occurred during registration: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString());
            out.flush();
            out.close();
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect POST requests or show error
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "GET method not supported");
    }
    
    // Email validation method
    private boolean isValidEmail(String email) {
        if (email == null) return false;
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }
}