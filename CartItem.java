// src/main/java/models/CartItem.java
package models;

import java.math.BigDecimal;

public class CartItem {
    private int productId;
    private String name;
    private BigDecimal price;
    private int quantity;
    private String imageUrl;

    public CartItem(int productId, String name, BigDecimal price, int quantity, String imageUrl) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
    }

    // Getters
    public int getProductId() { return productId; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public int getQuantity() { return quantity; }
    public String getImageUrl() { return imageUrl; }

    // Setter
    public void setQuantity(int quantity) { this.quantity = quantity; }
}