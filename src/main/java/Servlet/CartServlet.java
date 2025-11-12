package Servlet;

import daos.ProductDAO;
import models.Product;
import models.User;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private ProductDAO productDAO;
    private Gson gson;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/agri_business";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    public void init() {
        productDAO = new ProductDAO();
        gson = new GsonBuilder().setPrettyPrinting().create();
        
        // Load JDBC driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        handleCartRequest(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        handleCartRequest(request, response);
    }

    private void handleCartRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(true);
        
        // Fix: Use SerializableUser instead of User if User is not serializable
        SerializableUser user = getSerializableUser(session);

        Map<String, Object> result = new HashMap<>();
        List<SerializableCartItem> cart = null;

        try {
            String action = request.getParameter("action");
            System.out.println("🧩 CartServlet action: " + action + " | User: " +
                    (user != null ? user.getEmail() : "Guest"));

            if (action == null || action.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "Missing action parameter");
                out.print(gson.toJson(result));
                return;
            }

            if (user != null && user.getId() > 0) {
                // Logged-in user - use database cart
                switch (action) {
                    case "add":
                        addToCartDatabase(user.getId(), request);
                        break;
                    case "remove":
                        removeFromCartDatabase(user.getId(), request);
                        break;
                    case "clear":
                        clearCartDatabase(user.getId());
                        break;
                    case "get":
                    case "checkout":
                        break;
                    default:
                        result.put("success", false);
                        result.put("message", "Invalid action");
                }
                cart = getCartFromDatabase(user.getId());
            } else {
                // Guest session - use session cart
                cart = getSessionCart(session);

                switch (action) {
                    case "add":
                        addToCartSession(request, cart);
                        break;
                    case "remove":
                        removeFromCartSession(request, cart);
                        break;
                    case "clear":
                        cart.clear();
                        break;
                    case "get":
                    case "checkout":
                        break;
                    default:
                        result.put("success", false);
                        result.put("message", "Invalid action");
                }
                
                // Update session with serializable cart
                session.setAttribute("cart", new ArrayList<>(cart));
            }

            // Checkout validation
            if ("checkout".equals(action)) {
                if (cart == null || cart.isEmpty()) {
                    result.put("success", false);
                    result.put("message", "Your cart is empty. Please add products first.");
                } else {
                    result.put("success", true);
                    result.put("message", "Cart validated for checkout.");
                }
            } else if (!result.containsKey("success")) {
                result.put("success", true);
                result.put("message", "Action completed successfully");
            }

            // Prepare cart data for response
            List<Map<String, Object>> cartData = prepareCartData(cart);
            result.put("cart", cartData);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Error: " + e.getMessage());
            result.put("cart", new ArrayList<>());
        }

        out.print(gson.toJson(result));
        out.flush();
    }

    // ✅ DATABASE METHODS

    private void addToCartDatabase(int userId, HttpServletRequest request) throws SQLException {
        int productId = parseIntSafe(request.getParameter("id"), -1);
        int quantity = parseIntSafe(request.getParameter("qty"), 1);

        System.out.println("🟢 Add DB - User: " + userId + " | Product: " + productId + " | Qty: " + quantity);

        if (productId <= 0) throw new IllegalArgumentException("Invalid product ID");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            // Check if exists
            String checkSql = "SELECT quantity FROM cart_items WHERE user_id = ? AND product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String updateSql = "UPDATE cart_items SET quantity = quantity + ?, updated_at = NOW() WHERE user_id = ? AND product_id = ?";
                    try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                        ups.setInt(1, quantity);
                        ups.setInt(2, userId);
                        ups.setInt(3, productId);
                        ups.executeUpdate();
                        System.out.println("🟢 Quantity updated in DB cart");
                    }
                } else {
                    String insertSql = "INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)";
                    try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
                        ins.setInt(1, userId);
                        ins.setInt(2, productId);
                        ins.setInt(3, quantity);
                        ins.executeUpdate();
                        System.out.println("🟢 Added new product to DB cart");
                    }
                }
            }
        }
    }

    private void removeFromCartDatabase(int userId, HttpServletRequest request) throws SQLException {
        String rawId = request.getParameter("id");
        int productId = parseIntSafe(rawId, -1);
        System.out.println("🛑 Remove DB - User: " + userId + " | Product ID: " + productId + " | Raw: " + rawId);

        if (productId <= 0) {
            System.out.println("❌ Invalid or missing product ID for DB removal");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM cart_items WHERE user_id = ? AND product_id = ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            int rows = ps.executeUpdate();
            System.out.println("✅ DB cart removal: " + rows + " item(s) removed");
        }
    }

    private void clearCartDatabase(int userId) throws SQLException {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM cart_items WHERE user_id = ?")) {
            ps.setInt(1, userId);
            int rows = ps.executeUpdate();
            System.out.println("🧹 Cleared DB cart for user: " + userId + " | Rows: " + rows);
        }
    }

    private List<SerializableCartItem> getCartFromDatabase(int userId) {
        List<SerializableCartItem> cart = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT ci.product_id, p.name, p.price, ci.quantity, p.image " +
                             "FROM cart_items ci JOIN products p ON ci.product_id = p.id " +
                             "WHERE ci.user_id = ? AND p.is_available = 1 ORDER BY ci.created_at DESC")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SerializableCartItem item = new SerializableCartItem(
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getBigDecimal("price"),
                        rs.getInt("quantity"),
                        "ImageServlet?id=" + rs.getInt("product_id")
                );
                cart.add(item);
            }
            System.out.println("📦 DB Cart items retrieved: " + cart.size());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cart;
    }

    // ✅ SESSION CART METHODS

    @SuppressWarnings("unchecked")
    private List<SerializableCartItem> getSessionCart(HttpSession session) {
        List<SerializableCartItem> cart = (List<SerializableCartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", new ArrayList<>(cart)); // Ensure serializable list
        }
        return new ArrayList<>(cart); // Return a copy to avoid concurrent modification
    }

    private void addToCartSession(HttpServletRequest request, List<SerializableCartItem> cart) {
        int productId = parseIntSafe(request.getParameter("id"), -1);
        int quantity = parseIntSafe(request.getParameter("qty"), 1);
        System.out.println("🟢 Add session - Product: " + productId + " | Qty: " + quantity);

        if (productId <= 0) throw new IllegalArgumentException("Invalid product ID");

        // Check if item already exists in cart
        for (SerializableCartItem item : cart) {
            if (item.getProductId() == productId) {
                item.setQuantity(item.getQuantity() + quantity);
                System.out.println("🔄 Session cart quantity updated");
                return;
            }
        }

        // Add new item
        Product product = productDAO.getProductById(productId);
        if (product != null) {
            SerializableCartItem newItem = new SerializableCartItem(
                product.getId(), 
                product.getName(), 
                product.getPrice(), 
                quantity,
                "ImageServlet?id=" + product.getId()
            );
            cart.add(newItem);
            System.out.println("🆕 Added new item to session cart");
        } else {
            System.out.println("❌ Product not found for ID: " + productId);
            throw new IllegalArgumentException("Product not found");
        }
    }

    private void removeFromCartSession(HttpServletRequest request, List<SerializableCartItem> cart) {
        String rawId = request.getParameter("id");
        int productId = parseIntSafe(rawId, -1);
        System.out.println("🛑 Remove session - Product ID: " + productId + " | Raw: " + rawId);

        if (productId <= 0) {
            System.out.println("❌ Invalid or missing product ID for session removal");
            return;
        }

        boolean removed = cart.removeIf(item -> item.getProductId() == productId);
        System.out.println("✅ Session cart removal status: " + removed);
    }

    // ✅ HELPER METHODS

    private SerializableUser getSerializableUser(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user != null) {
            return new SerializableUser(user.getId(), user.getEmail(), user.getFirstName(), user.getLastName());
        }
        return null;
    }

    private List<Map<String, Object>> prepareCartData(List<SerializableCartItem> cart) {
        List<Map<String, Object>> cartData = new ArrayList<>();
        if (cart == null) return cartData;

        for (SerializableCartItem item : cart) {
            if (item.getProductId() <= 0) continue;

            Map<String, Object> map = new HashMap<>();
            map.put("id", item.getProductId());
            map.put("name", item.getName());
            map.put("price", item.getPrice() != null ? item.getPrice().doubleValue() : 0.0);
            map.put("qty", item.getQuantity());
            map.put("image", item.getImageUrl());
            cartData.add(map);

            System.out.println("✅ Prepared cart item: " + item.getName() + " (ID: " + item.getProductId() + ")");
        }
        return cartData;
    }

    private int parseIntSafe(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    // ✅ SERIALIZABLE INNER CLASSES

    public static class SerializableCartItem implements Serializable {
        private static final long serialVersionUID = 1L;
        
        private int productId;
        private String name;
        private BigDecimal price;
        private int quantity;
        private String imageUrl;

        public SerializableCartItem() {
            // Default constructor for serialization
        }

        public SerializableCartItem(int productId, String name, BigDecimal price, int quantity, String imageUrl) {
            this.productId = productId;
            this.name = name;
            this.price = price;
            this.quantity = quantity;
            this.imageUrl = imageUrl;
        }

        // Getters and setters
        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }
        
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        
        public String getImageUrl() { return imageUrl; }
        public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            SerializableCartItem that = (SerializableCartItem) o;
            return productId == that.productId;
        }

        @Override
        public int hashCode() {
            return Objects.hash(productId);
        }
    }

    public static class SerializableUser implements Serializable {
        private static final long serialVersionUID = 1L;
        
        private int id;
        private String email;
        private String firstName;
        private String lastName;

        public SerializableUser() {
            // Default constructor for serialization
        }

        public SerializableUser(int id, String email, String firstName, String lastName) {
            this.id = id;
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
        }

        // Getters and setters
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
    }
}