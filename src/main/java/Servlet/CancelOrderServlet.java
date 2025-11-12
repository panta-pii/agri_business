package Servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Order ID is required");
            out.print(jsonResponse.toString());
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

            // Check if order can be cancelled (only PENDING orders can be cancelled)
            String checkSql = "SELECT status FROM orders WHERE id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            ResultSet rs = pstmt.executeQuery();

            if (!rs.next()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Order not found");
                out.print(jsonResponse.toString());
                return;
            }

            String currentStatus = rs.getString("status");
            if (!"PENDING".equals(currentStatus)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Only PENDING orders can be cancelled. Current status: " + currentStatus);
                out.print(jsonResponse.toString());
                return;
            }

            rs.close();
            pstmt.close();

            // Delete order items first
            String deleteItemsSql = "DELETE FROM order_items WHERE order_id = ?";
            pstmt = conn.prepareStatement(deleteItemsSql);
            pstmt.setInt(1, Integer.parseInt(orderId));
            pstmt.executeUpdate();

            pstmt.close();

            // Delete the order
            String deleteOrderSql = "DELETE FROM orders WHERE id = ?";
            pstmt = conn.prepareStatement(deleteOrderSql);
            pstmt.setInt(1, Integer.parseInt(orderId));

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Order cancelled successfully");
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Failed to cancel order");
            }

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error cancelling order: " + e.getMessage());
        } finally {
            try {
                if (pstmt != null) {
                    pstmt.close();
                }
            } catch (Exception e) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }

        out.print(jsonResponse.toString());
    }
}
