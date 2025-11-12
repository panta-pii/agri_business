package Servlet;

import models.User;
import org.json.JSONObject;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Properties;

@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {

    private final String DB_URL = "jdbc:mysql://localhost:3306/agri_business";
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    // Email configuration - UPDATE THESE WITH REAL CREDENTIALS
    private final String SMTP_HOST = "smtp.gmail.com";
    private final String SMTP_PORT = "587";
    private final String EMAIL_USERNAME = "panta.pii@bothouniversity.com"; // CHANGE THIS
    private final String EMAIL_PASSWORD = "kfsg kbat qjtb nkda"; // CHANGE THIS

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();

        System.out.println("=== CHECKOUT PROCESS STARTED ===");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("User not logged in");
            result.put("success", false);
            result.put("message", "Please login to complete your order");
            out.print(result.toString());
            return;
        }

        // ✅ USE SESSION CART INSTEAD OF DATABASE CART
        @SuppressWarnings("unchecked")
        List<CartServlet.SerializableCartItem> cart = (List<CartServlet.SerializableCartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            System.out.println("Cart is empty");
            result.put("success", false);
            result.put("message", "Your cart is empty. Please add products first.");
            out.print(result.toString());
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        System.out.println("Processing checkout for user: " + user.getEmail() + ", Cart items: " + cart.size());

        // ✅ GET FORM DATA FROM REQUEST PARAMETERS
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String deliveryAddress = request.getParameter("deliveryAddress");
        String phoneNumber = request.getParameter("phoneNumber");
        String paymentMethod = request.getParameter("paymentMethod");

        System.out.println("Received checkout data:");
        System.out.println("First Name: " + firstName);
        System.out.println("Last Name: " + lastName);
        System.out.println("Email: " + email);
        System.out.println("Delivery Address: " + deliveryAddress);
        System.out.println("Phone Number: " + phoneNumber);
        System.out.println("Payment Method: " + paymentMethod);

        // ✅ VALIDATE REQUIRED FIELDS
        if (firstName == null || firstName.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "First name is required!");
            out.print(result.toString());
            return;
        }

        if (lastName == null || lastName.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Last name is required!");
            out.print(result.toString());
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Email address is required!");
            out.print(result.toString());
            return;
        }

        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Delivery address is required!");
            out.print(result.toString());
            return;
        }

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Phone number is required!");
            out.print(result.toString());
            return;
        }

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Payment method is required!");
            out.print(result.toString());
            return;
        }

        // ✅ Validate payment method
        if (!isValidPaymentMethod(paymentMethod)) {
            result.put("success", false);
            result.put("message", "Invalid payment method selected!");
            out.print(result.toString());
            return;
        }

        // ✅ Calculate total from session cart
        BigDecimal total = BigDecimal.ZERO;
        for (CartServlet.SerializableCartItem item : cart) {
            if (item.getPrice() != null) {
                total = total.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }

        System.out.println("Order total: " + total);

        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        PreparedStatement updateProductStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false);

            // ✅ Create order with ALL form data
            String orderSQL = "INSERT INTO orders (user_id, total_amount, status, delivery_address, phone_number, payment_method, created_at) VALUES (?, ?, 'PENDING', ?, ?, ?, NOW())";
            orderStmt = conn.prepareStatement(orderSQL, Statement.RETURN_GENERATED_KEYS);

            orderStmt.setInt(1, userId);
            orderStmt.setBigDecimal(2, total);
            orderStmt.setString(3, deliveryAddress.trim());
            orderStmt.setString(4, phoneNumber.trim());
            orderStmt.setString(5, paymentMethod);

            int rowsAffected = orderStmt.executeUpdate();
            System.out.println("Order inserted, rows affected: " + rowsAffected);

            ResultSet rs = orderStmt.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
                System.out.println("Generated Order ID: " + orderId);
            }

            // ✅ Add order items and update product quantities
            String itemSQL = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            itemStmt = conn.prepareStatement(itemSQL);

            String updateProductSQL = "UPDATE products SET quantity = quantity - ? WHERE id = ? AND quantity >= ?";
            updateProductStmt = conn.prepareStatement(updateProductSQL);

            for (CartServlet.SerializableCartItem item : cart) {
                // Add to order items
                itemStmt.setInt(1, orderId);
                itemStmt.setInt(2, item.getProductId());
                itemStmt.setInt(3, item.getQuantity());
                itemStmt.setBigDecimal(4, item.getPrice());
                itemStmt.addBatch();

                // Update product quantity
                updateProductStmt.setInt(1, item.getQuantity());
                updateProductStmt.setInt(2, item.getProductId());
                updateProductStmt.setInt(3, item.getQuantity());
                updateProductStmt.addBatch();

                System.out.println("Added order item: " + item.getName() + ", Qty: " + item.getQuantity());
            }

            int[] itemResults = itemStmt.executeBatch();
            int[] updateResults = updateProductStmt.executeBatch();
            System.out.println("Order items inserted: " + itemResults.length);
            System.out.println("Products updated: " + updateResults.length);

            conn.commit();

            // ✅ Send email receipt to the provided email
            boolean emailSent = sendReceiptEmail(firstName, lastName, email, orderId, total, cart, deliveryAddress, phoneNumber, paymentMethod);

            // ✅ Clear cart from session after successful checkout
            session.removeAttribute("cart");
            System.out.println("Cart cleared from session");

            // ✅ Clear cart from database for logged-in users
            clearUserCart(userId);

            result.put("success", true);
            result.put("message", "Order placed successfully! Order ID: #" + orderId);
            result.put("orderId", orderId);
            result.put("emailSent", emailSent);

            System.out.println("Checkout completed successfully for order: " + orderId);

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ignored) {
            }

            // Detailed SQL error handling
            if (e.getMessage().contains("delivery_address")) {
                result.put("success", false);
                result.put("message", "Database configuration error: delivery_address field issue.");
            } else if (e.getMessage().contains("phone_number")) {
                result.put("success", false);
                result.put("message", "Database configuration error: phone_number field issue.");
            } else if (e.getMessage().contains("payment_method")) {
                result.put("success", false);
                result.put("message", "Database configuration error: payment_method field issue.");
            } else {
                result.put("success", false);
                result.put("message", "Database error during checkout: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ignored) {
            }
            result.put("success", false);
            result.put("message", "Error processing order: " + e.getMessage());
        } finally {
            // Close resources
            try {
                if (orderStmt != null) {
                    orderStmt.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (itemStmt != null) {
                    itemStmt.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (updateProductStmt != null) {
                    updateProductStmt.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ignored) {
            }
        }

        out.print(result.toString());
        out.flush();
    }

    // ✅ Helper method to validate payment method
    private boolean isValidPaymentMethod(String paymentMethod) {
        return paymentMethod != null
                && (paymentMethod.equals("CASH")
                || paymentMethod.equals("MOBILE_MONEY")
                || paymentMethod.equals("BANK_TRANSFER"));
    }

    // ✅ Clear user cart from cart_items table
    private void clearUserCart(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            String sql = "DELETE FROM cart_items WHERE user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            int rows = ps.executeUpdate();
            System.out.println("Cart cleared from cart_items table for user: " + userId + ", rows affected: " + rows);
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException e) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
            }
        }
    }

    // ✅ EMAIL FUNCTION
    private boolean sendReceiptEmail(String firstName, String lastName, String email, int orderId, BigDecimal total,
            List<CartServlet.SerializableCartItem> cart, String deliveryAddress, String phoneNumber, String paymentMethod) {

        System.out.println("Attempting to send email to: " + email);

        try {
            // Setup mail server properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);

            // Create authenticator
            Authenticator auth = new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            };

            // Create session
            Session session = Session.getInstance(props, auth);
            session.setDebug(true);

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_USERNAME, "AgriYouth Marketplace"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("AgriYouth Marketplace - Order Confirmation #" + orderId);
            message.setSentDate(new java.util.Date());

            // Create email content
            String emailContent = buildReceiptContent(firstName, lastName, orderId, total, cart, deliveryAddress, phoneNumber, paymentMethod);

            // Set content as HTML
            message.setContent(emailContent, "text/html; charset=utf-8");

            System.out.println("Sending email...");

            // Send email
            Transport.send(message);

            System.out.println("✅ Email sent successfully to: " + email);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Failed to send email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private String buildReceiptContent(String firstName, String lastName, int orderId, BigDecimal total,
            List<CartServlet.SerializableCartItem> cart, String deliveryAddress, String phoneNumber, String paymentMethod) {

        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm a");
        String currentDate = dateFormat.format(new java.util.Date());

        StringBuilder itemsHtml = new StringBuilder();
        BigDecimal subtotal = BigDecimal.ZERO;

        // Build order items table
        for (CartServlet.SerializableCartItem item : cart) {
            if (item.getPrice() != null) {
                BigDecimal itemTotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                subtotal = subtotal.add(itemTotal);

                itemsHtml.append("<tr style='border-bottom: 1px solid #ddd;'>")
                        .append("<td style='padding: 12px;'>").append(item.getName()).append("</td>")
                        .append("<td style='padding: 12px; text-align: center;'>").append(item.getQuantity()).append("</td>")
                        .append("<td style='padding: 12px; text-align: right;'>M ").append(item.getPrice()).append("</td>")
                        .append("<td style='padding: 12px; text-align: right;'>M ").append(itemTotal).append("</td>")
                        .append("</tr>");
            }
        }

        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f4; }"
                + ".container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 0 10px rgba(0,0,0,0.1); }"
                + ".header { background: #28a745; color: white; padding: 30px; text-align: center; }"
                + ".content { padding: 30px; }"
                + ".section { margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid #eee; }"
                + ".section:last-child { border-bottom: none; }"
                + ".total { font-size: 18px; font-weight: bold; color: #28a745; }"
                + "table { width: 100%; border-collapse: collapse; margin: 20px 0; background: #f9f9f9; border-radius: 5px; overflow: hidden; }"
                + "th { background: #28a745; color: white; padding: 12px; text-align: left; }"
                + "td { padding: 12px; border-bottom: 1px solid #ddd; }"
                + ".info-box { background: #e7f3ff; padding: 15px; border-radius: 5px; border-left: 4px solid #007bff; margin: 15px 0; }"
                + ".footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1 style='margin: 0; font-size: 28px;'>🌱 AgriYouth Marketplace</h1>"
                + "<h2 style='margin: 10px 0 0 0; font-weight: 300;'>Order Confirmation</h2>"
                + "</div>"
                + "<div class='content'>"
                + "<div class='section'>"
                + "<p>Dear <strong>" + firstName + " " + lastName + "</strong>,</p>"
                + "<p>Thank you for your purchase! Your order has been received and is being processed.</p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>📦 Order Details</h3>"
                + "<p><strong>Order ID:</strong> #" + orderId + "</p>"
                + "<p><strong>Order Date:</strong> " + currentDate + "</p>"
                + "<p><strong>Status:</strong> <span style='color: #ffc107; font-weight: bold;'>PENDING</span></p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>📍 Delivery Information</h3>"
                + "<p><strong>Delivery Address:</strong><br>" + deliveryAddress.replace("\n", "<br>") + "</p>"
                + "<p><strong>Phone Number:</strong> " + phoneNumber + "</p>"
                + "<p><strong>Payment Method:</strong> " + paymentMethod + "</p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>🛒 Order Items</h3>"
                + "<table>"
                + "<thead>"
                + "<tr>"
                + "<th>Product</th>"
                + "<th style='text-align: center;'>Qty</th>"
                + "<th style='text-align: right;'>Price</th>"
                + "<th style='text-align: right;'>Total</th>"
                + "</tr>"
                + "</thead>"
                + "<tbody>"
                + itemsHtml.toString()
                + "</tbody>"
                + "</table>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>💰 Order Summary</h3>"
                + "<p><strong>Subtotal:</strong> M " + subtotal + "</p>"
                + "<p><strong>Total Amount:</strong> <span class='total'>M " + total + "</span></p>"
                + "</div>"
                + "<div class='info-box'>"
                + "<p style='margin: 0;'><strong>📞 Need Help?</strong><br>"
                + "If you have any questions about your order, please contact our support team at support@agriyouth.ls or call +266 1234 5678.</p>"
                + "</div>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>Thank you for shopping with AgriYouth Marketplace!<br>"
                + "We'll notify you when your order is confirmed and ready for delivery.</p>"
                + "<p style='margin-top: 20px; color: #999;'>© 2025 AgriYouth Marketplace. All rights reserved.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
    }
}