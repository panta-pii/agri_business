package models;

import java.sql.Timestamp;
import java.util.List;

public class Conversation {
    private int id;
    private String name;
    private String type;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<User> participants;
    private Message lastMessage;
    private int unreadCount;
    
    // Constructors
    public Conversation() {}
    
    public Conversation(String type, int createdBy) {
        this.type = type;
        this.createdBy = createdBy;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public List<User> getParticipants() { return participants; }
    public void setParticipants(List<User> participants) { this.participants = participants; }
    
    public Message getLastMessage() { return lastMessage; }
    public void setLastMessage(Message lastMessage) { this.lastMessage = lastMessage; }
    
    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }
    
    // Helper methods
    public String getDisplayName(int currentUserId) {
        if (type.equals("GROUP") && name != null) {
            return name;
        } else if (type.equals("DIRECT") && participants != null) {
            for (User participant : participants) {
                if (participant.getId() != currentUserId) {
                    return participant.getFirstName() + " " + participant.getLastName();
                }
            }
        }
        return "Unknown";
    }
}