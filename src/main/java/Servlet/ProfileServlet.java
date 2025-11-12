package Servlet;

import daos.UserDAO;
import models.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import org.json.JSONObject;

@WebServlet("/ProfileServlet")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class ProfileServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            result.put("success", false);
            result.put("message", "Please login to view profile");
            out.print(result.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        
        try {
            // Get fresh user data from database
            User user = userDAO.getUserById(currentUser.getId());
            if (user != null) {
                result.put("success", true);
                result.put("user", userToJson(user));
            } else {
                result.put("success", false);
                result.put("message", "User not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Error retrieving profile: " + e.getMessage());
        }

        out.print(result.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            result.put("success", false);
            result.put("message", "Please login to update profile");
            out.print(result.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        try {
            switch (action) {
                case "update":
                    updateProfile(request, currentUser, result);
                    break;
                case "changePassword":
                    changePassword(request, currentUser, result);
                    break;
                case "delete":
                    deleteProfile(request, currentUser, result);
                    break;
                case "uploadPhoto":
                    uploadProfilePhoto(request, currentUser, result);
                    break;
                default:
                    result.put("success", false);
                    result.put("message", "Invalid action");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
        }

        out.print(result.toString());
        out.flush();
    }

    private void updateProfile(HttpServletRequest request, User currentUser, JSONObject result) 
            throws Exception {
        
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String location = request.getParameter("location");
        String bio = request.getParameter("bio");

        // Validation
        if (firstName == null || firstName.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "First name is required");
            return;
        }

        if (lastName == null || lastName.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Last name is required");
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Email is required");
            return;
        }

        // Check if email is already taken by another user
        User existingUser = userDAO.getUserByEmail(email);
        if (existingUser != null && existingUser.getId() != currentUser.getId()) {
            result.put("success", false);
            result.put("message", "Email is already taken by another user");
            return;
        }

        // Update user object
        currentUser.setFirstName(firstName.trim());
        currentUser.setLastName(lastName.trim());
        currentUser.setEmail(email.trim());
        currentUser.setPhoneNumber(phoneNumber != null ? phoneNumber.trim() : null);
        currentUser.setLocation(location != null ? location.trim() : null);
        currentUser.setBio(bio != null ? bio.trim() : null);

        boolean success = userDAO.updateUser(currentUser);
        if (success) {
            // Update session
            request.getSession().setAttribute("user", currentUser);
            result.put("success", true);
            result.put("message", "Profile updated successfully");
            result.put("user", userToJson(currentUser));
        } else {
            result.put("success", false);
            result.put("message", "Failed to update profile");
        }
    }

    private void changePassword(HttpServletRequest request, User currentUser, JSONObject result) 
            throws Exception {
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Current password is required");
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "New password is required");
            return;
        }

        if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Please confirm your new password");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            result.put("success", false);
            result.put("message", "New passwords do not match");
            return;
        }

        if (newPassword.length() < 6) {
            result.put("success", false);
            result.put("message", "Password must be at least 6 characters long");
            return;
        }

        // Verify current password
        User user = userDAO.getUserById(currentUser.getId());
        if (!user.getPassword().equals(currentPassword)) {
            result.put("success", false);
            result.put("message", "Current password is incorrect");
            return;
        }

        // Update password
        boolean success = userDAO.updatePassword(currentUser.getId(), newPassword);
        if (success) {
            result.put("success", true);
            result.put("message", "Password changed successfully");
        } else {
            result.put("success", false);
            result.put("message", "Failed to change password");
        }
    }

    private void deleteProfile(HttpServletRequest request, User currentUser, JSONObject result) 
            throws Exception {
        
        String password = request.getParameter("password");
        
        if (password == null || password.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Password is required to delete account");
            return;
        }

        // Verify password
        User user = userDAO.getUserById(currentUser.getId());
        if (!user.getPassword().equals(password)) {
            result.put("success", false);
            result.put("message", "Incorrect password");
            return;
        }

        // Delete user account
        boolean success = userDAO.deleteUser(currentUser.getId());
        if (success) {
            // Invalidate session
            request.getSession().invalidate();
            result.put("success", true);
            result.put("message", "Account deleted successfully");
        } else {
            result.put("success", false);
            result.put("message", "Failed to delete account");
        }
    }

    private void uploadProfilePhoto(HttpServletRequest request, User currentUser, JSONObject result) 
            throws Exception {
        
        Part filePart = request.getPart("profilePhoto");
        if (filePart == null || filePart.getSize() == 0) {
            result.put("success", false);
            result.put("message", "Please select a photo");
            return;
        }

        // Validate file type
        String fileName = getFileName(filePart);
        String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        if (!fileExtension.matches("jpg|jpeg|png|gif")) {
            result.put("success", false);
            result.put("message", "Only JPG, JPEG, PNG, and GIF files are allowed");
            return;
        }

        // Validate file size (max 2MB)
        if (filePart.getSize() > 2 * 1024 * 1024) {
            result.put("success", false);
            result.put("message", "File size must be less than 2MB");
            return;
        }

        // Read file bytes
        byte[] fileBytes = filePart.getInputStream().readAllBytes();

        // Update profile picture
        boolean success = userDAO.updateProfilePicture(currentUser.getId(), fileBytes);
        if (success) {
            // Update user object in session
            currentUser.setProfilePicture(fileBytes);
            request.getSession().setAttribute("user", currentUser);
            
            result.put("success", true);
            result.put("message", "Profile photo updated successfully");
        } else {
            result.put("success", false);
            result.put("message", "Failed to update profile photo");
        }
    }

    private JSONObject userToJson(User user) {
        JSONObject userJson = new JSONObject();
        userJson.put("id", user.getId());
        userJson.put("firstName", user.getFirstName());
        userJson.put("lastName", user.getLastName());
        userJson.put("email", user.getEmail());
        userJson.put("phoneNumber", user.getPhoneNumber());
        userJson.put("role", user.getRole());
        userJson.put("location", user.getLocation());
        userJson.put("bio", user.getBio());
        userJson.put("isVerified", user.isVerified());
        userJson.put("createdAt", user.getCreatedAt());
        userJson.put("updatedAt", user.getUpdatedAt());
        
        // Add profile picture URL
        userJson.put("profilePictureUrl", "ProfilePhotoServlet?id=" + user.getId());
        
        return userJson;
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "file";
    }
}