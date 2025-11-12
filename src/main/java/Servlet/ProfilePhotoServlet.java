package Servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ProfilePhotoServlet")
public class ProfilePhotoServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/agri_business";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing user ID");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
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

            String sql = "SELECT profile_picture FROM users WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                imageStream = rs.getBinaryStream("profile_picture");
                if (imageStream != null) {
                    response.setContentType(getServletContext().getMimeType("image.jpg"));
                    response.setHeader("Cache-Control", "public, max-age=86400");

                    out = response.getOutputStream();
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = imageStream.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                } else {
                    sendDefaultAvatar(response, request, userId);
                }
            } else {
                sendDefaultAvatar(response, request, userId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            sendDefaultAvatar(response, request, userId);
        } finally {
            closeQuietly(imageStream, rs, ps, conn);
            if (out != null) try { out.close(); } catch (IOException ignored) {}
        }
    }

    private void sendDefaultAvatar(HttpServletResponse response, HttpServletRequest request, int userId) throws IOException {
        // Try to get user name for avatar generation
        String userName = "User";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            String sql = "SELECT first_name, last_name FROM users WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                if (firstName != null && lastName != null) {
                    userName = firstName + " " + lastName;
                }
            }
        } catch (Exception e) {
            // Use default name if we can't get user info
        } finally {
            closeQuietly(rs, ps, conn);
        }

        // Redirect to UI Avatars API for a nice default avatar
        String avatarUrl = "https://ui-avatars.com/api/?name=" + 
                          java.net.URLEncoder.encode(userName, "UTF-8") + 
                          "&size=200&background=28a745&color=ffffff&bold=true";
        
        response.sendRedirect(avatarUrl);
    }

    private void closeQuietly(AutoCloseable... closeables) {
        for (AutoCloseable c : closeables) {
            if (c != null) {
                try { c.close(); } catch (Exception ignored) {}
            }
        }
    }
}