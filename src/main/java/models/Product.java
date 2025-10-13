/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {
    private int id;
    private int userId;
    private String name;
    private String description;
    private String category;
    private BigDecimal price;
    private BigDecimal quantity;
    private String unit;
    private byte[] image;
    private boolean isAvailable;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String sellerName; // For display purposes
    
    // Constructors
    public Product() {}
    
    public Product(int id, String name, String description, String category, 
                  BigDecimal price, BigDecimal quantity, String unit) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.quantity = quantity;
        this.unit = unit;
    }
    
    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    
    public byte[] getImage() { return image; }
    public void setImage(byte[] image) { this.image = image; }
    
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean isAvailable) { this.isAvailable = isAvailable; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }
    
    // Helper method to get display price
    public String getDisplayPrice() {
        return "M " + price.toString();
    }
    
    // Helper method to get short description
    public String getShortDescription() {
        if (description.length() > 100) {
            return description.substring(0, 100) + "...";
        }
        return description;
    }
}