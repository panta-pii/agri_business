/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package daos;



import models.Product;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
    
    public List<Product> getAllAvailableProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p " +
                    "LEFT JOIN users u ON p.user_id = u.id " +
                    "WHERE p.is_available = 1 ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Product product = extractProductFromResultSet(rs);
                // Set seller name
                String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                product.setSellerName(sellerName);
                products.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching products: " + e.getMessage());
            e.printStackTrace();
        }
        
        return products;
    }
    
    public List<Product> getProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p " +
                    "LEFT JOIN users u ON p.user_id = u.id " +
                    "WHERE p.is_available = 1 AND p.category = ? ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Product product = extractProductFromResultSet(rs);
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching products by category: " + e.getMessage());
            e.printStackTrace();
        }
        
        return products;
    }
    
    public List<Product> searchProducts(String query) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p " +
                    "LEFT JOIN users u ON p.user_id = u.id " +
                    "WHERE p.is_available = 1 AND (p.name LIKE ? OR p.description LIKE ? OR p.category LIKE ?) " +
                    "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setString(3, searchTerm);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Product product = extractProductFromResultSet(rs);
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching products: " + e.getMessage());
            e.printStackTrace();
        }
        
        return products;
    }
    
    public Product getProductById(int id) {
        Product product = null;
        String sql = "SELECT p.*, u.first_name, u.last_name FROM products p " +
                    "LEFT JOIN users u ON p.user_id = u.id WHERE p.id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    product = extractProductFromResultSet(rs);
                    String sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                    product.setSellerName(sellerName);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching product by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return product;
    }
    
    public List<String> getDistinctCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM products WHERE is_available = 1 ORDER BY category";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching categories: " + e.getMessage());
            e.printStackTrace();
        }
        
        return categories;
    }
    
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (user_id, name, description, category, price, quantity, unit, image, is_available) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, product.getUserId());
            pstmt.setString(2, product.getName());
            pstmt.setString(3, product.getDescription());
            pstmt.setString(4, product.getCategory());
            pstmt.setBigDecimal(5, product.getPrice());
            pstmt.setBigDecimal(6, product.getQuantity());
            pstmt.setString(7, product.getUnit());
            
            if (product.getImage() != null && product.getImage().length > 0) {
                pstmt.setBytes(8, product.getImage());
            } else {
                pstmt.setNull(8, Types.BLOB);
            }
            
            pstmt.setBoolean(9, product.isAvailable());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error adding product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET name=?, description=?, category=?, price=?, quantity=?, unit=?, image=?, is_available=? WHERE id=?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, product.getName());
            pstmt.setString(2, product.getDescription());
            pstmt.setString(3, product.getCategory());
            pstmt.setBigDecimal(4, product.getPrice());
            pstmt.setBigDecimal(5, product.getQuantity());
            pstmt.setString(6, product.getUnit());
            
            if (product.getImage() != null && product.getImage().length > 0) {
                pstmt.setBytes(7, product.getImage());
            } else {
                pstmt.setNull(7, Types.BLOB);
            }
            
            pstmt.setBoolean(8, product.isAvailable());
            pstmt.setInt(9, product.getId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM products WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    private Product extractProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setUserId(rs.getInt("user_id"));
        product.setName(rs.getString("name"));
        product.setDescription(rs.getString("description"));
        product.setCategory(rs.getString("category"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setQuantity(rs.getBigDecimal("quantity"));
        product.setUnit(rs.getString("unit"));
        product.setAvailable(rs.getBoolean("is_available"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Handle image blob
        Blob imageBlob = rs.getBlob("image");
        if (imageBlob != null) {
            product.setImage(imageBlob.getBytes(1, (int) imageBlob.length()));
        }
        
        return product;
    }
}