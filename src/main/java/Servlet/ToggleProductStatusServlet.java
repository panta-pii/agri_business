package Servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import org.json.JSONObject;

@WebServlet("/ToggleProductStatusServlet")
public class ToggleProductStatusServlet extends HttpServlet {

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

        int productId = Integer.parseInt(request.getParameter("productId"));
        boolean newStatus = Boolean.parseBoolean(request.getParameter("newStatus"));

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

            String sql = "UPDATE products SET is_available = ? WHERE id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, newStatus);
            pstmt.setInt(2, productId);
            pstmt.setInt(3, farmerId);

            int rowsUpdated = pstmt.executeUpdate();
            
            if (rowsUpdated > 0) {
                json.put("success", true).put("message", "Product status updated successfully");
            } else {
                json.put("success", false).put("message", "Product not found or you don't have permission");
            }

        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false).put("message", "Error updating product status: " + e.getMessage());
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        out.print(json.toString());
    }
}