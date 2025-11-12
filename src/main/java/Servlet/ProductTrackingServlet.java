package Servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/ProductTrackingServlet")
public class ProductTrackingServlet extends HttpServlet {
    
    private static final String CSV_FILE_PATH = "/tmp/product_tracking.csv";
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String productId = request.getParameter("productId");
        String searchQuery = request.getParameter("searchQuery");
        String category = request.getParameter("category");
        
        HttpSession session = request.getSession();
        String sessionId = session.getId();
        
        // FIX: Handle userId properly - it might be Integer or String
        Object userIdObj = session.getAttribute("userId");
        String userId;
        if (userIdObj instanceof Integer) {
            userId = String.valueOf(userIdObj);
        } else if (userIdObj instanceof String) {
            userId = (String) userIdObj;
        } else {
            userId = "guest";
        }
        
        try {
            switch (action) {
                case "product_click":
                    logProductClick(productId, sessionId, userId);
                    break;
                case "search":
                    logSearch(searchQuery, sessionId, userId);
                    break;
                case "add_to_cart":
                    logAddToCart(productId, sessionId, userId);
                    break;
                case "category_view":
                    logCategoryView(category, sessionId, userId);
                    break;
                case "page_view":
                    logPageView(sessionId, userId);
                    break;
            }
            
            response.getWriter().write("{\"success\": true}");
        } catch (Exception e) {
            response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void logProductClick(String productId, String sessionId, String userId) throws IOException {
        String timestamp = LocalDateTime.now().format(formatter);
        String record = String.format("%s,%s,%s,product_click,%s,,%s\n", 
            timestamp, sessionId, userId, productId, "1");
        writeToCSV(record);
    }
    
    private void logSearch(String searchQuery, String sessionId, String userId) throws IOException {
        String timestamp = LocalDateTime.now().format(formatter);
        String record = String.format("%s,%s,%s,search,,%s,%s\n", 
            timestamp, sessionId, userId, searchQuery, "1");
        writeToCSV(record);
    }
    
    private void logAddToCart(String productId, String sessionId, String userId) throws IOException {
        String timestamp = LocalDateTime.now().format(formatter);
        String record = String.format("%s,%s,%s,add_to_cart,%s,,%s\n", 
            timestamp, sessionId, userId, productId, "1");
        writeToCSV(record);
    }
    
    private void logCategoryView(String category, String sessionId, String userId) throws IOException {
        String timestamp = LocalDateTime.now().format(formatter);
        String record = String.format("%s,%s,%s,category_view,,%s,%s\n", 
            timestamp, sessionId, userId, category, "1");
        writeToCSV(record);
    }
    
    private void logPageView(String sessionId, String userId) throws IOException {
        String timestamp = LocalDateTime.now().format(formatter);
        String record = String.format("%s,%s,%s,page_view,,,,%s\n", 
            timestamp, sessionId, userId, "1");
        writeToCSV(record);
    }
    
    private synchronized void writeToCSV(String record) throws IOException {
        File file = new File(CSV_FILE_PATH);
        
        // Create file and write header if it doesn't exist
        if (!file.exists()) {
            file.getParentFile().mkdirs();
            String header = "timestamp,session_id,user_id,action_type,product_id,search_query,category,click_count\n";
            try (FileWriter writer = new FileWriter(file, true)) {
                writer.write(header);
            }
        }
        
        // Append the record
        try (FileWriter writer = new FileWriter(file, true)) {
            writer.write(record);
        }
    }
}