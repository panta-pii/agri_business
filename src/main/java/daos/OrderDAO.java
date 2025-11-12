package daos;

import models.Order;
import models.OrderItem;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.List;

public class OrderDAO {

    public int createOrder(Order order) {
        String orderSql = "INSERT INTO orders (user_email, first_name, last_name, email, phone, delivery_address, payment_method, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet generatedKeys = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            orderStmt = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            orderStmt.setString(1, order.getUserEmail());
            orderStmt.setString(2, order.getFirstName());
            orderStmt.setString(3, order.getLastName());
            orderStmt.setString(4, order.getEmail());
            orderStmt.setString(5, order.getPhone());
            orderStmt.setString(6, order.getDeliveryAddress());
            orderStmt.setString(7, order.getPaymentMethod());
            orderStmt.setBigDecimal(8, order.getTotalAmount());

            int affectedRows = orderStmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }

            generatedKeys = orderStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                int orderId = generatedKeys.getInt(1);

                itemStmt = conn.prepareStatement(itemSql);
                for (OrderItem item : order.getOrderItems()) {
                    itemStmt.setInt(1, orderId);
                    itemStmt.setInt(2, item.getProductId());
                    itemStmt.setString(3, item.getProductName());
                    itemStmt.setInt(4, item.getQuantity());
                    itemStmt.setBigDecimal(5, item.getUnitPrice());
                    itemStmt.setBigDecimal(6, item.getSubtotal());
                    itemStmt.addBatch();
                }
                itemStmt.executeBatch();

                conn.commit();
                return orderId;
            } else {
                throw new SQLException("Creating order failed, no ID obtained.");
            }

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return -1;
        } finally {
            try {
                if (generatedKeys != null) generatedKeys.close();
                if (itemStmt != null) itemStmt.close();
                if (orderStmt != null) orderStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}