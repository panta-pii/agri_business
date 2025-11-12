package Servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.*;

@WebServlet("/AnalyticsServlet")
public class AnalyticsServlet extends HttpServlet {
    
    private static final String CSV_FILE_PATH = "/tmp/product_tracking.csv";
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (action) {
                case "popular_products":
                    getPopularProducts(response);
                    break;
                case "search_analytics":
                    getSearchAnalytics(response);
                    break;
                case "demand_metrics":
                    getDemandMetrics(response);
                    break;
                default:
                    response.getWriter().write("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void getPopularProducts(HttpServletResponse response) throws IOException {
        List<String> lines = readCSVFile();
        Map<String, Integer> productClicks = new HashMap<>();
        Map<String, Integer> productCartAdds = new HashMap<>();
        
        for (String line : lines) {
            if (line.startsWith("timestamp")) continue; // Skip header
            
            String[] parts = line.split(",");
            if (parts.length >= 5) {
                String actionType = parts[3];
                String productId = parts[4];
                
                if ("product_click".equals(actionType) && !productId.isEmpty()) {
                    productClicks.put(productId, productClicks.getOrDefault(productId, 0) + 1);
                } else if ("add_to_cart".equals(actionType) && !productId.isEmpty()) {
                    productCartAdds.put(productId, productCartAdds.getOrDefault(productId, 0) + 1);
                }
            }
        }
        
        // Create JSON response
        StringBuilder json = new StringBuilder("{\"popular_products\": [");
        List<Map.Entry<String, Integer>> sortedProducts = productClicks.entrySet()
                .stream()
                .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
                .limit(10)
                .collect(Collectors.toList());
        
        for (int i = 0; i < sortedProducts.size(); i++) {
            Map.Entry<String, Integer> entry = sortedProducts.get(i);
            String productId = entry.getKey();
            int clicks = entry.getValue();
            int cartAdds = productCartAdds.getOrDefault(productId, 0);
            
            json.append(String.format(
                "{\"product_id\": \"%s\", \"clicks\": %d, \"cart_adds\": %d, \"conversion_rate\": %.2f}",
                productId, clicks, cartAdds, (cartAdds * 100.0 / clicks)
            ));
            
            if (i < sortedProducts.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        
        response.getWriter().write(json.toString());
    }
    
    private void getSearchAnalytics(HttpServletResponse response) throws IOException {
        List<String> lines = readCSVFile();
        Map<String, Integer> searchCounts = new HashMap<>();
        
        for (String line : lines) {
            if (line.startsWith("timestamp")) continue;
            
            String[] parts = line.split(",");
            if (parts.length >= 6 && "search".equals(parts[3])) {
                String searchQuery = parts[5];
                if (!searchQuery.isEmpty()) {
                    searchCounts.put(searchQuery, searchCounts.getOrDefault(searchQuery, 0) + 1);
                }
            }
        }
        
        StringBuilder json = new StringBuilder("{\"search_analytics\": [");
        List<Map.Entry<String, Integer>> sortedSearches = searchCounts.entrySet()
                .stream()
                .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
                .limit(15)
                .collect(Collectors.toList());
        
        for (int i = 0; i < sortedSearches.size(); i++) {
            Map.Entry<String, Integer> entry = sortedSearches.get(i);
            json.append(String.format("{\"query\": \"%s\", \"count\": %d}", 
                entry.getKey(), entry.getValue()));
            
            if (i < sortedSearches.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        
        response.getWriter().write(json.toString());
    }
    
    private void getDemandMetrics(HttpServletResponse response) throws IOException {
        List<String> lines = readCSVFile();
        Map<String, Integer> categoryClicks = new HashMap<>();
        Map<String, Integer> categorySearches = new HashMap<>();
        
        for (String line : lines) {
            if (line.startsWith("timestamp")) continue;
            
            String[] parts = line.split(",");
            if (parts.length >= 7) {
                String actionType = parts[3];
                String category = parts[6];
                
                if (!category.isEmpty()) {
                    if ("product_click".equals(actionType) || "category_view".equals(actionType)) {
                        categoryClicks.put(category, categoryClicks.getOrDefault(category, 0) + 1);
                    } else if ("search".equals(actionType)) {
                        categorySearches.put(category, categorySearches.getOrDefault(category, 0) + 1);
                    }
                }
            }
        }
        
        StringBuilder json = new StringBuilder("{\"demand_metrics\": [");
        List<String> allCategories = new ArrayList<>();
        allCategories.addAll(categoryClicks.keySet());
        allCategories.addAll(categorySearches.keySet());
        
        Set<String> uniqueCategories = new HashSet<>(allCategories);
        List<Map<String, Object>> categoryData = new ArrayList<>();
        
        for (String category : uniqueCategories) {
            int clicks = categoryClicks.getOrDefault(category, 0);
            int searches = categorySearches.getOrDefault(category, 0);
            int demandScore = (clicks * 2) + searches; // Weight clicks higher
            
            Map<String, Object> data = new HashMap<>();
            data.put("category", category);
            data.put("clicks", clicks);
            data.put("searches", searches);
            data.put("demand_score", demandScore);
            data.put("demand_level", getDemandLevel(demandScore));
            categoryData.add(data);
        }
        
        // Sort by demand score
        categoryData.sort((a, b) -> Integer.compare(
            (Integer)b.get("demand_score"), 
            (Integer)a.get("demand_score")
        ));
        
        for (int i = 0; i < categoryData.size(); i++) {
            Map<String, Object> data = categoryData.get(i);
            json.append(String.format(
                "{\"category\": \"%s\", \"clicks\": %d, \"searches\": %d, \"demand_score\": %d, \"demand_level\": \"%s\"}",
                data.get("category"), data.get("clicks"), data.get("searches"), 
                data.get("demand_score"), data.get("demand_level")
            ));
            
            if (i < categoryData.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        
        response.getWriter().write(json.toString());
    }
    
    private String getDemandLevel(int score) {
        if (score >= 100) return "VERY_HIGH";
        if (score >= 50) return "HIGH";
        if (score >= 20) return "MEDIUM";
        return "LOW";
    }
    
    private List<String> readCSVFile() throws IOException {
        Path path = Paths.get(CSV_FILE_PATH);
        if (!Files.exists(path)) {
            return new ArrayList<>();
        }
        return Files.readAllLines(path);
    }
}