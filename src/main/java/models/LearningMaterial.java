package models;

import java.sql.Timestamp;

public class LearningMaterial {
    private int id;
    private String title;
    private String description;
    private String contentType;
    private String contentUrl;
    private String contentText;
    private String category;
    private String difficultyLevel;
    private int durationMinutes;
    private boolean isPublished;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public LearningMaterial() {}
    
    public LearningMaterial(int id, String title, String description, String contentType, 
                          String contentUrl, String contentText, String category, 
                          String difficultyLevel, int durationMinutes, boolean isPublished, 
                          int createdBy, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.contentType = contentType;
        this.contentUrl = contentUrl;
        this.contentText = contentText;
        this.category = category;
        this.difficultyLevel = difficultyLevel;
        this.durationMinutes = durationMinutes;
        this.isPublished = isPublished;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    
    public String getContentUrl() { return contentUrl; }
    public void setContentUrl(String contentUrl) { this.contentUrl = contentUrl; }
    
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public String getDifficultyLevel() { return difficultyLevel; }
    public void setDifficultyLevel(String difficultyLevel) { this.difficultyLevel = difficultyLevel; }
    
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }
    
    public boolean isPublished() { return isPublished; }
    public void setPublished(boolean published) { isPublished = published; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}