/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Servlet;



import daos.ProductDAO;
import models.Product;
import models.User;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/ProductServlet")
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024, // 5MB
    maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject jsonResponse = new JSONObject();
        PrintWriter out = response.getWriter();
        
        try {
            if ("categories".equals(action)) {
                // Get all categories
                JSONArray categories = new JSONArray(productDAO.getDistinctCategories());
                jsonResponse.put("success", true);
                jsonResponse.put("categories", categories);
                
            } else if ("search".equals(action)) {
                // Search products
                String query = request.getParameter("query");
                if (query != null && !query.trim().isEmpty()) {
                    JSONArray products = productsToJsonArray(productDAO.searchProducts(query));
                    jsonResponse.put("success", true);
                    jsonResponse.put("products", products);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Search query is required");
                }
                
            } else if ("category".equals(action)) {
                // Get products by category
                String category = request.getParameter("category");
                if (category != null && !category.trim().isEmpty()) {
                    JSONArray products = productsToJsonArray(productDAO.getProductsByCategory(category));
                    jsonResponse.put("success", true);
                    jsonResponse.put("products", products);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Category is required");
                }
                
            } else {
                // Get all products
                JSONArray products = productsToJsonArray(productDAO.getAllAvailableProducts());
                jsonResponse.put("success", true);
                jsonResponse.put("products", products);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject jsonResponse = new JSONObject();
        PrintWriter out = response.getWriter();
        
        try {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            
            if (user == null) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Please login to perform this action");
                out.print(jsonResponse.toString());
                return;
            }
            
            if ("add".equals(action)) {
                addProduct(request, response, user, jsonResponse);
            } else if ("update".equals(action)) {
                updateProduct(request, response, user, jsonResponse);
            } else if ("delete".equals(action)) {
                deleteProduct(request, response, user, jsonResponse);
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Invalid action");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
    
    private void addProduct(HttpServletRequest request, HttpServletResponse response, 
                           User user, JSONObject jsonResponse) throws Exception {
        
        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");
        String unit = request.getParameter("unit");
        Part imagePart = request.getPart("image");
        
        // Validate required fields
        if (name == null || name.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product name is required");
            return;
        }
        
        if (description == null || description.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product description is required");
            return;
        }
        
        if (priceStr == null || priceStr.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Price is required");
            return;
        }
        
        // Create product object
        Product product = new Product();
        product.setUserId(user.getId());
        product.setName(name.trim());
        product.setDescription(description.trim());
        product.setCategory(category != null ? category.trim() : "Other");
        product.setPrice(new BigDecimal(priceStr));
        product.setQuantity(new BigDecimal(quantityStr != null ? quantityStr : "1"));
        product.setUnit(unit != null ? unit : "kg");
        product.setAvailable(true);
        
        // Handle image upload
        if (imagePart != null && imagePart.getSize() > 0) {
            byte[] imageBytes = imagePart.getInputStream().readAllBytes();
            product.setImage(imageBytes);
        }
        
        // Save product
        boolean success = productDAO.addProduct(product);
        
        if (success) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Product added successfully");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to add product");
        }
    }
    
    private void updateProduct(HttpServletRequest request, HttpServletResponse response, 
                              User user, JSONObject jsonResponse) throws Exception {
        
        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product ID is required");
            return;
        }
        
        int productId = Integer.parseInt(productIdStr);
        Product existingProduct = productDAO.getProductById(productId);
        
        if (existingProduct == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product not found");
            return;
        }
        
        // Check if user owns the product or is admin
        if (existingProduct.getUserId() != user.getId() && !"ADMIN".equals(user.getRole())) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "You don't have permission to update this product");
            return;
        }
        
        // Update product fields
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");
        String unit = request.getParameter("unit");
        Part imagePart = request.getPart("image");
        
        if (name != null) existingProduct.setName(name.trim());
        if (description != null) existingProduct.setDescription(description.trim());
        if (category != null) existingProduct.setCategory(category.trim());
        if (priceStr != null) existingProduct.setPrice(new BigDecimal(priceStr));
        if (quantityStr != null) existingProduct.setQuantity(new BigDecimal(quantityStr));
        if (unit != null) existingProduct.setUnit(unit);
        
        // Handle image update
        if (imagePart != null && imagePart.getSize() > 0) {
            byte[] imageBytes = imagePart.getInputStream().readAllBytes();
            existingProduct.setImage(imageBytes);
        }
        
        boolean success = productDAO.updateProduct(existingProduct);
        
        if (success) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Product updated successfully");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to update product");
        }
    }
    
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response, 
                              User user, JSONObject jsonResponse) throws Exception {
        
        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product ID is required");
            return;
        }
        
        int productId = Integer.parseInt(productIdStr);
        Product existingProduct = productDAO.getProductById(productId);
        
        if (existingProduct == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Product not found");
            return;
        }
        
        // Check if user owns the product or is admin
        if (existingProduct.getUserId() != user.getId() && !"ADMIN".equals(user.getRole())) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "You don't have permission to delete this product");
            return;
        }
        
        boolean success = productDAO.deleteProduct(productId);
        
        if (success) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Product deleted successfully");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to delete product");
        }
    }
    
    private JSONArray productsToJsonArray(List<Product> products) {
        JSONArray jsonArray = new JSONArray();
        for (Product product : products) {
            JSONObject jsonProduct = new JSONObject();
            jsonProduct.put("id", product.getId());
            jsonProduct.put("name", product.getName());
            jsonProduct.put("description", product.getDescription());
            jsonProduct.put("category", product.getCategory());
            jsonProduct.put("price", product.getPrice());
            jsonProduct.put("quantity", product.getQuantity());
            jsonProduct.put("unit", product.getUnit());
            jsonProduct.put("sellerName", product.getSellerName());
            jsonProduct.put("createdAt", product.getCreatedAt().toString());
            jsonArray.put(jsonProduct);
        }
        return jsonArray;
    }
}