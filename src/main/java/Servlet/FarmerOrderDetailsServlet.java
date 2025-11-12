package Servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;

@WebServlet("/FarmerOrderDetailsServlet")
public class FarmerOrderDetailsServlet extends HttpServlet {
    
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
            
            // Get order details with farmer verification
            String orderSql = "SELECT o.*, u.first_name as customer_name, u.email as customer_email, " +
                            "p.name as product_name, p.description as product_description, " +
                            "oi.quantity, oi.price " +
                            "FROM orders o " +
                            "JOIN order_items oi ON o.id = oi.order_id " +
                            "JOIN products p ON oi.product_id = p.id " +
                            "JOIN users u ON o.user_id = u.id " +
                            "WHERE o.id = ? AND p.user_id = ?";
            
            HttpSession session = request.getSession(false);
            Integer farmerId = (session != null) ? (Integer) session.getAttribute("userId") : null;
            
            pstmt = conn.prepareStatement(orderSql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            pstmt.setInt(2, farmerId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                out.println("<div class='alert alert-danger'>Order not found or you don't have permission to view this order</div>");
                return;
            }
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
            
            // Order header
            out.println("<div class='row mb-4'>");
            out.println("<div class='col-md-6'>");
            out.println("<h6 class='text-muted'>Order Information</h6>");
            out.println("<p><strong>Order Date:</strong> " + dateFormat.format(rs.getTimestamp("created_at")) + "</p>");
            out.println("<p><strong>Status:</strong> <span class='badge status-" + rs.getString("status") + "'>" + rs.getString("status") + "</span></p>");
            out.println("<p><strong>Payment Method:</strong> " + rs.getString("payment_method") + "</p>");
            out.println("</div>");
            out.println("<div class='col-md-6'>");
            out.println("<h6 class='text-muted'>Customer Information</h6>");
            out.println("<p><strong>Name:</strong> " + rs.getString("customer_name") + "</p>");
            out.println("<p><strong>Email:</strong> " + rs.getString("customer_email") + "</p>");
            out.println("<p><strong>Phone:</strong> " + (rs.getString("phone_number") != null ? rs.getString("phone_number") : "Not provided") + "</p>");
            out.println("<p><strong>Delivery Address:</strong> " + rs.getString("delivery_address") + "</p>");
            out.println("</div>");
            out.println("</div>");
            
            // Product details
            out.println("<h6 class='text-muted mb-3'>Product Details</h6>");
            out.println("<div class='card'>");
            out.println("<div class='card-body'>");
            out.println("<h5>" + rs.getString("product_name") + "</h5>");
            out.println("<p class='text-muted'>" + (rs.getString("product_description") != null ? rs.getString("product_description") : "No description available") + "</p>");
            out.println("<div class='row'>");
            out.println("<div class='col-md-4'><strong>Quantity:</strong> " + rs.getInt("quantity") + "</div>");
            out.println("<div class='col-md-4'><strong>Unit Price:</strong> M " + String.format("%.2f", rs.getDouble("price")) + "</div>");
            out.println("<div class='col-md-4'><strong>Subtotal:</strong> M " + String.format("%.2f", rs.getDouble("price") * rs.getInt("quantity")) + "</div>");
            out.println("</div>");
            out.println("</div>");
            out.println("</div>");
            
            // Order summary
            out.println("<div class='card mt-3'>");
            out.println("<div class='card-body'>");
            out.println("<h6 class='text-muted'>Order Summary</h6>");
            out.println("<div class='d-flex justify-content-between'>");
            out.println("<span>Subtotal:</span>");
            out.println("<span>M " + String.format("%.2f", rs.getDouble("price") * rs.getInt("quantity")) + "</span>");
            out.println("</div>");
            out.println("<div class='d-flex justify-content-between'>");
            out.println("<span>Delivery:</span>");
            out.println("<span>M 0.00</span>");
            out.println("</div>");
            out.println("<hr>");
            out.println("<div class='d-flex justify-content-between fw-bold'>");
            out.println("<span>Total Amount:</span>");
            out.println("<span>M " + String.format("%.2f", rs.getDouble("total_amount")) + "</span>");
            out.println("</div>");
            out.println("</div>");
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