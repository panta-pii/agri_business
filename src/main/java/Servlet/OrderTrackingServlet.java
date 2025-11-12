package Servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import java.util.Date;

@WebServlet("/OrderTrackingServlet")
public class OrderTrackingServlet extends HttpServlet {
    
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
            
            String sql = "SELECT status, created_at FROM orders WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                out.println("<div class='alert alert-danger'>Order not found</div>");
                return;
            }
            
            String status = rs.getString("status");
            Date orderDate = rs.getDate("created_at");
            
            out.println("<div class='tracking-container'>");
            out.println("<div class='tracking-progress mb-4'>");
            out.println("<div class='tracking-progress-bar' style='width: " + getProgressWidth(status) + "%'></div>");
            out.println("</div>");
            
            out.println("<div class='row text-center'>");
            
            // PENDING Step
            out.println("<div class='col'>");
            out.println("<div class='" + (status.equals("PENDING") ? "text-warning" : "text-success") + "'>");
            out.println("<i class='fas fa-shopping-cart fa-2x mb-2'></i>");
            out.println("<p class='mb-1'><strong>Order Placed</strong></p>");
            out.println("<small>" + orderDate + "</small>");
            out.println("</div>");
            out.println("</div>");
            
            // PAID Step
            out.println("<div class='col'>");
            out.println("<div class='" + (status.equals("PAID") ? "text-warning" : 
                          status.equals("DELIVERED") ? "text-success" : "text-muted") + "'>");
            out.println("<i class='fas fa-credit-card fa-2x mb-2'></i>");
            out.println("<p class='mb-1'><strong>Payment</strong></p>");
            out.println("<small>" + (status.equals("PENDING") ? "Pending" : "Completed") + "</small>");
            out.println("</div>");
            out.println("</div>");
            
            // DELIVERED Step
            out.println("<div class='col'>");
            out.println("<div class='" + (status.equals("DELIVERED") ? "text-success" : "text-muted") + "'>");
            out.println("<i class='fas fa-truck fa-2x mb-2'></i>");
            out.println("<p class='mb-1'><strong>Delivery</strong></p>");
            out.println("<small>" + (status.equals("DELIVERED") ? "Delivered" : "In Progress") + "</small>");
            out.println("</div>");
            out.println("</div>");
            
            out.println("</div>"); // Close row
            
            // Current status message
            out.println("<div class='alert alert-info mt-4'>");
            out.println("<h6>Current Status: <span class='badge status-" + status + "'>" + status + "</span></h6>");
            out.println("<p class='mb-0'>" + getStatusMessage(status) + "</p>");
            out.println("</div>");
            
            out.println("</div>"); // Close container
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class='alert alert-danger'>Error loading tracking information</div>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
    
    private int getProgressWidth(String status) {
        switch (status) {
            case "PENDING": return 33;
            case "PAID": return 66;
            case "DELIVERED": return 100;
            default: return 0;
        }
    }
    
    private String getStatusMessage(String status) {
        switch (status) {
            case "PENDING": return "Your order has been received and is being processed. Please complete your payment.";
            case "PAID": return "Payment received! Your order is being prepared for delivery.";
            case "DELIVERED": return "Your order has been successfully delivered. Thank you for shopping with us!";
            default: return "Tracking information not available.";
        }
    }
}