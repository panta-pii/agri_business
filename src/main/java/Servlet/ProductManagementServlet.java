package Servlet;

import java.io.*;
import java.math.BigDecimal;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

import org.json.JSONObject;
import daos.ProductDAO;
import models.Product;
import models.User;

@WebServlet("/ProductManagementServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class ProductManagementServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONObject json = new JSONObject();
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            json.put("success", false).put("message", "User not logged in.");
            out.print(json.toString());
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        try {
            switch (action) {
                case "add":
                    addProduct(request, user, json);
                    break;
                case "update":
                    updateProduct(request, user, json);
                    break;
                case "delete":
                    deleteProduct(request, user, json);
                    break;
                default:
                    json.put("success", false).put("message", "Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false).put("message", "Server error: " + e.getMessage());
        }
        out.print(json.toString());
        out.flush();
    }

    private void addProduct(HttpServletRequest request, User user, JSONObject json) throws Exception {
        Product product = new Product();
        product.setUserId(user.getId());
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));
        product.setCategory(request.getParameter("category"));
        product.setPrice(new BigDecimal(request.getParameter("price")));
        product.setQuantity(Integer.parseInt(request.getParameter("quantity"))); // Fixed
        product.setUnit(request.getParameter("unit"));
        product.setAvailable(true);

        Part imagePart = request.getPart("image");
        if (imagePart != null && imagePart.getSize() > 0) {
            product.setImage(imagePart.getInputStream().readAllBytes());
        }

        boolean success = productDAO.addProduct(product);
        json.put("success", success)
                .put("message", success ? "Product added!" : "Failed to add product");
    }

    private void updateProduct(HttpServletRequest request, User user, JSONObject json) throws Exception {
        int id = Integer.parseInt(request.getParameter("id"));
        Product existing = productDAO.getProductById(id);
        if (existing == null || existing.getUserId() != user.getId()) {
            json.put("success", false).put("message", "Unauthorized");
            return;
        }

        existing.setName(request.getParameter("name"));
        existing.setDescription(request.getParameter("description"));
        existing.setCategory(request.getParameter("category"));
        existing.setPrice(new BigDecimal(request.getParameter("price")));
        existing.setQuantity(Integer.parseInt(request.getParameter("quantity"))); // Fixed
        existing.setUnit(request.getParameter("unit"));

        Part imagePart = request.getPart("image");
        if (imagePart != null && imagePart.getSize() > 0) {
            existing.setImage(imagePart.getInputStream().readAllBytes());
        }

        boolean success = productDAO.updateProduct(existing);
        json.put("success", success)
                .put("message", success ? "Updated successfully!" : "Update failed");
    }

    private void deleteProduct(HttpServletRequest request, User user, JSONObject json) {
        int id = Integer.parseInt(request.getParameter("id"));
        Product existing = productDAO.getProductById(id);
        if (existing == null || existing.getUserId() != user.getId()) {
            json.put("success", false).put("message", "Unauthorized or not found");
            return;
        }
        boolean success = productDAO.deleteProduct(id);
        json.put("success", success)
                .put("message", success ? "Deleted!" : "Delete failed");
    }
}
