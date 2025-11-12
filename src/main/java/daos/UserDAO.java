package daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.User;
import utils.DBConnection;

public class UserDAO {
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (first_name, last_name, email, password, phone_number, role, location, bio, profile_picture, is_verified, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPassword());
            stmt.setString(5, user.getPhoneNumber());
            stmt.setString(6, user.getRole());
            stmt.setString(7, user.getLocation());
            stmt.setString(8, user.getBio());
            if (user.getProfilePicture() != null && user.getProfilePicture().length > 0) {
                stmt.setBytes(9, user.getProfilePicture());
            } else {
                stmt.setNull(9, Types.BLOB);
            }
            stmt.setBoolean(10, user.isVerified());
            stmt.setString(11, user.getStatus());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Get user by email (for login) */
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return extractUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Get user by ID */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return extractUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Check if email already exists */
    public boolean emailExists(String email) {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Update user profile */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET first_name = ?, last_name = ?, email = ?, phone_number = ?, "
                   + "location = ?, bio = ?, role = ?, status = ?, is_verified = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPhoneNumber());
            stmt.setString(5, user.getLocation());
            stmt.setString(6, user.getBio());
            stmt.setString(7, user.getRole());
            stmt.setString(8, user.getStatus());
            stmt.setBoolean(9, user.isVerified());
            stmt.setInt(10, user.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Update password */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, newPassword);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Update profile picture */
    public boolean updateProfilePicture(int userId, byte[] profilePicture) {
        String sql = "UPDATE users SET profile_picture = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (profilePicture != null) stmt.setBytes(1, profilePicture);
            else stmt.setNull(1, Types.BLOB);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Delete user */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Extract user from ResultSet */
    private User extractUser(ResultSet rs) throws SQLException {
        User user = new User();
        try {
            user.setId(rs.getInt("id"));
            user.setFirstName(rs.getString("first_name"));
            user.setLastName(rs.getString("last_name"));
            user.setEmail(rs.getString("email"));
            user.setPassword(rs.getString("password"));
            user.setPhoneNumber(rs.getString("phone_number"));
            user.setRole(rs.getString("role"));
            user.setLocation(rs.getString("location"));
            user.setBio(rs.getString("bio"));
            user.setProfilePicture(rs.getBytes("profile_picture"));
            user.setVerified(rs.getBoolean("is_verified"));
            user.setStatus(rs.getString("status"));
            user.setCreatedAt(rs.getTimestamp("created_at"));
            user.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException e) {
            System.err.println("Error extracting user: " + e.getMessage());
        }
        return user;
    }

    /** Get all users */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, first_name, last_name, email, password, phone_number, role, location, bio, profile_picture, is_verified, status, created_at, updated_at "
                   + "FROM users ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) users.add(extractUser(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    /** Get recent users */
    public List<User> getRecentUsers(int limit) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) users.add(extractUser(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    /** Verify user */
    public boolean verifyUser(int userId) {
        String sql = "UPDATE users SET is_verified = 1, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Update user status */
    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Count users by role */
    public int getUsersCountByRole(String role) {
        String sql = "SELECT COUNT(*) AS count FROM users WHERE role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, role);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt("count");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Total users count */
    public int getTotalUsersCount() {
        String sql = "SELECT COUNT(*) AS count FROM users";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) return rs.getInt("count");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Verified users count */
    public int getVerifiedUsersCount() {
        String sql = "SELECT COUNT(*) AS count FROM users WHERE is_verified = 1";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) return rs.getInt("count");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Get users by status */
    public List<User> getUsersByStatus(String status) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE status = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) users.add(extractUser(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    /** Search users by name or email */
    public List<User> searchUsers(String query) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + query + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) users.add(extractUser(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    /** Create user (admin use) */
    public boolean createUser(String firstName, String lastName, String email, String password, String role, String status) {
        String sql = "INSERT INTO users (first_name, last_name, email, password, role, status, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, firstName);
            stmt.setString(2, lastName);
            stmt.setString(3, email);
            stmt.setString(4, password);
            stmt.setString(5, role);
            stmt.setString(6, status);
            stmt.setBoolean(7, true);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
