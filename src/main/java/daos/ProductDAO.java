package daos;

import java.sql.*;
import java.util.*;
import models.Product;
import utils.DBConnection;

public class ProductDAO {

    // Create
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (user_id, name, description, category, price, quantity, unit, image, is_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, product.getUserId());
            stmt.setString(2, product.getName());
            stmt.setString(3, product.getDescription());
            stmt.setString(4, product.getCategory());
            stmt.setBigDecimal(5, product.getPrice());
            stmt.setInt(6, product.getQuantity());
            stmt.setString(7, product.getUnit());
            stmt.setBytes(8, product.getImage());
            stmt.setBoolean(9, product.isAvailable());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all products (for admin)
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p LEFT JOIN users u ON p.user_id = u.id ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Product product = extractProduct(rs);
                // Set seller name
                try {
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                } catch (SQLException e) {
                    product.setSellerName("Unknown");
                }
                products.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Read all for a specific user
    public List<Product> getProductsByUser(int userId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(extractProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Read one
    public Product getProductById(int id) {
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p LEFT JOIN users u ON p.user_id = u.id WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Product product = extractProduct(rs);
                try {
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                } catch (SQLException e) {
                    product.setSellerName("Unknown");
                }
                return product;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update
    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, description=?, category=?, price=?, quantity=?, unit=?, image=?, is_available=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getName());
            stmt.setString(2, p.getDescription());
            stmt.setString(3, p.getCategory());
            stmt.setBigDecimal(4, p.getPrice());
            stmt.setInt(5, p.getQuantity());
            stmt.setString(6, p.getUnit());
            stmt.setBytes(7, p.getImage());
            stmt.setBoolean(8, p.isAvailable());
            stmt.setInt(9, p.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete
    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Product> searchProducts(String search) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE name LIKE ? OR description LIKE ? AND is_available = true";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            String searchPattern = "%" + search + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                products.add(extractProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Get all available products
    public List<Product> getAllAvailableProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE is_available = 1 ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                products.add(extractProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Get products by category
    public List<Product> getProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category = ? AND is_available = 1 ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(extractProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Get available products count
    public int getAvailableProductsCount() {
        String sql = "SELECT COUNT(*) as count FROM products WHERE is_available = 1";
        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get out of stock products count
    public int getOutOfStockProductsCount() {
        String sql = "SELECT COUNT(*) as count FROM products WHERE quantity = 0 OR is_available = 0";
        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get recent products
    public List<Product> getRecentProducts(int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p LEFT JOIN users u ON p.user_id = u.id ORDER BY p.created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Product product = extractProduct(rs);
                try {
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                } catch (SQLException e) {
                    product.setSellerName("Unknown");
                }
                products.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public Map<String, List<Integer>> getMonthlyProductCounts(int months) {
        Map<String, List<Integer>> demandData = new LinkedHashMap<>();
        String sql = """
        SELECT 
            category,
            MONTH(created_at) as month, 
            COUNT(*) as product_count
        FROM products 
        WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
        GROUP BY category, MONTH(created_at)
        ORDER BY category, month;
    """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, months);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String category = rs.getString("category");
                int month = rs.getInt("month");
                int productCount = rs.getInt("product_count");

                // Initialize if not exists
                if (!demandData.containsKey(category)) {
                    demandData.put(category, new ArrayList<>());
                }

                // Add to the category's monthly counts
                demandData.get(category).add(productCount);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Return empty map instead of null
            return new HashMap<>();
        }

        return demandData;
    }

    private Product extractProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        try {
            p.setId(rs.getInt("id"));
            p.setUserId(rs.getInt("user_id"));
            p.setName(rs.getString("name"));
            p.setDescription(rs.getString("description"));
            p.setCategory(rs.getString("category"));
            p.setPrice(rs.getBigDecimal("price"));
            p.setQuantity(rs.getBigDecimal("quantity").intValue());
            p.setUnit(rs.getString("unit"));
            p.setImage(rs.getBytes("image"));

            // Use is_available column (not available)
            p.setAvailable(rs.getBoolean("is_available"));

            p.setCreatedAt(rs.getTimestamp("created_at"));
            p.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException e) {
            System.err.println("Error extracting product: " + e.getMessage());
        }
        return p;
    }
}
