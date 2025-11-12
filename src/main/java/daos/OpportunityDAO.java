package daos;

import models.Opportunity;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.DBConnection;

public class OpportunityDAO {

    // Create new opportunity
    public boolean createOpportunity(Opportunity opportunity) {
        String sql = "INSERT INTO opportunities (title, description, type, category, budget, deadline, created_by, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, opportunity.getTitle());
            stmt.setString(2, opportunity.getDescription());
            stmt.setString(3, opportunity.getType());
            stmt.setString(4, opportunity.getCategory());
            
            // Handle null budget
            if (opportunity.getBudget() > 0) {
                stmt.setBigDecimal(5, new java.math.BigDecimal(opportunity.getBudget()));
            } else {
                stmt.setNull(5, java.sql.Types.DECIMAL);
            }
            
            // Handle null deadline
            if (opportunity.getDeadline() != null) {
                stmt.setDate(6, new java.sql.Date(opportunity.getDeadline().getTime()));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }
            
            stmt.setInt(7, opportunity.getCreatedBy());
            stmt.setString(8, opportunity.getStatus() != null ? opportunity.getStatus() : "ACTIVE");

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all opportunities
    public List<Opportunity> getAllOpportunities() {
        List<Opportunity> opportunities = new ArrayList<>();
        String sql = "SELECT o.*, u.first_name, u.last_name FROM opportunities o LEFT JOIN users u ON o.created_by = u.id ORDER BY o.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                opportunities.add(extractOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return opportunities;
    }

    // Get opportunity by ID
    public Opportunity getOpportunityById(int id) {
        String sql = "SELECT o.*, u.first_name, u.last_name FROM opportunities o LEFT JOIN users u ON o.created_by = u.id WHERE o.id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractOpportunity(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update opportunity
    public boolean updateOpportunity(Opportunity opportunity) {
        String sql = "UPDATE opportunities SET title=?, description=?, type=?, category=?, budget=?, deadline=?, status=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, opportunity.getTitle());
            stmt.setString(2, opportunity.getDescription());
            stmt.setString(3, opportunity.getType());
            stmt.setString(4, opportunity.getCategory());
            
            // Handle null budget
            if (opportunity.getBudget() > 0) {
                stmt.setBigDecimal(5, new java.math.BigDecimal(opportunity.getBudget()));
            } else {
                stmt.setNull(5, java.sql.Types.DECIMAL);
            }
            
            // Handle null deadline
            if (opportunity.getDeadline() != null) {
                stmt.setDate(6, new java.sql.Date(opportunity.getDeadline().getTime()));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }
            
            stmt.setString(7, opportunity.getStatus());
            stmt.setInt(8, opportunity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete opportunity
    public boolean deleteOpportunity(int id) {
        String sql = "DELETE FROM opportunities WHERE id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get opportunities count
    public int getOpportunitiesCount() {
        String sql = "SELECT COUNT(*) as count FROM opportunities";

        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get active opportunities count
    public int getActiveOpportunitiesCount() {
        String sql = "SELECT COUNT(*) as count FROM opportunities WHERE status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get filtered opportunities with database-level filtering
    public List<Opportunity> getFilteredOpportunities(String search, String category, String type) {
        List<Opportunity> opportunities = new ArrayList<>();

        // Build SQL query with filters
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, u.first_name, u.last_name FROM opportunities o "
                + "LEFT JOIN users u ON o.created_by = u.id "
                + "WHERE o.status = 'ACTIVE' " // Only show active opportunities
        );

        List<Object> parameters = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (o.title LIKE ? OR o.description LIKE ?) ");
            String searchPattern = "%" + search + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND o.category = ? ");
            parameters.add(category);
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND o.type = ? ");
            parameters.add(type);
        }

        sql.append(" ORDER BY o.created_at DESC");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                opportunities.add(extractOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return opportunities;
    }

    // Helper method to extract opportunity from ResultSet
    private Opportunity extractOpportunity(ResultSet rs) throws SQLException {
        Opportunity opportunity = new Opportunity();
        try {
            opportunity.setId(rs.getInt("id"));
            opportunity.setTitle(rs.getString("title"));
            opportunity.setDescription(rs.getString("description"));
            opportunity.setType(rs.getString("type"));
            opportunity.setCategory(rs.getString("category"));
            
            // Handle null budget
            java.math.BigDecimal budget = rs.getBigDecimal("budget");
            if (budget != null) {
                opportunity.setBudget(budget.doubleValue());
            } else {
                opportunity.setBudget(0.0);
            }
            
            // Handle date fields
            opportunity.setDeadline(rs.getDate("deadline"));
            opportunity.setCreatedAt(rs.getTimestamp("created_at"));
            opportunity.setUpdatedAt(rs.getTimestamp("updated_at"));
            
            opportunity.setCreatedBy(rs.getInt("created_by"));
            opportunity.setStatus(rs.getString("status"));

            // Get creator name if available
            try {
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                if (firstName != null && lastName != null) {
                    opportunity.setCreatorName(firstName + " " + lastName);
                } else {
                    opportunity.setCreatorName("Unknown User");
                }
            } catch (SQLException e) {
                opportunity.setCreatorName("Unknown User");
            }
        } catch (SQLException e) {
            System.err.println("Error extracting opportunity: " + e.getMessage());
            e.printStackTrace();
        }
        return opportunity;
    }
}