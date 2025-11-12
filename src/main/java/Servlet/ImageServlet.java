package Servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ImageServlet")
public class ImageServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/agri_business";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        
        System.out.println("ImageServlet called with ID: " + idStr);

        // Handle undefined or invalid IDs gracefully
        if (idStr == null || idStr.trim().isEmpty() || "undefined".equals(idStr)) {
            System.out.println("Invalid product ID received: " + idStr);
            sendPlaceholderImage(response, "No ID");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            System.out.println("Invalid product ID format: " + idStr);
            sendPlaceholderImage(response, "Invalid ID");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        InputStream imageStream = null;
        OutputStream out = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT image, name FROM products WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();

            if (rs.next()) {
                imageStream = rs.getBinaryStream("image");
                String productName = rs.getString("name");
                
                if (imageStream != null) {
                    // Set proper content type
                    response.setContentType("image/jpeg");
                    response.setHeader("Cache-Control", "public, max-age=86400");
                    
                    out = response.getOutputStream();
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = imageStream.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                    System.out.println("✅ Successfully served image for product: " + productName + " (ID: " + productId + ")");
                } else {
                    System.out.println("❌ No image data for product: " + productName + " (ID: " + productId + ")");
                    sendPlaceholderImage(response, "No Image");
                }
            } else {
                System.out.println("❌ Product not found in database: " + productId);
                sendPlaceholderImage(response, "Not Found");
            }

        } catch (Exception e) {
            System.out.println("❌ Error serving image for product: " + productId + " - " + e.getMessage());
            e.printStackTrace();
            sendPlaceholderImage(response, "Error");
        } finally {
            closeQuietly(imageStream, rs, ps, conn);
            if (out != null) try { out.close(); } catch (IOException ignored) {}
        }
    }

    private void sendPlaceholderImage(HttpServletResponse response, String reason) throws IOException {
        System.out.println("🔄 Serving placeholder image. Reason: " + reason);
        
        response.setContentType("image/svg+xml");
        
        // Fixed: Use String.format instead of .formatted() for Java 8+ compatibility
        String svg = String.format(
            "<svg width=\"200\" height=\"200\" xmlns=\"http://www.w3.org/2000/svg\">" +
            "<rect width=\"100%%\" height=\"100%%\" fill=\"#f8f9fa\"/>" +
            "<circle cx=\"100\" cy=\"80\" r=\"30\" fill=\"#e9ecef\"/>" +
            "<path d=\"M70 120 L130 120 L130 160 L70 160 Z\" fill=\"#e9ecef\"/>" +
            "<text x=\"100\" y=\"190\" font-family=\"Arial\" font-size=\"14\" fill=\"#6c757d\" text-anchor=\"middle\">%s</text>" +
            "<text x=\"100\" y=\"210\" font-family=\"Arial\" font-size=\"12\" fill=\"#adb5bd\" text-anchor=\"middle\">No Image</text>" +
            "</svg>", 
            reason
        );
        
        response.getWriter().write(svg);
    }

    private void closeQuietly(AutoCloseable... closeables) {
        for (AutoCloseable c : closeables) {
            if (c != null) {
                try { c.close(); } catch (Exception ignored) {}
            }
        }
    }
}