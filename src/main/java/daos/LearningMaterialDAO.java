package daos;

import models.LearningMaterial;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LearningMaterialDAO {
    
    // Create new learning material
    public boolean createLearningMaterial(LearningMaterial material) throws SQLException {
        String sql = "INSERT INTO learning_materials (title, description, content_type, content_url, " +
                    "content_text, category, difficulty_level, duration_minutes, is_published, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, material.getTitle());
            stmt.setString(2, material.getDescription());
            stmt.setString(3, material.getContentType());
            stmt.setString(4, material.getContentUrl());
            stmt.setString(5, material.getContentText());
            stmt.setString(6, material.getCategory());
            stmt.setString(7, material.getDifficultyLevel());
            stmt.setInt(8, material.getDurationMinutes());
            stmt.setBoolean(9, material.isPublished());
            stmt.setInt(10, material.getCreatedBy());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Get all published learning materials
    public List<LearningMaterial> getAllPublishedMaterials() throws SQLException {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT * FROM learning_materials WHERE is_published = TRUE ORDER BY created_at DESC";
        
        Connection conn = DBConnection.getConnection();
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                materials.add(extractLearningMaterial(rs));
            }
        }
        return materials;
    }
    
    // Get all learning materials (for admin)
    public List<LearningMaterial> getAllMaterials() throws SQLException {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT * FROM learning_materials ORDER BY created_at DESC";
        
        Connection conn = DBConnection.getConnection();
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                materials.add(extractLearningMaterial(rs));
            }
        }
        return materials;
    }
    
    // Get learning material by ID
    public LearningMaterial getMaterialById(int id) throws SQLException {
        String sql = "SELECT * FROM learning_materials WHERE id = ?";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractLearningMaterial(rs);
                }
            }
        }
        return null;
    }
    
    // Update learning material
    public boolean updateLearningMaterial(LearningMaterial material) throws SQLException {
        String sql = "UPDATE learning_materials SET title = ?, description = ?, content_type = ?, " +
                    "content_url = ?, content_text = ?, category = ?, difficulty_level = ?, " +
                    "duration_minutes = ?, is_published = ? WHERE id = ?";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, material.getTitle());
            stmt.setString(2, material.getDescription());
            stmt.setString(3, material.getContentType());
            stmt.setString(4, material.getContentUrl());
            stmt.setString(5, material.getContentText());
            stmt.setString(6, material.getCategory());
            stmt.setString(7, material.getDifficultyLevel());
            stmt.setInt(8, material.getDurationMinutes());
            stmt.setBoolean(9, material.isPublished());
            stmt.setInt(10, material.getId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Delete learning material
    public boolean deleteLearningMaterial(int id) throws SQLException {
        String sql = "DELETE FROM learning_materials WHERE id = ?";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Get materials by category
    public List<LearningMaterial> getMaterialsByCategory(String category) throws SQLException {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT * FROM learning_materials WHERE category = ? AND is_published = TRUE ORDER BY created_at DESC";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    materials.add(extractLearningMaterial(rs));
                }
            }
        }
        return materials;
    }
    
    // Search learning materials
    public List<LearningMaterial> searchMaterials(String query) throws SQLException {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT * FROM learning_materials WHERE is_published = TRUE AND " +
                    "(title LIKE ? OR description LIKE ? OR content_text LIKE ?) ORDER BY created_at DESC";
        
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);
            stmt.setString(3, searchTerm);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    materials.add(extractLearningMaterial(rs));
                }
            }
        }
        return materials;
    }
    
    // Extract LearningMaterial from ResultSet
    private LearningMaterial extractLearningMaterial(ResultSet rs) throws SQLException {
        return new LearningMaterial(
            rs.getInt("id"),
            rs.getString("title"),
            rs.getString("description"),
            rs.getString("content_type"),
            rs.getString("content_url"),
            rs.getString("content_text"),
            rs.getString("category"),
            rs.getString("difficulty_level"),
            rs.getInt("duration_minutes"),
            rs.getBoolean("is_published"),
            rs.getInt("created_by"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at")
        );
    }
}