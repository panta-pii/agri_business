package Servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import org.json.JSONObject;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.text.SimpleDateFormat;

@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    // Email configuration - Same as other servlets
    private final String SMTP_HOST = "smtp.gmail.com";
    private final String SMTP_PORT = "587";
    private final String EMAIL_USERNAME = "panta.pii@bothouniversity.com";
    private final String EMAIL_PASSWORD = "kfsg kbat qjtb nkda";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();

        HttpSession session = request.getSession(false);
        Integer farmerId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (farmerId == null) {
            json.put("success", false).put("message", "Please login first");
            out.print(json.toString());
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            json.put("success", false).put("message", "Order ID is required");
            out.print(json.toString());
            return;
        }

        if (newStatus == null || newStatus.trim().isEmpty()) {
            json.put("success", false).put("message", "New status is required");
            out.print(json.toString());
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement selectStmt = null;
        ResultSet rs = null;

        try {
            int orderId = Integer.parseInt(orderIdParam);
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

            // First, get order details and customer email for notification
            String selectSql = "SELECT o.id, o.user_id, o.total_amount, o.status, o.delivery_address, " +
                             "u.email, u.first_name, u.last_name, " +
                             "GROUP_CONCAT(p.name SEPARATOR ', ') as products " +
                             "FROM orders o " +
                             "JOIN users u ON o.user_id = u.id " +
                             "JOIN order_items oi ON o.id = oi.order_id " +
                             "JOIN products p ON oi.product_id = p.id " +
                             "WHERE o.id = ? AND p.user_id = ? " +
                             "GROUP BY o.id";

            selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, orderId);
            selectStmt.setInt(2, farmerId);
            rs = selectStmt.executeQuery();

            if (rs.next()) {
                String customerEmail = rs.getString("email");
                String customerName = rs.getString("first_name") + " " + rs.getString("last_name");
                double totalAmount = rs.getDouble("total_amount");
                String products = rs.getString("products");
                String deliveryAddress = rs.getString("delivery_address");
                String oldStatus = rs.getString("status");

                // Update status only if the farmer owns the product in this order
                String updateSql = "UPDATE orders o " +
                                "JOIN order_items oi ON o.id = oi.order_id " +
                                "JOIN products p ON oi.product_id = p.id " +
                                "SET o.status = ? " +
                                "WHERE o.id = ? AND p.user_id = ?";

                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newStatus);
                pstmt.setInt(2, orderId);
                pstmt.setInt(3, farmerId);

                int rowsUpdated = pstmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // ✅ Send status update email to customer
                    boolean emailSent = sendStatusUpdateEmail(customerName, customerEmail, orderId, 
                            oldStatus, newStatus, totalAmount, products, deliveryAddress);
                    
                    json.put("success", true)
                        .put("message", "Order status updated successfully" + 
                             (emailSent ? " and customer notified via email." : " but email notification failed."));
                    
                    System.out.println("✅ Order status updated: Order #" + orderId + " from " + oldStatus + " to " + newStatus);
                } else {
                    json.put("success", false).put("message", "Order not found or you don't have permission to update this order");
                }
            } else {
                json.put("success", false).put("message", "Order not found or you don't have permission to update this order");
            }

        } catch (NumberFormatException e) {
            json.put("success", false).put("message", "Invalid order ID format");
        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false).put("message", "Error updating order status: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (selectStmt != null) selectStmt.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        out.print(json.toString());
    }

    // ✅ EMAIL FUNCTION - Order Status Update Notification
    private boolean sendStatusUpdateEmail(String customerName, String customerEmail, int orderId, 
            String oldStatus, String newStatus, double totalAmount, String products, String deliveryAddress) {
        
        System.out.println("Attempting to send status update email to: " + customerEmail);

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
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(customerEmail));
            message.setSubject("📦 Order #" + orderId + " Status Updated - AgriYouth Marketplace");
            message.setSentDate(new java.util.Date());

            // Create email content
            String emailContent = buildStatusUpdateEmailContent(customerName, orderId, oldStatus, newStatus, totalAmount, products, deliveryAddress);

            // Set content as HTML
            message.setContent(emailContent, "text/html; charset=utf-8");

            System.out.println("Sending status update email...");

            // Send email
            Transport.send(message);

            System.out.println("✅ Status update email sent successfully to: " + customerEmail);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Failed to send status update email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private String buildStatusUpdateEmailContent(String customerName, int orderId, String oldStatus, 
            String newStatus, double totalAmount, String products, String deliveryAddress) {
        
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm a");
        String currentDate = dateFormat.format(new java.util.Date());

        String statusColor = "#28a745"; // Default green
        String statusIcon = "✅";
        
        if ("CANCELLED".equalsIgnoreCase(newStatus)) {
            statusColor = "#dc3545";
            statusIcon = "❌";
        } else if ("PENDING".equalsIgnoreCase(newStatus)) {
            statusColor = "#ffc107";
            statusIcon = "⏳";
        } else if ("DELIVERED".equalsIgnoreCase(newStatus)) {
            statusColor = "#17a2b8";
            statusIcon = "🚚";
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
                + ".status-badge { display: inline-block; padding: 8px 16px; background: " + statusColor + "; color: white; border-radius: 20px; font-weight: bold; }"
                + ".info-box { background: #e7f3ff; padding: 15px; border-radius: 5px; border-left: 4px solid #007bff; margin: 15px 0; }"
                + ".footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1 style='margin: 0; font-size: 28px;'>🌱 AgriYouth Marketplace</h1>"
                + "<h2 style='margin: 10px 0 0 0; font-weight: 300;'>Order Status Update</h2>"
                + "</div>"
                + "<div class='content'>"
                + "<div class='section'>"
                + "<p>Dear <strong>" + customerName + "</strong>,</p>"
                + "<p>Your order status has been updated. Here are the latest details:</p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>📦 Order Details</h3>"
                + "<p><strong>Order ID:</strong> #" + orderId + "</p>"
                + "<p><strong>Products:</strong> " + products + "</p>"
                + "<p><strong>Total Amount:</strong> M " + String.format("%.2f", totalAmount) + "</p>"
                + "<p><strong>Delivery Address:</strong><br>" + (deliveryAddress != null ? deliveryAddress.replace("\n", "<br>") : "Not specified") + "</p>"
                + "</div>"
                + "<div class='section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>🔄 Status Update</h3>"
                + "<p><strong>Previous Status:</strong> " + oldStatus + "</p>"
                + "<p><strong>New Status:</strong> <span class='status-badge'>" + statusIcon + " " + newStatus + "</span></p>"
                + "<p><strong>Updated On:</strong> " + currentDate + "</p>"
                + "</div>"
                + "<div class='info-box'>"
                + "<p style='margin: 0;'><strong>📞 Need Help?</strong><br>"
                + "If you have any questions about this status update, please contact our support team at <strong>support@agriyouth.ls</strong> or call us at <strong>+266 1234 5678</strong>.</p>"
                + "</div>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>Thank you for shopping with AgriYouth Marketplace!<br>"
                + "We appreciate your business and are here to help if you need anything.</p>"
                + "<p style='margin-top: 20px; color: #999;'>© 2025 AgriYouth Marketplace. All rights reserved.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
    }
}