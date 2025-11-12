package models;

import java.sql.Timestamp;

public class Message {
    private int id;
    private int conversationId;
    private int senderId;
    private String senderName;
    private String messageType;
    private String content;
    private String fileUrl;
    private String fileName;
    private Integer fileSize;
    private boolean isRead;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public Message() {}
    
    public Message(int conversationId, int senderId, String messageType, String content) {
        this.conversationId = conversationId;
        this.senderId = senderId;
        this.messageType = messageType;
        this.content = content;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }
    
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
    
    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    
    public Integer getFileSize() { return fileSize; }
    public void setFileSize(Integer fileSize) { this.fileSize = fileSize; }
    
    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}