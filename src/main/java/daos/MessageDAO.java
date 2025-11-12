package daos;

import models.Conversation;
import models.Message;
import models.User;
import utils.DBConnection;

import java.sql.*;
import java.util.*;

public class MessageDAO {
    
    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // Get or create direct conversation between two users
    public int getOrCreateDirectConversation(int user1Id, int user2Id) throws SQLException {
        String sql = "SELECT c.id FROM conversations c " +
                    "JOIN conversation_participants cp1 ON c.id = cp1.conversation_id " +
                    "JOIN conversation_participants cp2 ON c.id = cp2.conversation_id " +
                    "WHERE c.type = 'DIRECT' AND cp1.user_id = ? AND cp2.user_id = ? " +
                    "LIMIT 1";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, user1Id);
            stmt.setInt(2, user2Id);
            
            rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        // Create new conversation
        return createDirectConversation(user1Id, user2Id);
    }
    
    private int createDirectConversation(int user1Id, int user2Id) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Create conversation
            String convSql = "INSERT INTO conversations (type, created_by, created_at, updated_at) VALUES ('DIRECT', ?, NOW(), NOW())";
            stmt = conn.prepareStatement(convSql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, user1Id);
            stmt.executeUpdate();
            
            rs = stmt.getGeneratedKeys();
            if (!rs.next()) throw new SQLException("Failed to create conversation");
            int conversationId = rs.getInt(1);
            
            // Close resources before reusing statement
            closeResources(rs, stmt, null);
            
            // Add participants
            String partSql = "INSERT INTO conversation_participants (conversation_id, user_id) VALUES (?, ?)";
            stmt = conn.prepareStatement(partSql);
            stmt.setInt(1, conversationId);
            stmt.setInt(2, user1Id);
            stmt.executeUpdate();
            
            stmt.setInt(2, user2Id);
            stmt.executeUpdate();
            
            conn.commit();
            return conversationId;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error during rollback: " + ex.getMessage());
                }
            }
            throw e;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    // Create group conversation
    public int createGroupConversation(String name, int createdBy, List<Integer> participantIds) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Create conversation
            String convSql = "INSERT INTO conversations (name, type, created_by, created_at, updated_at) VALUES (?, 'GROUP', ?, NOW(), NOW())";
            stmt = conn.prepareStatement(convSql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, name);
            stmt.setInt(2, createdBy);
            stmt.executeUpdate();
            
            rs = stmt.getGeneratedKeys();
            if (!rs.next()) throw new SQLException("Failed to create group conversation");
            int conversationId = rs.getInt(1);
            
            // Close resources before reusing statement
            closeResources(rs, stmt, null);
            
            // Add participants
            String partSql = "INSERT INTO conversation_participants (conversation_id, user_id, role) VALUES (?, ?, ?)";
            stmt = conn.prepareStatement(partSql);
            
            // Add creator as admin
            stmt.setInt(1, conversationId);
            stmt.setInt(2, createdBy);
            stmt.setString(3, "ADMIN");
            stmt.executeUpdate();
            
            // Add other participants as members
            for (Integer userId : participantIds) {
                if (userId != createdBy) {
                    stmt.setInt(1, conversationId);
                    stmt.setInt(2, userId);
                    stmt.setString(3, "MEMBER");
                    stmt.executeUpdate();
                }
            }
            
            conn.commit();
            return conversationId;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error during rollback: " + ex.getMessage());
                }
            }
            throw e;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    // Get or create community chat
    public int getOrCreateCommunityChat() throws SQLException {
        String sql = "SELECT id FROM conversations WHERE type = 'COMMUNITY' LIMIT 1";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        // Create community chat if it doesn't exist
        return createCommunityChat();
    }
    
    private int createCommunityChat() throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Create community conversation
            String convSql = "INSERT INTO conversations (name, type, created_by, created_at, updated_at) VALUES ('AgriYouth Community', 'COMMUNITY', 1, NOW(), NOW())";
            stmt = conn.prepareStatement(convSql, Statement.RETURN_GENERATED_KEYS);
            stmt.executeUpdate();
            
            rs = stmt.getGeneratedKeys();
            if (!rs.next()) throw new SQLException("Failed to create community chat");
            int conversationId = rs.getInt(1);
            
            conn.commit();
            return conversationId;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error during rollback: " + ex.getMessage());
                }
            }
            throw e;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    // Add user to community chat
    public void addUserToCommunityChat(int userId) throws SQLException {
        // Get or create community chat
        int communityId = getOrCreateCommunityChat();
        
        String sql = "INSERT IGNORE INTO conversation_participants (conversation_id, user_id, role) VALUES (?, ?, 'MEMBER')";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, communityId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } finally {
            closeResources(null, stmt, conn);
        }
    }
    
    // Ensure user is in community chat
    public void ensureUserInCommunityChat(int userId) throws SQLException {
        String checkSql = "SELECT 1 FROM conversation_participants cp " +
                         "JOIN conversations c ON cp.conversation_id = c.id " +
                         "WHERE cp.user_id = ? AND c.type = 'COMMUNITY'";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(checkSql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();
            
            // If user is not in community chat, add them
            if (!rs.next()) {
                addUserToCommunityChat(userId);
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    // Send message
    public int sendMessage(Message message) throws SQLException {
        String sql = "INSERT INTO messages (conversation_id, sender_id, message_type, content, file_url, file_name, file_size, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            stmt.setInt(1, message.getConversationId());
            stmt.setInt(2, message.getSenderId());
            stmt.setString(3, message.getMessageType());
            stmt.setString(4, message.getContent());
            stmt.setString(5, message.getFileUrl());
            stmt.setString(6, message.getFileName());
            stmt.setObject(7, message.getFileSize());
            
            stmt.executeUpdate();
            
            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return -1;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    // Get conversations for user with role-based filtering
    public List<Conversation> getRoleBasedConversations(int userId, String userRole) throws SQLException {
        // Ensure user is in community chat
        ensureUserInCommunityChat(userId);
        
        List<Conversation> allConversations = getConversationsForUser(userId);
        List<Conversation> filteredConversations = new ArrayList<>();
        
        // Always include community chat
        for (Conversation conv : allConversations) {
            if ("COMMUNITY".equals(conv.getType())) {
                filteredConversations.add(conv);
                break;
            }
        }
        
        // Get conversations based on user relationships
        List<Conversation> relationshipConversations = getConversationsFromUserRelationships(userId, userRole);
        for (Conversation relConv : relationshipConversations) {
            // Avoid duplicates
            if (!containsConversation(filteredConversations, relConv.getId())) {
                filteredConversations.add(relConv);
            }
        }
        
        return filteredConversations;
    }
    
    // Get conversations based on user relationships
    private List<Conversation> getConversationsFromUserRelationships(int userId, String userRole) throws SQLException {
        List<Conversation> conversations = new ArrayList<>();
        
        String sql;
        if ("FARMER".equals(userRole)) {
            // For farmers: get all buyers (users with BUYER role)
            sql = "SELECT DISTINCT u.id as other_user_id, u.first_name, u.last_name " +
                  "FROM users u " +
                  "WHERE u.role = 'BUYER' " +
                  "AND u.id != ? " +
                  "ORDER BY u.created_at DESC";
        } else {
            // For buyers: get all farmers (users with FARMER role)
            sql = "SELECT DISTINCT u.id as other_user_id, u.first_name, u.last_name " +
                  "FROM users u " +
                  "WHERE u.role = 'FARMER' " +
                  "AND u.id != ? " +
                  "ORDER BY u.created_at DESC";
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            
            rs = stmt.executeQuery();
            
            // First, collect all user IDs
            List<Integer> otherUserIds = new ArrayList<>();
            while (rs.next()) {
                otherUserIds.add(rs.getInt("other_user_id"));
            }
            
            // Close the ResultSet and Statement before creating conversations
            closeResources(rs, stmt, null);
            
            // Now create conversations for each user
            for (Integer otherUserId : otherUserIds) {
                try {
                    int conversationId = getOrCreateDirectConversation(userId, otherUserId);
                    Conversation conv = getConversationById(conversationId);
                    if (conv != null) {
                        conversations.add(conv);
                    }
                } catch (SQLException e) {
                    // Skip if there's an error creating conversation
                    System.err.println("Error creating conversation with user " + otherUserId + ": " + e.getMessage());
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting conversations from user relationships: " + e.getMessage());
            // Return empty list instead of throwing exception
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return conversations;
    }
    
    // Get all conversations for user
    public List<Conversation> getConversationsForUser(int userId) throws SQLException {
        List<Conversation> conversations = new ArrayList<>();
        
        String sql = "SELECT c.*, " +
                    "m.content as last_message_content, " +
                    "m.created_at as last_message_time, " +
                    "m.sender_id as last_message_sender, " +
                    "u.first_name as sender_first_name, " +
                    "u.last_name as sender_last_name, " +
                    "(SELECT COUNT(*) FROM messages m2 " +
                    " WHERE m2.conversation_id = c.id AND m2.sender_id != ?) as unread_count " +
                    "FROM conversations c " +
                    "JOIN conversation_participants cp ON c.id = cp.conversation_id " +
                    "LEFT JOIN messages m ON c.id = m.conversation_id " +
                    "LEFT JOIN users u ON m.sender_id = u.id " +
                    "WHERE cp.user_id = ? " +
                    "AND (m.id = (SELECT MAX(id) FROM messages WHERE conversation_id = c.id) OR m.id IS NULL) " +
                    "ORDER BY COALESCE(m.created_at, c.created_at) DESC";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            
            rs = stmt.executeQuery();
            
            // First, collect all conversation data
            List<Conversation> tempConversations = new ArrayList<>();
            while (rs.next()) {
                Conversation conv = new Conversation();
                conv.setId(rs.getInt("id"));
                conv.setName(rs.getString("name"));
                conv.setType(rs.getString("type"));
                conv.setCreatedBy(rs.getInt("created_by"));
                conv.setCreatedAt(rs.getTimestamp("created_at"));
                conv.setUpdatedAt(rs.getTimestamp("updated_at"));
                conv.setUnreadCount(rs.getInt("unread_count"));
                
                // Set last message if exists
                if (rs.getString("last_message_content") != null) {
                    Message lastMessage = new Message();
                    lastMessage.setContent(rs.getString("last_message_content"));
                    lastMessage.setCreatedAt(rs.getTimestamp("last_message_time"));
                    lastMessage.setSenderId(rs.getInt("last_message_sender"));
                    lastMessage.setSenderName(rs.getString("sender_first_name") + " " + rs.getString("sender_last_name"));
                    conv.setLastMessage(lastMessage);
                }
                
                tempConversations.add(conv);
            }
            
            // Close the ResultSet and Statement before loading participants
            closeResources(rs, stmt, null);
            
            // Now load participants for each conversation
            for (Conversation conv : tempConversations) {
                try {
                    conv.setParticipants(getConversationParticipants(conv.getId()));
                    conversations.add(conv);
                } catch (SQLException e) {
                    System.err.println("Error loading participants for conversation " + conv.getId() + ": " + e.getMessage());
                    // Add conversation even if participants fail to load
                    conversations.add(conv);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error loading conversations: " + e.getMessage());
            throw e;
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return conversations;
    }
    
    // Get conversation by ID
    public Conversation getConversationById(int conversationId) throws SQLException {
        String sql = "SELECT c.*, " +
                    "m.content as last_message_content, " +
                    "m.created_at as last_message_time, " +
                    "m.sender_id as last_message_sender, " +
                    "u.first_name as sender_first_name, " +
                    "u.last_name as sender_last_name " +
                    "FROM conversations c " +
                    "LEFT JOIN messages m ON c.id = m.conversation_id " +
                    "LEFT JOIN users u ON m.sender_id = u.id " +
                    "WHERE c.id = ? " +
                    "AND (m.id = (SELECT MAX(id) FROM messages WHERE conversation_id = c.id) OR m.id IS NULL)";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, conversationId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Conversation conv = new Conversation();
                conv.setId(rs.getInt("id"));
                conv.setName(rs.getString("name"));
                conv.setType(rs.getString("type"));
                conv.setCreatedBy(rs.getInt("created_by"));
                conv.setCreatedAt(rs.getTimestamp("created_at"));
                conv.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                // Set last message if exists
                if (rs.getString("last_message_content") != null) {
                    Message lastMessage = new Message();
                    lastMessage.setContent(rs.getString("last_message_content"));
                    lastMessage.setCreatedAt(rs.getTimestamp("last_message_time"));
                    lastMessage.setSenderId(rs.getInt("last_message_sender"));
                    lastMessage.setSenderName(rs.getString("sender_first_name") + " " + rs.getString("sender_last_name"));
                    conv.setLastMessage(lastMessage);
                }
                
                // Close current resources before loading participants
                closeResources(rs, stmt, null);
                
                // Load participants
                conv.setParticipants(getConversationParticipants(conversationId));
                
                return conv;
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return null;
    }
    
    // Get conversation participants
    public List<User> getConversationParticipants(int conversationId) throws SQLException {
        List<User> participants = new ArrayList<>();
        
        String sql = "SELECT u.id, u.first_name, u.last_name, u.email, u.role, cp.role as participant_role " +
                    "FROM conversation_participants cp " +
                    "JOIN users u ON cp.user_id = u.id " +
                    "WHERE cp.conversation_id = ?";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, conversationId);
            
            rs = stmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                participants.add(user);
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return participants;
    }
    
    // Get messages for conversation - SIMPLIFIED VERSION
    public List<Message> getMessagesForConversation(int conversationId, int userId) throws SQLException {
        List<Message> messages = new ArrayList<>();
        
        String sql = "SELECT m.*, u.first_name, u.last_name " +
                    "FROM messages m " +
                    "JOIN users u ON m.sender_id = u.id " +
                    "WHERE m.conversation_id = ? " +
                    "ORDER BY m.created_at ASC";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, conversationId);
            
            rs = stmt.executeQuery();
            while (rs.next()) {
                Message message = new Message();
                message.setId(rs.getInt("id"));
                message.setConversationId(rs.getInt("conversation_id"));
                message.setSenderId(rs.getInt("sender_id"));
                message.setSenderName(rs.getString("first_name") + " " + rs.getString("last_name"));
                message.setMessageType(rs.getString("message_type"));
                message.setContent(rs.getString("content"));
                message.setFileUrl(rs.getString("file_url"));
                message.setFileName(rs.getString("file_name"));
                message.setFileSize(rs.getInt("file_size"));
                message.setRead(true); // Mark all as read for now
                message.setCreatedAt(rs.getTimestamp("created_at"));
                message.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                messages.add(message);
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        // Try to mark as read, but don't fail if it errors
        try {
            markMessagesAsRead(conversationId, userId);
        } catch (SQLException e) {
            System.err.println("Warning: Could not mark messages as read: " + e.getMessage());
            // Continue without marking as read
        }
        
        return messages;
    }
    
    // Mark messages as read - SIMPLIFIED VERSION
    public void markMessagesAsRead(int conversationId, int userId) throws SQLException {
        // Simple implementation - just try to update if is_read column exists
        String sql = "UPDATE messages SET is_read = 1 WHERE conversation_id = ? AND sender_id != ?";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, conversationId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If the column doesn't exist, ignore the error
            if (!e.getMessage().contains("Unknown column")) {
                System.err.println("Error marking messages as read: " + e.getMessage());
            }
        } finally {
            closeResources(null, stmt, conn);
        }
    }
    
    // Search users for messaging
    public List<User> searchUsers(String query, int currentUserId) throws SQLException {
        List<User> users = new ArrayList<>();
        
        String sql = "SELECT id, first_name, last_name, email, role " +
                    "FROM users " +
                    "WHERE (first_name LIKE ? OR last_name LIKE ? OR email LIKE ?) " +
                    "AND id != ? " +
                    "LIMIT 20";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            
            String searchTerm = "%" + query + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);
            stmt.setString(3, searchTerm);
            stmt.setInt(4, currentUserId);
            
            rs = stmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return users;
    }
    
    // Get user role
    private String getUserRole(int userId) throws SQLException {
        String sql = "SELECT role FROM users WHERE id = ?";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("role");
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return "BUYER"; // default
    }
    
    // Get conversation display name
    public String getConversationDisplayName(int conversationId, int currentUserId) throws SQLException {
        List<User> participants = getConversationParticipants(conversationId);
        
        if (participants.size() == 2) {
            // Direct message - show other user's name
            for (User user : participants) {
                if (user.getId() != currentUserId) {
                    return user.getFirstName() + " " + user.getLastName();
                }
            }
        }
        
        // Group conversation or self-chat
        String sql = "SELECT name FROM conversations WHERE id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, conversationId);
            rs = stmt.executeQuery();
            
            if (rs.next() && rs.getString("name") != null) {
                return rs.getString("name");
            }
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        // Fallback: show participant names
        StringBuilder name = new StringBuilder();
        for (User user : participants) {
            if (user.getId() != currentUserId) {
                if (name.length() > 0) name.append(", ");
                name.append(user.getFirstName());
            }
        }
        return name.length() > 0 ? name.toString() : "Conversation";
    }
    
    // Helper method to check if conversation already exists in list
    private boolean containsConversation(List<Conversation> conversations, int conversationId) {
        for (Conversation conv : conversations) {
            if (conv.getId() == conversationId) {
                return true;
            }
        }
        return false;
    }
    
    // Resource closing helper method
    private void closeResources(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing ResultSet: " + e.getMessage());
        }
        
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing Statement: " + e.getMessage());
        }
        
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing Connection: " + e.getMessage());
        }
    }
}