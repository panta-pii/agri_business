package Servlet;

import daos.UserDAO;
import models.User;
import utils.PasswordUtil;
import org.json.JSONObject;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import javax.servlet.http.Part;

@WebServlet("/RegisterServlet")
@MultipartConfig(
        maxFileSize = 5 * 1024 * 1024, // 5MB
        maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;
    
    // Email configuration - Same as CheckoutServlet
    private final String SMTP_HOST = "smtp.gmail.com";
    private final String SMTP_PORT = "587";
    private final String EMAIL_USERNAME = "panta.pii@bothouniversity.com";
    private final String EMAIL_PASSWORD = "kfsg kbat qjtb nkda";

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONObject jsonResponse = new JSONObject();
        PrintWriter out = response.getWriter();

        try {
            // ✅ Read input fields from multipart form
            String firstName = getParameter(request, "firstName");
            String lastName = getParameter(request, "lastName");
            String email = getParameter(request, "email");
            String password = getParameter(request, "password");
            String confirmPassword = getParameter(request, "confirmPassword");
            String phoneNumber = getParameter(request, "phoneNumber");
            String role = getParameter(request, "role");
            String location = getParameter(request, "location");
            String bio = getParameter(request, "bio");

            // ✅ Validate required fields
            if (firstName == null || firstName.trim().isEmpty()
                    || lastName == null || lastName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()) {

                jsonResponse.put("success", false);
                jsonResponse.put("message", "All required fields must be filled.");
                out.print(jsonResponse.toString());
                return;
            }

            // ✅ Check email uniqueness
            if (userDAO.emailExists(email)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email already exists.");
                out.print(jsonResponse.toString());
                return;
            }

            // ✅ Validate password match
            if (!password.equals(confirmPassword)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Passwords do not match.");
                out.print(jsonResponse.toString());
                return;
            }

            // ✅ Validate password strength
            if (password.length() < 6) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Password must be at least 6 characters long.");
                out.print(jsonResponse.toString());
                return;
            }

            // ✅ Get uploaded profile picture (optional)
            byte[] profileImage = null;
            try {
                Part profilePicturePart = request.getPart("profilePicture");
                if (profilePicturePart != null && profilePicturePart.getSize() > 0) {
                    try (InputStream is = profilePicturePart.getInputStream()) {
                        profileImage = is.readAllBytes();
                    }
                }
            } catch (Exception e) {
                System.out.println("Profile picture not uploaded or failed: " + e.getMessage());
            }

            // ✅ Hash password and store as "salt:hash"
            String hashedPassword = PasswordUtil.hashPasswordCombined(password);

            // ✅ Create user object with ALL required fields including status and isVerified
            User newUser = new User();
            newUser.setFirstName(firstName.trim());
            newUser.setLastName(lastName.trim());
            newUser.setEmail(email.trim().toLowerCase());
            newUser.setPassword(hashedPassword); // store salt:hash together
            newUser.setPhoneNumber(phoneNumber != null ? phoneNumber.trim() : null);
            newUser.setRole(role != null && !role.trim().isEmpty() ? role.trim() : "BUYER");
            newUser.setLocation(location != null ? location.trim() : null);
            newUser.setBio(bio != null ? bio.trim() : null);
            newUser.setProfilePicture(profileImage);
            
            // ✅ Set the missing fields that are required by UserDAO
            newUser.setStatus("ACTIVE"); // Default status for new users
            newUser.setVerified(false); // New users are not verified by default

            // ✅ Save to DB
            boolean success = userDAO.addUser(newUser);

            if (success) {
                // ✅ Send welcome email
                boolean emailSent = sendWelcomeEmail(firstName, lastName, email, role);
                
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Registration successful! You can now log in." + (emailSent ? " A welcome email has been sent to your inbox." : ""));

                // Optional: Auto-login or session setup
                HttpSession session = request.getSession();
                session.setAttribute("userEmail", newUser.getEmail());
                session.setAttribute("userName", newUser.getFirstName() + " " + newUser.getLastName());
                session.setAttribute("userId", newUser.getId());
                session.setAttribute("userRole", newUser.getRole());
                
                System.out.println("✅ User registered successfully: " + email);
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Registration failed. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "System error: " + e.getMessage());
        }

        out.print(jsonResponse.toString());
        out.flush();
    }

    // ✅ Helper method to safely get form parameters
    private String getParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return value != null ? value.trim() : "";
    }

    // ✅ EMAIL FUNCTION - Welcome Email for New Users
    private boolean sendWelcomeEmail(String firstName, String lastName, String email, String role) {
        System.out.println("Attempting to send welcome email to: " + email);

        try {
            // Setup mail server properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);

            // Create authenticator
            Authenticator auth = new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            };

            // Create session
            Session session = Session.getInstance(props, auth);
            session.setDebug(true);

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_USERNAME, "AgriYouth Marketplace"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("🌱 Welcome to AgriYouth Marketplace!");
            message.setSentDate(new java.util.Date());

            // Create email content
            String emailContent = buildWelcomeEmailContent(firstName, lastName, role);

            // Set content as HTML
            message.setContent(emailContent, "text/html; charset=utf-8");

            System.out.println("Sending welcome email...");

            // Send email
            Transport.send(message);

            System.out.println("✅ Welcome email sent successfully to: " + email);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Failed to send welcome email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private String buildWelcomeEmailContent(String firstName, String lastName, String role) {
        String roleDescription = "";
        if ("FARMER".equalsIgnoreCase(role)) {
            roleDescription = "As a <strong>Farmer</strong>, you can now list your products, manage your inventory, and connect directly with buyers.";
        } else if ("BUYER".equalsIgnoreCase(role)) {
            roleDescription = "As a <strong>Buyer</strong>, you can now browse fresh agricultural products, place orders, and support local farmers.";
        } else {
            roleDescription = "You can now explore our marketplace and access all features.";
        }

        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f4; }"
                + ".container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 0 10px rgba(0,0,0,0.1); }"
                + ".header { background: #28a745; color: white; padding: 30px; text-align: center; }"
                + ".content { padding: 30px; }"
                + ".section { margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid #eee; }"
                + ".section:last-child { border-bottom: none; }"
                + ".feature-list { list-style: none; padding: 0; }"
                + ".feature-list li { margin-bottom: 10px; padding-left: 20px; position: relative; }"
                + ".feature-list li:before { content: '✓'; color: #28a745; font-weight: bold; position: absolute; left: 0; }"
                + ".info-box { background: #e7f3ff; padding: 15px; border-radius: 5px; border-left: 4px solid #007bff; margin: 15px 0; }"
                + ".footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }"
                + ".btn { display: inline-block; padding: 12px 24px; background: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1 style='margin: 0; font-size: 28px;'>🌱 AgriYouth Marketplace</h1>"
                + "<h2 style='margin: 10px 0 0 0; font-weight: 300;'>Welcome Aboard!</h2>"
                + "</div>"
                + "<div class='content'>"
                + "<div class='section'>"
                + "<p>Dear <strong>" + firstName + " " + lastName + "</strong>,</p>"
                + "<p>Welcome to AgriYouth Marketplace - Lesotho's premier platform for youth-led agri-businesses!</p>"
                + "<p>We're excited to have you join our growing community of farmers, buyers, and agricultural enthusiasts.</p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>🎯 Your Account Details</h3>"
                + "<p><strong>Role:</strong> " + roleDescription + "</p>"
                + "<p><strong>Status:</strong> <span style='color: #28a745; font-weight: bold;'>ACTIVE</span></p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>🚀 What You Can Do Now</h3>"
                + "<ul class='feature-list'>"
                + "<li>Browse and search for agricultural products</li>"
                + "<li>Connect with local farmers and buyers</li>"
                + "<li>Access learning resources and opportunities</li>"
                + "<li>Manage your profile and preferences</li>"
                + "</ul>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>📱 Get Started</h3>"
                + "<p>Ready to explore? Click the button below to start your journey:</p>"
                + "<a href='http://localhost:8000/agri%20business/' class='btn'>Start Exploring →</a>"
                + "</div>"
                + "<div class='info-box'>"
                + "<p style='margin: 0;'><strong>💡 Need Help?</strong><br>"
                + "If you have any questions or need assistance, please don't hesitate to contact our support team at <strong>support@agriyouth.ls</strong> or call us at <strong>+266 1234 5678</strong>.</p>"
                + "</div>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>Thank you for joining AgriYouth Marketplace!<br>"
                + "Together, let's grow Lesotho's agricultural future.</p>"
                + "<p style='margin-top: 20px; color: #999;'>© 2025 AgriYouth Marketplace. All rights reserved.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
    }
}