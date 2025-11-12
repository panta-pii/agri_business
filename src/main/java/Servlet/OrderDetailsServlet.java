package Servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/OrderDetailsServlet")
public class OrderDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            out.println("<div class='alert alert-danger'>Order ID is required</div>");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");
            
            // Get order details
            String orderSql = "SELECT * FROM orders WHERE id = ?";
            pstmt = conn.prepareStatement(orderSql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                out.println("<div class='alert alert-danger'>Order not found</div>");
                return;
            }
            
            // Order header
            out.println("<div class='row mb-4'>");
            out.println("<div class='col-md-6'>");
            out.println("<h6 class='text-muted'>Order Information</h6>");
            out.println("<p><strong>Order Date:</strong> " + rs.getTimestamp("created_at") + "</p>");
            out.println("<p><strong>Status:</strong> <span class='badge status-" + rs.getString("status") + "'>" + rs.getString("status") + "</span></p>");
            out.println("<p><strong>Payment Method:</strong> " + rs.getString("payment_method") + "</p>");
            out.println("</div>");
            out.println("<div class='col-md-6'>");
            out.println("<h6 class='text-muted'>Delivery Information</h6>");
            out.println("<p><strong>Address:</strong> " + rs.getString("delivery_address") + "</p>");
            out.println("<p><strong>Phone:</strong> " + rs.getString("phone_number") + "</p>");
            out.println("<p><strong>Total Amount:</strong> M " + String.format("%.2f", rs.getDouble("total_amount")) + "</p>");
            out.println("</div>");
            out.println("</div>");
            
            rs.close();
            pstmt.close();
            
            // Get order items
            String itemsSql = "SELECT oi.*, p.name as product_name, p.image " +
                            "FROM order_items oi " +
                            "LEFT JOIN products p ON oi.product_id = p.id " +
                            "WHERE oi.order_id = ?";
            pstmt = conn.prepareStatement(itemsSql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            rs = pstmt.executeQuery();
            
            out.println("<h6 class='text-muted mb-3'>Order Items</h6>");
            out.println("<div class='table-responsive'>");
            out.println("<table class='table table-bordered'>");
            out.println("<thead class='table-light'>");
            out.println("<tr><th>Product</th><th>Quantity</th><th>Price</th><th>Subtotal</th></tr>");
            out.println("</thead>");
            out.println("<tbody>");
            
            double total = 0;
            while (rs.next()) {
                double price = rs.getDouble("price");
                int quantity = rs.getInt("quantity");
                double subtotal = price * quantity;
                total += subtotal;
                
                out.println("<tr>");
                out.println("<td>");
                out.println("<div class='d-flex align-items-center'>");
                // Display product image if available
                byte[] imageBytes = rs.getBytes("image");
                if (imageBytes != null && imageBytes.length > 0) {
                    String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);
                    out.println("<img src='data:image/jpeg;base64," + base64Image + "' class='rounded me-3' width='50' height='50' alt='Product'>");
                }
                out.println("<div>");
                out.println("<strong>" + rs.getString("product_name") + "</strong>");
                out.println("</div>");
                out.println("</div>");
                out.println("</td>");
                out.println("<td>" + quantity + "</td>");
                out.println("<td>M " + String.format("%.2f", price) + "</td>");
                out.println("<td>M " + String.format("%.2f", subtotal) + "</td>");
                out.println("</tr>");
            }
            
            out.println("</tbody>");
            out.println("<tfoot class='table-light'>");
            out.println("<tr><td colspan='3' class='text-end'><strong>Total:</strong></td><td><strong>M " + String.format("%.2f", total) + "</strong></td></tr>");
            out.println("</tfoot>");
            out.println("</table>");
            out.println("</div>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class='alert alert-danger'>Error loading order details: " + e.getMessage() + "</div>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}