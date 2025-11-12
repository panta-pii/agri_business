package Servlet;

import com.google.gson.Gson;
import daos.*;
import models.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;

@WebServlet("/AdminDashboardServlet")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class AdminDashboardServlet extends HttpServlet {

    private UserDAO userDAO;
    private ProductDAO productDAO;
    private OpportunityDAO opportunityDAO;
    private LearningMaterialDAO learningMaterialDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        productDAO = new ProductDAO();
        opportunityDAO = new OpportunityDAO();
        learningMaterialDAO = new LearningMaterialDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            switch (action != null ? action : "") {
                case "getStats":
                    getDashboardStats(response);
                    break;
                case "getUsers":
                    getUsers(response);
                    break;
                case "getRecentUsers":
                    getRecentUsers(response);
                    break;
                case "getProducts":
                    getProducts(response);
                    break;
                case "getRecentProducts":
                    getRecentProducts(response);
                    break;
                case "getOpportunities":
                    getOpportunities(response);
                    break;
                case "getLearningMaterials":
                    getLearningMaterials(response);
                    break;
                case "getUserById":
                    getUserById(request, response);
                    break;
                case "getProductById":
                    getProductById(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            switch (action != null ? action : "") {
                case "addUser":
                    addUser(request, response);
                    break;
                case "addProduct":
                    addProduct(request, response);
                    break;
                case "addOpportunity":
                    addOpportunity(request, response);
                    break;
                case "addLearningMaterial":
                    addLearningMaterial(request, response);
                    break;
                case "toggleUserStatus":
                    toggleUserStatus(request, response);
                    break;
                case "toggleMaterialPublish":
                    toggleMaterialPublish(request, response);
                    break;
                case "updateUser":
                    updateUser(request, response);
                    break;
                case "updateProduct":
                    updateProduct(request, response);
                    break;
                case "updateOpportunity":
                    updateOpportunity(request, response);
                    break;
                case "updateLearningMaterial":
                    updateLearningMaterial(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            switch (action != null ? action : "") {
                case "updateUser":
                    updateUser(request, response);
                    break;
                case "updateProduct":
                    updateProduct(request, response);
                    break;
                case "updateOpportunity":
                    updateOpportunity(request, response);
                    break;
                case "updateLearningMaterial":
                    updateLearningMaterial(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            switch (action != null ? action : "") {
                case "deleteUser":
                    deleteUser(request, response);
                    break;
                case "deleteProduct":
                    deleteProduct(request, response);
                    break;
                case "deleteOpportunity":
                    deleteOpportunity(request, response);
                    break;
                case "deleteLearningMaterial":
                    deleteLearningMaterial(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    private void getDashboardStats(HttpServletResponse response) throws IOException {
        Map<String, Object> stats = new HashMap<>();

        // User stats
        int totalUsers = userDAO.getTotalUsersCount();
        int totalFarmers = userDAO.getUsersCountByRole("FARMER");
        int totalBuyers = userDAO.getUsersCountByRole("BUYER");
        int verifiedUsers = userDAO.getVerifiedUsersCount();
        double verificationRate = totalUsers > 0 ? (double) verifiedUsers / totalUsers * 100 : 0;

        // Product stats
        int totalProducts = productDAO.getAllProducts().size();
        int availableProducts = productDAO.getAvailableProductsCount();
        int outOfStockProducts = productDAO.getOutOfStockProductsCount();

        // Opportunity stats
        int totalOpportunities = opportunityDAO.getOpportunitiesCount();
        int activeOpportunities = opportunityDAO.getActiveOpportunitiesCount();

        // Learning Materials stats
        try {
            List<LearningMaterial> allMaterials = learningMaterialDAO.getAllMaterials();
            long publishedCount = allMaterials.stream().filter(LearningMaterial::isPublished).count();
            long draftCount = allMaterials.size() - publishedCount;
            
            stats.put("totalLearningMaterials", allMaterials.size());
            stats.put("publishedMaterials", publishedCount);
            stats.put("draftMaterials", draftCount);
        } catch (Exception e) {
            stats.put("totalLearningMaterials", 0);
            stats.put("publishedMaterials", 0);
            stats.put("draftMaterials", 0);
        }

        stats.put("totalUsers", totalUsers);
        stats.put("totalFarmers", totalFarmers);
        stats.put("totalBuyers", totalBuyers);
        stats.put("verifiedUsers", verifiedUsers);
        stats.put("verificationRate", String.format("%.1f%%", verificationRate));
        stats.put("totalProducts", totalProducts);
        stats.put("availableProducts", availableProducts);
        stats.put("outOfStockProducts", outOfStockProducts);
        stats.put("totalOpportunities", totalOpportunities);
        stats.put("activeOpportunities", activeOpportunities);

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("stats", stats);

        response.getWriter().write(gson.toJson(responseData));
    }

    private void getUsers(HttpServletResponse response) throws IOException {
        List<User> users = userDAO.getAllUsers();
        List<Map<String, Object>> userData = new ArrayList<>();

        for (User user : users) {
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("id", user.getId());
            userMap.put("firstName", user.getFirstName());
            userMap.put("lastName", user.getLastName());
            userMap.put("email", user.getEmail());
            userMap.put("role", user.getRole());
            userMap.put("status", user.getStatus());
            userMap.put("verified", user.isVerified());
            userMap.put("createdAt", user.getCreatedAt());
            userMap.put("location", user.getLocation());
            userMap.put("phoneNumber", user.getPhoneNumber());

            // Handle profile picture
            if (user.getProfilePicture() != null && user.getProfilePicture().length > 0) {
                String base64Image = Base64.getEncoder().encodeToString(user.getProfilePicture());
                userMap.put("profileImage", "data:image/jpeg;base64," + base64Image);
            } else {
                userMap.put("profileImage", null);
            }

            userData.add(userMap);
        }

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("data", userData);

        response.getWriter().write(gson.toJson(responseData));
    }

    private void getRecentUsers(HttpServletResponse response) throws IOException {
        List<User> recentUsers = userDAO.getRecentUsers(5);
        List<Map<String, Object>> userData = new ArrayList<>();

        for (User user : recentUsers) {
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("id", user.getId());
            userMap.put("firstName", user.getFirstName());
            userMap.put("lastName", user.getLastName());
            userMap.put("email", user.getEmail());
            userMap.put("role", user.getRole());

            if (user.getProfilePicture() != null && user.getProfilePicture().length > 0) {
                String base64Image = Base64.getEncoder().encodeToString(user.getProfilePicture());
                userMap.put("profileImage", "data:image/jpeg;base64," + base64Image);
            } else {
                userMap.put("profileImage", null);
            }

            userData.add(userMap);
        }

        response.getWriter().write(gson.toJson(userData));
    }

    private void getProducts(HttpServletResponse response) throws IOException {
        List<Product> products = productDAO.getAllProducts();
        List<Map<String, Object>> productData = new ArrayList<>();

        for (Product product : products) {
            Map<String, Object> productMap = new HashMap<>();
            productMap.put("id", product.getId());
            productMap.put("name", product.getName());
            productMap.put("description", product.getDescription());
            productMap.put("category", product.getCategory());
            productMap.put("price", product.getPrice());
            productMap.put("quantity", product.getQuantity());
            productMap.put("unit", product.getUnit());
            productMap.put("available", product.isAvailable());
            productMap.put("sellerName", product.getSellerName());
            productMap.put("createdAt", product.getCreatedAt());

            // Handle product image
            if (product.getImage() != null && product.getImage().length > 0) {
                String base64Image = Base64.getEncoder().encodeToString(product.getImage());
                productMap.put("imageUrl", "data:image/jpeg;base64," + base64Image);
            } else {
                productMap.put("imageUrl", null);
            }

            // Add status for display
            productMap.put("status", product.isAvailable() ? "AVAILABLE" : "UNAVAILABLE");
            productMap.put("stock", product.getQuantity());

            productData.add(productMap);
        }

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("data", productData);

        response.getWriter().write(gson.toJson(responseData));
    }

    private void getRecentProducts(HttpServletResponse response) throws IOException {
        List<Product> recentProducts = productDAO.getRecentProducts(5);
        List<Map<String, Object>> productData = new ArrayList<>();

        for (Product product : recentProducts) {
            Map<String, Object> productMap = new HashMap<>();
            productMap.put("id", product.getId());
            productMap.put("name", product.getName());
            productMap.put("price", product.getPrice());
            productMap.put("quantity", product.getQuantity());
            productMap.put("available", product.isAvailable());
            productMap.put("sellerName", product.getSellerName());

            if (product.getImage() != null && product.getImage().length > 0) {
                String base64Image = Base64.getEncoder().encodeToString(product.getImage());
                productMap.put("imageUrl", "data:image/jpeg;base64," + base64Image);
            } else {
                productMap.put("imageUrl", null);
            }

            productMap.put("status", product.isAvailable() ? "AVAILABLE" : "UNAVAILABLE");

            productData.add(productMap);
        }

        response.getWriter().write(gson.toJson(productData));
    }

    private void getOpportunities(HttpServletResponse response) throws IOException {
        List<Opportunity> opportunities = opportunityDAO.getAllOpportunities();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Opportunity opportunity : opportunities) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", opportunity.getId());
            map.put("title", opportunity.getTitle());
            map.put("type", opportunity.getType());
            map.put("category", opportunity.getCategory());
            map.put("budget", opportunity.getBudget());
            map.put("deadline", opportunity.getDeadline());
            map.put("status", opportunity.getStatus());
            map.put("applicationsCount", 0); // You can add actual applications count logic
            result.add(map);
        }

        response.getWriter().write(gson.toJson(result));
    }

    private void getLearningMaterials(HttpServletResponse response) throws IOException {
        try {
            List<LearningMaterial> materials = learningMaterialDAO.getAllMaterials();
            List<Map<String, Object>> result = new ArrayList<>();

            for (LearningMaterial material : materials) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", material.getId());
                map.put("title", material.getTitle());
                map.put("contentType", material.getContentType());
                map.put("category", material.getCategory());
                map.put("difficultyLevel", material.getDifficultyLevel());
                map.put("durationMinutes", material.getDurationMinutes());
                map.put("isPublished", material.isPublished());
                map.put("createdAt", material.getCreatedAt() != null ? material.getCreatedAt().toString() : null);
                map.put("description", material.getDescription());
                map.put("contentUrl", material.getContentUrl());
                map.put("contentText", material.getContentText());
                result.add(map);
            }

            // Wrap in "data" key for DataTables
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("data", result);
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error loading learning materials: " + e.getMessage() + "\"}");
        }
    }

    private void getUserById(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User user = userDAO.getUserById(userId);

            if (user != null) {
                Map<String, Object> userMap = new HashMap<>();
                userMap.put("id", user.getId());
                userMap.put("firstName", user.getFirstName());
                userMap.put("lastName", user.getLastName());
                userMap.put("email", user.getEmail());
                userMap.put("phoneNumber", user.getPhoneNumber());
                userMap.put("role", user.getRole());
                userMap.put("location", user.getLocation());
                userMap.put("bio", user.getBio());
                userMap.put("status", user.getStatus());
                userMap.put("verified", user.isVerified());

                response.getWriter().write(gson.toJson(userMap));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"User not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid user ID\"}");
        }
    }

    private void getProductById(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            Product product = productDAO.getProductById(productId);

            if (product != null) {
                Map<String, Object> productMap = new HashMap<>();
                productMap.put("id", product.getId());
                productMap.put("name", product.getName());
                productMap.put("description", product.getDescription());
                productMap.put("category", product.getCategory());
                productMap.put("price", product.getPrice());
                productMap.put("quantity", product.getQuantity());
                productMap.put("unit", product.getUnit());
                productMap.put("available", product.isAvailable());
                productMap.put("userId", product.getUserId());

                if (product.getImage() != null && product.getImage().length > 0) {
                    String base64Image = Base64.getEncoder().encodeToString(product.getImage());
                    productMap.put("image", base64Image);
                }

                response.getWriter().write(gson.toJson(productMap));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Product not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid product ID\"}");
        }
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String status = request.getParameter("status");

            // Validate required fields
            if (firstName == null || lastName == null || email == null || password == null || role == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"All fields are required\"}");
                return;
            }

            // Check if email already exists
            if (userDAO.emailExists(email)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Email already exists\"}");
                return;
            }

            User user = new User();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setPassword(password); // In production, hash this password
            user.setRole(role);
            user.setStatus(status != null ? status : "ACTIVE");
            user.setVerified(true); // Admin created users are verified by default
            user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

            // Handle profile picture upload
            Part profilePicturePart = request.getPart("profilePicture");
            if (profilePicturePart != null && profilePicturePart.getSize() > 0) {
                byte[] profilePicture = profilePicturePart.getInputStream().readAllBytes();
                user.setProfilePicture(profilePicture);
            }

            boolean success = userDAO.addUser(user);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "User added successfully");
                result.put("userId", user.getId());
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to add user\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error adding user: " + e.getMessage() + "\"}");
        }
    }

    private void addProduct(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String quantityStr = request.getParameter("quantity");
            String unit = request.getParameter("unit");
            String availableStr = request.getParameter("available");

            // Validate required fields
            if (name == null || category == null || priceStr == null || quantityStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Name, category, price, and quantity are required\"}");
                return;
            }

            // Get current admin user from session
            HttpSession session = request.getSession(false);
            User adminUser = (session != null) ? (User) session.getAttribute("user") : null;

            if (adminUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\": \"Admin authentication required\"}");
                return;
            }

            Product product = new Product();
            product.setName(name);
            product.setDescription(description);
            product.setCategory(category);
            product.setPrice(new BigDecimal(priceStr));
            product.setQuantity(Integer.parseInt(quantityStr));
            product.setUnit(unit != null ? unit : "unit");
            product.setAvailable(availableStr == null || Boolean.parseBoolean(availableStr));
            product.setUserId(adminUser.getId());
            product.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            product.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

            // Handle product image upload
            Part imagePart = request.getPart("image");
            if (imagePart != null && imagePart.getSize() > 0) {
                byte[] image = imagePart.getInputStream().readAllBytes();
                product.setImage(image);
            }

            boolean success = productDAO.addProduct(product);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Product added successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to add product\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error adding product: " + e.getMessage() + "\"}");
        }
    }

    private void addOpportunity(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String type = request.getParameter("type");
            String category = request.getParameter("category");
            String budgetStr = request.getParameter("budget");
            String deadlineStr = request.getParameter("deadline");

            if (title == null || description == null || type == null || category == null || deadlineStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Missing required opportunity fields\"}");
                return;
            }

            // Get current admin user from session
            HttpSession session = request.getSession(false);
            User adminUser = (session != null) ? (User) session.getAttribute("user") : null;

            if (adminUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\": \"Admin authentication required\"}");
                return;
            }

            Opportunity opportunity = new Opportunity();
            opportunity.setTitle(title);
            opportunity.setDescription(description);
            opportunity.setType(type);
            opportunity.setCategory(category);
            opportunity.setBudget(budgetStr != null && !budgetStr.trim().isEmpty() ? Double.parseDouble(budgetStr) : 0.0);
            opportunity.setDeadline(java.sql.Date.valueOf(deadlineStr));
            opportunity.setCreatedBy(adminUser.getId());
            opportunity.setStatus("ACTIVE");

            boolean success = opportunityDAO.createOpportunity(opportunity);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Opportunity created successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to create opportunity\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error creating opportunity: " + e.getMessage() + "\"}");
        }
    }

    private void addLearningMaterial(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String contentType = request.getParameter("contentType");
            String contentUrl = request.getParameter("contentUrl");
            String contentText = request.getParameter("contentText");
            String category = request.getParameter("category");
            String difficultyLevel = request.getParameter("difficultyLevel");
            String durationMinutesStr = request.getParameter("durationMinutes");
            String isPublishedStr = request.getParameter("isPublished");

            if (title == null || contentType == null || category == null || difficultyLevel == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Missing required learning material fields\"}");
                return;
            }

            // Get current admin user from session
            HttpSession session = request.getSession(false);
            User adminUser = (session != null) ? (User) session.getAttribute("user") : null;

            if (adminUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\": \"Admin authentication required\"}");
                return;
            }

            LearningMaterial material = new LearningMaterial();
            material.setTitle(title);
            material.setDescription(description != null ? description : "");
            material.setContentType(contentType);
            material.setContentUrl(contentUrl);
            material.setContentText(contentText);
            material.setCategory(category);
            material.setDifficultyLevel(difficultyLevel);
            material.setDurationMinutes(durationMinutesStr != null ? Integer.parseInt(durationMinutesStr) : 30);
            material.setPublished("true".equals(isPublishedStr));
            material.setCreatedBy(adminUser.getId());

            boolean success = learningMaterialDAO.createLearningMaterial(material);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Learning material added successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to add learning material\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error adding learning material: " + e.getMessage() + "\"}");
        }
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String role = request.getParameter("role");
            String location = request.getParameter("location");
            String bio = request.getParameter("bio");
            String status = request.getParameter("status");
            String verifiedStr = request.getParameter("verified");

            User existingUser = userDAO.getUserById(userId);
            if (existingUser == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"User not found\"}");
                return;
            }

            // Update user fields
            if (firstName != null) {
                existingUser.setFirstName(firstName);
            }
            if (lastName != null) {
                existingUser.setLastName(lastName);
            }
            if (email != null) {
                existingUser.setEmail(email);
            }
            if (phoneNumber != null) {
                existingUser.setPhoneNumber(phoneNumber);
            }
            if (role != null) {
                existingUser.setRole(role);
            }
            if (location != null) {
                existingUser.setLocation(location);
            }
            if (bio != null) {
                existingUser.setBio(bio);
            }
            if (status != null) {
                existingUser.setStatus(status);
            }
            if (verifiedStr != null) {
                existingUser.setVerified(Boolean.parseBoolean(verifiedStr));
            }

            // Handle profile picture update
            Part profilePicturePart = request.getPart("profilePicture");
            if (profilePicturePart != null && profilePicturePart.getSize() > 0) {
                byte[] profilePicture = profilePicturePart.getInputStream().readAllBytes();
                existingUser.setProfilePicture(profilePicture);
            }

            boolean success = userDAO.updateUser(existingUser);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "User updated successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update user\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid user ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error updating user: " + e.getMessage() + "\"}");
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String quantityStr = request.getParameter("quantity");
            String unit = request.getParameter("unit");
            String availableStr = request.getParameter("available");

            Product existingProduct = productDAO.getProductById(productId);
            if (existingProduct == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Product not found\"}");
                return;
            }

            // Update product fields
            if (name != null) {
                existingProduct.setName(name);
            }
            if (description != null) {
                existingProduct.setDescription(description);
            }
            if (category != null) {
                existingProduct.setCategory(category);
            }
            if (priceStr != null) {
                existingProduct.setPrice(new BigDecimal(priceStr));
            }
            if (quantityStr != null) {
                existingProduct.setQuantity(Integer.parseInt(quantityStr));
            }
            if (unit != null) {
                existingProduct.setUnit(unit);
            }
            if (availableStr != null) {
                existingProduct.setAvailable(Boolean.parseBoolean(availableStr));
            }

            // Handle product image update
            Part imagePart = request.getPart("image");
            if (imagePart != null && imagePart.getSize() > 0) {
                byte[] image = imagePart.getInputStream().readAllBytes();
                existingProduct.setImage(image);
            }

            boolean success = productDAO.updateProduct(existingProduct);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Product updated successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update product\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid product ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error updating product: " + e.getMessage() + "\"}");
        }
    }

    private void updateOpportunity(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            int opportunityId = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String type = request.getParameter("type");
            String category = request.getParameter("category");
            String budgetStr = request.getParameter("budget");
            String deadlineStr = request.getParameter("deadline");
            String status = request.getParameter("status");

            Opportunity existingOpportunity = opportunityDAO.getOpportunityById(opportunityId);
            if (existingOpportunity == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Opportunity not found\"}");
                return;
            }

            // Update opportunity fields
            if (title != null) {
                existingOpportunity.setTitle(title);
            }
            if (description != null) {
                existingOpportunity.setDescription(description);
            }
            if (type != null) {
                existingOpportunity.setType(type);
            }
            if (category != null) {
                existingOpportunity.setCategory(category);
            }
            if (budgetStr != null && !budgetStr.trim().isEmpty()) {
                existingOpportunity.setBudget(Double.parseDouble(budgetStr));
            }
            if (deadlineStr != null && !deadlineStr.trim().isEmpty()) {
                existingOpportunity.setDeadline(java.sql.Date.valueOf(deadlineStr));
            }
            if (status != null) {
                existingOpportunity.setStatus(status);
            }

            boolean success = opportunityDAO.updateOpportunity(existingOpportunity);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Opportunity updated successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update opportunity\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid opportunity ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error updating opportunity: " + e.getMessage() + "\"}");
        }
    }

    private void updateLearningMaterial(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String contentType = request.getParameter("contentType");
            String contentUrl = request.getParameter("contentUrl");
            String contentText = request.getParameter("contentText");
            String category = request.getParameter("category");
            String difficultyLevel = request.getParameter("difficultyLevel");
            String durationMinutesStr = request.getParameter("durationMinutes");
            String isPublishedStr = request.getParameter("isPublished");

            LearningMaterial existingMaterial = learningMaterialDAO.getMaterialById(materialId);
            if (existingMaterial == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Learning material not found\"}");
                return;
            }

            // Update learning material fields
            if (title != null) {
                existingMaterial.setTitle(title);
            }
            if (description != null) {
                existingMaterial.setDescription(description);
            }
            if (contentType != null) {
                existingMaterial.setContentType(contentType);
            }
            if (contentUrl != null) {
                existingMaterial.setContentUrl(contentUrl);
            }
            if (contentText != null) {
                existingMaterial.setContentText(contentText);
            }
            if (category != null) {
                existingMaterial.setCategory(category);
            }
            if (difficultyLevel != null) {
                existingMaterial.setDifficultyLevel(difficultyLevel);
            }
            if (durationMinutesStr != null && !durationMinutesStr.trim().isEmpty()) {
                existingMaterial.setDurationMinutes(Integer.parseInt(durationMinutesStr));
            }
            if (isPublishedStr != null) {
                existingMaterial.setPublished("true".equals(isPublishedStr));
            }

            boolean success = learningMaterialDAO.updateLearningMaterial(existingMaterial);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Learning material updated successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update learning material\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error updating learning material: " + e.getMessage() + "\"}");
        }
    }

    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");

            if (status == null || (!status.equals("ACTIVE") && !status.equals("INACTIVE"))) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid status\"}");
                return;
            }

            boolean success = userDAO.updateUserStatus(userId, status);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "User status updated successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update user status\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid user ID\"}");
        }
    }

    private void toggleMaterialPublish(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));
            boolean publish = Boolean.parseBoolean(request.getParameter("publish"));

            LearningMaterial material = learningMaterialDAO.getMaterialById(materialId);
            if (material == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Learning material not found\"}");
                return;
            }

            material.setPublished(publish);
            boolean success = learningMaterialDAO.updateLearningMaterial(material);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", publish ? "Material published successfully" : "Material unpublished successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to update material status\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error updating material status: " + e.getMessage() + "\"}");
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));

            boolean success = userDAO.deleteUser(userId);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "User deleted successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to delete user\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid user ID\"}");
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));

            boolean success = productDAO.deleteProduct(productId);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Product deleted successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to delete product\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid product ID\"}");
        }
    }

    private void deleteOpportunity(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int opportunityId = Integer.parseInt(request.getParameter("id"));

            boolean success = opportunityDAO.deleteOpportunity(opportunityId);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Opportunity deleted successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to delete opportunity\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid opportunity ID\"}");
        }
    }

    private void deleteLearningMaterial(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));

            boolean success = learningMaterialDAO.deleteLearningMaterial(materialId);

            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Learning material deleted successfully");
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to delete learning material\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Error deleting learning material: " + e.getMessage() + "\"}");
        }
    }
}