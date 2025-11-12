<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="java.sql.*, java.util.*"%>
<%
    // Analytics data for visitors
    Map<String, Object> analytics = new HashMap<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

        // Most popular products (most bought)
        String popularSql = "SELECT p.id, p.name, p.category, p.price, p.image, "
                + "SUM(oi.quantity) as total_sold, "
                + "COUNT(DISTINCT o.id) as order_count, "
                + "AVG(oi.quantity) as avg_quantity "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' AND p.is_available = 1 "
                + "GROUP BY p.id, p.name, p.category, p.price, p.image "
                + "ORDER BY total_sold DESC LIMIT 10";
        pstmt = conn.prepareStatement(popularSql);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> popularProducts = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> product = new HashMap<>();
            product.put("id", rs.getInt("id"));
            product.put("name", rs.getString("name"));
            product.put("category", rs.getString("category"));
            product.put("price", rs.getDouble("price"));
            product.put("total_sold", rs.getInt("total_sold"));
            product.put("order_count", rs.getInt("order_count"));
            product.put("avg_quantity", rs.getDouble("avg_quantity"));
            
            // Handle image
            byte[] imageBytes = rs.getBytes("image");
            if (imageBytes != null && imageBytes.length > 0) {
                String base64Image = Base64.getEncoder().encodeToString(imageBytes);
                product.put("image", "data:image/jpeg;base64," + base64Image);
            } else {
                product.put("image", null);
            }
            
            popularProducts.add(product);
        }
        analytics.put("popular_products", popularProducts);
        rs.close();
        pstmt.close();

        // Products in demand (high sales velocity)
        String demandSql = "SELECT p.id, p.name, p.category, "
                + "SUM(oi.quantity) as total_sold, "
                + "COUNT(DISTINCT o.id) as order_count, "
                + "DATEDIFF(NOW(), MIN(o.created_at)) as days_tracked, "
                + "(SUM(oi.quantity) / GREATEST(DATEDIFF(NOW(), MIN(o.created_at)), 1)) as daily_sales_rate "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' AND p.is_available = 1 "
                + "AND o.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY) "
                + "GROUP BY p.id, p.name, p.category "
                + "HAVING days_tracked >= 7 "
                + "ORDER BY daily_sales_rate DESC LIMIT 15";
        pstmt = conn.prepareStatement(demandSql);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> demandProducts = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> product = new HashMap<>();
            product.put("id", rs.getInt("id"));
            product.put("name", rs.getString("name"));
            product.put("category", rs.getString("category"));
            product.put("total_sold", rs.getInt("total_sold"));
            product.put("order_count", rs.getInt("order_count"));
            product.put("daily_sales_rate", rs.getDouble("daily_sales_rate"));
            product.put("demand_level", getDemandLevel(rs.getDouble("daily_sales_rate")));
            demandProducts.add(product);
        }
        analytics.put("demand_products", demandProducts);
        rs.close();
        pstmt.close();

        // Category-wise sales analysis
        String categorySql = "SELECT p.category, "
                + "SUM(oi.quantity) as total_sold, "
                + "COUNT(DISTINCT o.id) as order_count, "
                + "SUM(oi.quantity * oi.price) as total_revenue, "
                + "AVG(oi.quantity) as avg_quantity_per_order "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' AND p.is_available = 1 "
                + "AND o.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY) "
                + "GROUP BY p.category "
                + "ORDER BY total_sold DESC";
        pstmt = conn.prepareStatement(categorySql);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> categoryAnalysis = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> category = new HashMap<>();
            category.put("name", rs.getString("category"));
            category.put("total_sold", rs.getInt("total_sold"));
            category.put("order_count", rs.getInt("order_count"));
            category.put("total_revenue", rs.getDouble("total_revenue"));
            category.put("avg_quantity", rs.getDouble("avg_quantity_per_order"));
            categoryAnalysis.add(category);
        }
        analytics.put("category_analysis", categoryAnalysis);
        rs.close();
        pstmt.close();

        // Seasonal trends (monthly sales by category)
        String seasonalSql = "SELECT p.category, "
                + "DATE_FORMAT(o.created_at, '%Y-%m') as month, "
                + "SUM(oi.quantity) as monthly_sales "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' AND p.is_available = 1 "
                + "AND o.created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) "
                + "GROUP BY p.category, DATE_FORMAT(o.created_at, '%Y-%m') "
                + "ORDER BY month, p.category";
        pstmt = conn.prepareStatement(seasonalSql);
        rs = pstmt.executeQuery();
        Map<String, Map<String, Integer>> seasonalData = new LinkedHashMap<>();
        while (rs.next()) {
            String category = rs.getString("category");
            String month = rs.getString("month");
            int sales = rs.getInt("monthly_sales");
            
            if (!seasonalData.containsKey(category)) {
                seasonalData.put(category, new LinkedHashMap<>());
            }
            seasonalData.get(category).put(month, sales);
        }
        analytics.put("seasonal_trends", seasonalData);
        rs.close();
        pstmt.close();

        // Price sensitivity analysis
        String priceSql = "SELECT "
                + "CASE "
                + "    WHEN p.price <= 50 THEN '0-50' "
                + "    WHEN p.price <= 100 THEN '51-100' "
                + "    WHEN p.price <= 200 THEN '101-200' "
                + "    ELSE '200+' "
                + "END as price_range, "
                + "COUNT(DISTINCT p.id) as product_count, "
                + "SUM(oi.quantity) as total_sold, "
                + "AVG(oi.quantity) as avg_sales_per_product "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' AND p.is_available = 1 "
                + "GROUP BY price_range "
                + "ORDER BY MIN(p.price)";
        pstmt = conn.prepareStatement(priceSql);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> priceAnalysis = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> priceRange = new HashMap<>();
            priceRange.put("range", rs.getString("price_range"));
            priceRange.put("product_count", rs.getInt("product_count"));
            priceRange.put("total_sold", rs.getInt("total_sold"));
            priceRange.put("avg_sales", rs.getDouble("avg_sales_per_product"));
            priceAnalysis.add(priceRange);
        }
        analytics.put("price_analysis", priceAnalysis);
        rs.close();
        pstmt.close();

        // Demand prediction (simple trend analysis)
        String predictionSql = "SELECT p.category, "
                + "SUM(oi.quantity) as current_sales, "
                + "(SELECT SUM(oi2.quantity) "
                + " FROM order_items oi2 "
                + " JOIN orders o2 ON oi2.order_id = o2.id "
                + " JOIN products p2 ON oi2.product_id = p2.id "
                + " WHERE p2.category = p.category "
                + " AND o2.created_at BETWEEN DATE_SUB(NOW(), INTERVAL 60 DAY) AND DATE_SUB(NOW(), INTERVAL 30 DAY) "
                + " AND o2.status = 'DELIVERED') as previous_sales "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE o.status = 'DELIVERED' "
                + "AND o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) "
                + "GROUP BY p.category "
                + "HAVING previous_sales IS NOT NULL";
        pstmt = conn.prepareStatement(predictionSql);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> demandPredictions = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> prediction = new HashMap<>();
            String category = rs.getString("category");
            int currentSales = rs.getInt("current_sales");
            int previousSales = rs.getInt("previous_sales");
            
            double growthRate = previousSales > 0 ? ((double)(currentSales - previousSales) / previousSales) * 100 : 0;
            String trend = growthRate > 10 ? "HIGH_GROWTH" : growthRate > 0 ? "GROWING" : growthRate < -10 ? "DECLINING" : "STABLE";
            
            prediction.put("category", category);
            prediction.put("current_sales", currentSales);
            prediction.put("previous_sales", previousSales);
            prediction.put("growth_rate", growthRate);
            prediction.put("trend", trend);
            prediction.put("recommendation", getRecommendation(trend, category));
            
            demandPredictions.add(prediction);
        }
        analytics.put("demand_predictions", demandPredictions);

    } catch (Exception e) {
        e.printStackTrace();
        // Initialize empty data structures to prevent null pointer exceptions
        analytics.put("popular_products", new ArrayList<>());
        analytics.put("demand_products", new ArrayList<>());
        analytics.put("category_analysis", new ArrayList<>());
        analytics.put("seasonal_trends", new HashMap<>());
        analytics.put("price_analysis", new ArrayList<>());
        analytics.put("demand_predictions", new ArrayList<>());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<%!
    // Helper method to determine demand level
    private String getDemandLevel(double dailySalesRate) {
        if (dailySalesRate >= 5) return "VERY_HIGH";
        if (dailySalesRate >= 2) return "HIGH";
        if (dailySalesRate >= 0.5) return "MEDIUM";
        return "LOW";
    }

    // Helper method to get recommendation based on trend
    private String getRecommendation(String trend, String category) {
        switch (trend) {
            case "HIGH_GROWTH":
                return "Consider increasing stock and promoting " + category + " products";
            case "GROWING":
                return "Maintain good stock levels for " + category;
            case "STABLE":
                return "Monitor " + category + " market for changes";
            case "DECLINING":
                return "Review pricing and marketing for " + category;
            default:
                return "Gather more data for " + category;
        }
    }

    // Helper method to get demand level color
    private String getDemandColor(String demandLevel) {
        switch (demandLevel) {
            case "VERY_HIGH": return "danger";
            case "HIGH": return "warning";
            case "MEDIUM": return "info";
            case "LOW": return "secondary";
            default: return "light";
        }
    }

    // Helper method to get trend icon
    private String getTrendIcon(String trend) {
        switch (trend) {
            case "HIGH_GROWTH": return "fa-arrow-up text-success";
            case "GROWING": return "fa-arrow-up text-success";
            case "STABLE": return "fa-minus text-warning";
            case "DECLINING": return "fa-arrow-down text-danger";
            default: return "fa-question text-secondary";
        }
    }
    
    // Helper method to get trend color
    private String getTrendColor(String trend) {
        switch (trend) {
            case "HIGH_GROWTH": return "success";
            case "GROWING": return "success";
            case "STABLE": return "warning";
            case "DECLINING": return "danger";
            default: return "secondary";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Market Analytics - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --light-bg: #f8f9fa;
                --card-shadow: 0 5px 15px rgba(0,0,0,0.08);
                --hover-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }
            
            body {
                background-color: var(--light-bg);
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
            }
            
            .sidebar {
                width: 250px;
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                background: var(--primary-color);
                color: white;
                z-index: 1000;
                transition: all 0.3s ease;
            }
            
            .sidebar .nav-link {
                color: white;
                padding: 12px 20px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                transition: all 0.3s ease;
            }
            
            .sidebar .nav-link:hover {
                background: rgba(255,255,255,0.1);
                padding-left: 25px;
            }
            
            .sidebar .nav-link.active {
                background: rgba(255,255,255,0.2);
                border-left: 4px solid white;
            }
            
            .main-content {
                margin-left: 250px;
                padding: 20px;
                transition: all 0.3s ease;
                min-height: 100vh;
            }
            
            @media (max-width: 768px) {
                .sidebar {
                    width: 0;
                    transform: translateX(-100%);
                }
                
                .sidebar.show {
                    width: 250px;
                    transform: translateX(0);
                }
                
                .main-content {
                    margin-left: 0;
                }
            }
            
            .stat-card {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                border-radius: 12px;
                padding: 25px;
                text-align: center;
                box-shadow: var(--card-shadow);
                transition: all 0.3s ease;
                height: 100%;
            }
            
            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }
            
            .stat-number {
                font-size: 2.5rem;
                font-weight: 700;
                margin-bottom: 5px;
            }
            
            .chart-container {
                background: white;
                border-radius: 12px;
                padding: 25px;
                box-shadow: var(--card-shadow);
                margin-bottom: 25px;
                transition: all 0.3s ease;
            }
            
            .chart-container:hover {
                box-shadow: var(--hover-shadow);
            }
            
            .product-card {
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                transition: all 0.3s ease;
                background: white;
                height: 100%;
            }
            
            .product-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }
            
            .demand-badge {
                font-size: 0.75rem;
                padding: 6px 12px;
                border-radius: 20px;
                font-weight: 600;
            }
            
            .page-header {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                padding: 60px 0;
                margin-bottom: 40px;
                border-radius: 0 0 20px 20px;
            }
            
            .loading-spinner {
                color: var(--primary-color);
            }
            
            .no-data {
                text-align: center;
                padding: 40px 20px;
                color: #6c757d;
            }
            
            .no-data i {
                font-size: 3rem;
                margin-bottom: 15px;
            }
            
            .trend-indicator {
                font-size: 1.2rem;
                margin-left: 5px;
            }
            
            .table-hover tbody tr:hover {
                background-color: rgba(40, 167, 69, 0.05);
            }
            
            .card-hover {
                transition: all 0.3s ease;
            }
            
            .card-hover:hover {
                transform: translateY(-3px);
                box-shadow: var(--hover-shadow);
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header p-3">
                <h5 class="mb-0"><i class="fas fa-chart-line me-2"></i>Market Analytics</h5>
                <small class="text-white-50">Visitor Dashboard</small>
            </div>
            <nav class="nav flex-column mt-3">
                <a class="nav-link" href="index.jsp"><i class="fas fa-home me-2"></i> Home</a>
                <a class="nav-link" href="Product_lising.jsp"><i class="fas fa-shopping-bag me-2"></i> Browse Products</a>
                <a class="nav-link" href="opportunities.jsp"><i class="fas fa-briefcase me-2"></i> Opportunities</a>
                <a class="nav-link" href="learning_support.jsp"><i class="fas fa-graduation-cap me-2"></i> Learning Hub</a>
                <a class="nav-link active" href="market_analytics.jsp"><i class="fas fa-analytics me-2"></i> Market Analytics</a>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm rounded">
                <button class="btn btn-success" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h5 class="mb-0 text-success">Market Analytics</h5>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="page-header">
                <div class="container">
                    <div class="row align-items-center">
                        <div class="col">
                            <h1 class="display-5 fw-bold mb-3">
                                <i class="fas fa-analytics me-3"></i>Market Intelligence
                            </h1>
                            <p class="lead mb-0">Real-time market trends and demand predictions</p>
                        </div>
                        <div class="col-auto">
                            <div class="btn-group">
                                <button class="btn btn-outline-light active" data-period="30">
                                    <i class="fas fa-calendar-day me-2"></i>30 Days
                                </button>
                                <button class="btn btn-outline-light" data-period="90">
                                    <i class="fas fa-calendar-week me-2"></i>90 Days
                                </button>
                                <button class="btn btn-outline-light" data-period="365">
                                    <i class="fas fa-calendar me-2"></i>1 Year
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="container">
                <!-- Key Metrics -->
                <div class="row mb-5">
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-card">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="stat-number" id="totalProducts">
                                        <%= ((List<Map<String, Object>>) analytics.get("popular_products")).size() %>
                                    </div>
                                    <div class="opacity-75">Top Products</div>
                                </div>
                                <i class="fas fa-star fa-2x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-card">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="stat-number" id="demandItems">
                                        <%= ((List<Map<String, Object>>) analytics.get("demand_products")).size() %>
                                    </div>
                                    <div class="opacity-75">High Demand Items</div>
                                </div>
                                <i class="fas fa-fire fa-2x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-card">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="stat-number" id="totalCategories">
                                        <%= ((List<Map<String, Object>>) analytics.get("category_analysis")).size() %>
                                    </div>
                                    <div class="opacity-75">Categories Tracked</div>
                                </div>
                                <i class="fas fa-tags fa-2x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-card">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="stat-number" id="totalPredictions">
                                        <%= ((List<Map<String, Object>>) analytics.get("demand_predictions")).size() %>
                                    </div>
                                    <div class="opacity-75">Market Predictions</div>
                                </div>
                                <i class="fas fa-chart-line fa-2x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Most Popular Products -->
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="fw-bold mb-0">
                            <i class="fas fa-crown me-2 text-warning"></i>Most Popular Products
                        </h4>
                        <span class="badge bg-success fs-6">
                            <%= ((List<Map<String, Object>>) analytics.get("popular_products")).size() %> products
                        </span>
                    </div>
                    
                    <% if (((List<Map<String, Object>>) analytics.get("popular_products")).isEmpty()) { %>
                    <div class="no-data">
                        <i class="fas fa-box-open text-muted"></i>
                        <h5 class="text-muted">No popular products data available</h5>
                        <p class="text-muted">Product sales data will appear here once orders are completed.</p>
                    </div>
                    <% } else { %>
                    <div class="row">
                        <% for (Map<String, Object> product : (List<Map<String, Object>>) analytics.get("popular_products")) { %>
                        <div class="col-xl-4 col-lg-6 mb-4">
                            <div class="product-card p-4 card-hover">
                                <div class="d-flex align-items-center mb-3">
                                    <% if (product.get("image") != null) { %>
                                    <img src="<%= product.get("image") %>" alt="<%= product.get("name") %>" 
                                         class="rounded me-3" width="60" height="60" style="object-fit: cover;">
                                    <% } else { %>
                                    <div class="bg-light rounded d-flex align-items-center justify-content-center me-3" 
                                         style="width: 60px; height: 60px;">
                                        <i class="fas fa-image text-muted fa-lg"></i>
                                    </div>
                                    <% } %>
                                    <div class="flex-grow-1">
                                        <h6 class="fw-bold mb-1 text-truncate"><%= product.get("name") %></h6>
                                        <span class="badge bg-secondary"><%= product.get("category") %></span>
                                    </div>
                                </div>
                                <div class="row text-center">
                                    <div class="col-4">
                                        <div class="border-end">
                                            <div class="fw-bold text-success fs-5">M <%= String.format("%.2f", product.get("price")) %></div>
                                            <small class="text-muted">Price</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="border-end">
                                            <div class="fw-bold text-primary fs-5"><%= product.get("total_sold") %></div>
                                            <small class="text-muted">Sold</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div>
                                            <div class="fw-bold text-info fs-5"><%= product.get("order_count") %></div>
                                            <small class="text-muted">Orders</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>

                <div class="row">
                    <!-- Products in Demand -->
                    <div class="col-md-6">
                        <div class="chart-container h-100">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4 class="fw-bold mb-0">
                                    <i class="fas fa-fire me-2 text-danger"></i>Products in High Demand
                                </h4>
                                <span class="badge bg-danger fs-6">
                                    <%= ((List<Map<String, Object>>) analytics.get("demand_products")).size() %> items
                                </span>
                            </div>
                            
                            <% if (((List<Map<String, Object>>) analytics.get("demand_products")).isEmpty()) { %>
                            <div class="no-data">
                                <i class="fas fa-chart-line text-muted"></i>
                                <h5 class="text-muted">No demand data available</h5>
                                <p class="text-muted">Demand analytics will appear here with sufficient sales data.</p>
                            </div>
                            <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Product</th>
                                            <th>Category</th>
                                            <th>Daily Sales</th>
                                            <th>Demand Level</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> product : (List<Map<String, Object>>) analytics.get("demand_products")) { %>
                                        <tr class="card-hover">
                                            <td>
                                                <strong><%= product.get("name") %></strong>
                                            </td>
                                            <td>
                                                <span class="badge bg-secondary"><%= product.get("category") %></span>
                                            </td>
                                            <td>
                                                <span class="fw-bold"><%= String.format("%.1f", product.get("daily_sales_rate")) %></span>
                                                <small class="text-muted d-block">units/day</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-<%= getDemandColor((String) product.get("demand_level")) %> demand-badge">
                                                    <i class="fas fa-<%= "VERY_HIGH".equals(product.get("demand_level")) ? "rocket" : "chart-line" %> me-1"></i>
                                                    <%= product.get("demand_level") %>
                                                </span>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Demand Predictions -->
                    <div class="col-md-6">
                        <div class="chart-container h-100">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4 class="fw-bold mb-0">
                                    <i class="fas fa-crystal-ball me-2 text-info"></i>Demand Predictions
                                </h4>
                                <span class="badge bg-info fs-6">
                                    <%= ((List<Map<String, Object>>) analytics.get("demand_predictions")).size() %> predictions
                                </span>
                            </div>
                            
                            <% if (((List<Map<String, Object>>) analytics.get("demand_predictions")).isEmpty()) { %>
                            <div class="no-data">
                                <i class="fas fa-chart-bar text-muted"></i>
                                <h5 class="text-muted">No prediction data available</h5>
                                <p class="text-muted">Predictions will appear here with sufficient historical data.</p>
                            </div>
                            <% } else { %>
                            <div class="list-group">
                                <% for (Map<String, Object> prediction : (List<Map<String, Object>>) analytics.get("demand_predictions")) { %>
                                <div class="list-group-item card-hover">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div class="flex-grow-1">
                                            <div class="d-flex align-items-center mb-2">
                                                <h6 class="fw-bold mb-0 me-2"><%= prediction.get("category") %></h6>
                                                <span class="badge bg-<%= getTrendColor((String) prediction.get("trend")) %>">
                                                    <i class="fas <%= getTrendIcon((String) prediction.get("trend")) %> me-1"></i>
                                                    <%= prediction.get("trend") %>
                                                </span>
                                            </div>
                                            <p class="mb-2 text-muted small"><%= prediction.get("recommendation") %></p>
                                            <div class="d-flex align-items-center">
                                                <small class="text-muted me-3">
                                                    <i class="fas fa-chart-line me-1"></i>
                                                    Growth: <strong><%= String.format("%.1f", prediction.get("growth_rate")) %>%</strong>
                                                </small>
                                                <small class="text-muted">
                                                    <i class="fas fa-shopping-cart me-1"></i>
                                                    Current: <strong><%= prediction.get("current_sales") %></strong> units
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Charts Row -->
                <div class="row">
                    <!-- Category Sales Distribution -->
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h4 class="fw-bold mb-4">
                                <i class="fas fa-chart-pie me-2 text-success"></i>Sales by Category
                            </h4>
                            <% if (((List<Map<String, Object>>) analytics.get("category_analysis")).isEmpty()) { %>
                            <div class="no-data">
                                <i class="fas fa-chart-pie text-muted"></i>
                                <h5 class="text-muted">No category data available</h5>
                            </div>
                            <% } else { %>
                            <canvas id="categoryChart" height="250"></canvas>
                            <% } %>
                        </div>
                    </div>

                    <!-- Price Sensitivity -->
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h4 class="fw-bold mb-4">
                                <i class="fas fa-money-bill-wave me-2 text-warning"></i>Price Sensitivity Analysis
                            </h4>
                            <% if (((List<Map<String, Object>>) analytics.get("price_analysis")).isEmpty()) { %>
                            <div class="no-data">
                                <i class="fas fa-chart-bar text-muted"></i>
                                <h5 class="text-muted">No price analysis data available</h5>
                            </div>
                            <% } else { %>
                            <canvas id="priceChart" height="250"></canvas>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Seasonal Trends -->
                <div class="chart-container">
                    <h4 class="fw-bold mb-4">
                        <i class="fas fa-calendar-alt me-2 text-primary"></i>Seasonal Trends
                    </h4>
                    <% if (((Map<String, Map<String, Integer>>) analytics.get("seasonal_trends")).isEmpty()) { %>
                    <div class="no-data">
                        <i class="fas fa-calendar text-muted"></i>
                        <h5 class="text-muted">No seasonal data available</h5>
                        <p class="text-muted">Seasonal trends will appear here with sufficient historical data.</p>
                    </div>
                    <% } else { %>
                    <canvas id="seasonalChart" height="300"></canvas>
                    <% } %>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Sidebar toggle for mobile
            $('#sidebarToggle').click(function () {
                $('#sidebar').toggleClass('show');
            });

            // Close sidebar when clicking on a link (mobile)
            $('.sidebar .nav-link').click(function() {
                if ($(window).width() <= 768) {
                    $('#sidebar').removeClass('show');
                }
            });

            // Initialize charts only if data is available
            $(document).ready(function () {
                <% if (!((List<Map<String, Object>>) analytics.get("category_analysis")).isEmpty()) { %>
                initializeCategoryChart();
                <% } %>
                
                <% if (!((List<Map<String, Object>>) analytics.get("price_analysis")).isEmpty()) { %>
                initializePriceChart();
                <% } %>
                
                <% if (!((Map<String, Map<String, Integer>>) analytics.get("seasonal_trends")).isEmpty()) { %>
                initializeSeasonalChart();
                <% } %>
                
                initializePeriodFilters();
            });

            // Category Sales Chart
            function initializeCategoryChart() {
                const categoryCtx = document.getElementById('categoryChart').getContext('2d');
                new Chart(categoryCtx, {
                    type: 'doughnut',
                    data: {
                        labels: [
                            <% for (Map<String, Object> category : (List<Map<String, Object>>) analytics.get("category_analysis")) { %>
                                '<%= category.get("name") %>',
                            <% } %>
                        ],
                        datasets: [{
                            data: [
                                <% for (Map<String, Object> category : (List<Map<String, Object>>) analytics.get("category_analysis")) { %>
                                    <%= category.get("total_sold") %>,
                                <% } %>
                            ],
                            backgroundColor: [
                                '#28a745', '#20c997', '#17a2b8', '#6f42c1', '#e83e8c',
                                '#fd7e14', '#ffc107', '#dc3545', '#6c757d', '#343a40'
                            ],
                            borderWidth: 2,
                            borderColor: '#fff'
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    padding: 20,
                                    usePointStyle: true
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const label = context.label || '';
                                        const value = context.raw || 0;
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        const percentage = Math.round((value / total) * 100);
                                        return `${label}: ${value} units (${percentage}%)`;
                                    }
                                }
                            }
                        },
                        cutout: '50%'
                    }
                });
            }

            // Price Sensitivity Chart
            function initializePriceChart() {
                const priceCtx = document.getElementById('priceChart').getContext('2d');
                new Chart(priceCtx, {
                    type: 'bar',
                    data: {
                        labels: [
                            <% for (Map<String, Object> priceRange : (List<Map<String, Object>>) analytics.get("price_analysis")) { %>
                                'M <%= priceRange.get("range") %>',
                            <% } %>
                        ],
                        datasets: [{
                            label: 'Average Sales per Product',
                            data: [
                                <% for (Map<String, Object> priceRange : (List<Map<String, Object>>) analytics.get("price_analysis")) { %>
                                    <%= priceRange.get("avg_sales") %>,
                                <% } %>
                            ],
                            backgroundColor: '#28a745',
                            borderColor: '#218838',
                            borderWidth: 1,
                            borderRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return `Avg Sales: ${context.raw.toFixed(1)} units`;
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: 'Average Units Sold',
                                    font: {
                                        weight: 'bold'
                                    }
                                },
                                grid: {
                                    color: 'rgba(0,0,0,0.1)'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Price Range (M)',
                                    font: {
                                        weight: 'bold'
                                    }
                                },
                                grid: {
                                    display: false
                                }
                            }
                        }
                    }
                });
            }

            // Seasonal Trends Chart
            function initializeSeasonalChart() {
                const seasonalCtx = document.getElementById('seasonalChart').getContext('2d');
                <%
                    Map<String, Map<String, Integer>> seasonalData = (Map<String, Map<String, Integer>>) analytics.get("seasonal_trends");
                    Set<String> months = new TreeSet<>();
                    for (Map<String, Integer> categoryData : seasonalData.values()) {
                        months.addAll(categoryData.keySet());
                    }
                    List<String> monthList = new ArrayList<>(months);
                    Collections.sort(monthList);
                    
                    // Format months for better display
                    List<String> formattedMonths = new ArrayList<>();
                    for (String month : monthList) {
                        String[] parts = month.split("-");
                        if (parts.length == 2) {
                            formattedMonths.add(parts[1] + "/" + parts[0].substring(2));
                        } else {
                            formattedMonths.add(month);
                        }
                    }
                %>
                
                const seasonalChart = new Chart(seasonalCtx, {
                    type: 'line',
                    data: {
                        labels: [
                            <% for (String month : formattedMonths) { %>
                                '<%= month %>',
                            <% } %>
                        ],
                        datasets: [
                            <% 
                            int colorIndex = 0;
                            String[] colors = {"#28a745", "#dc3545", "#ffc107", "#17a2b8", "#6f42c1", "#e83e8c", "#fd7e14"};
                            for (String category : seasonalData.keySet()) { 
                            %>
                            {
                                label: '<%= category %>',
                                data: [
                                    <% for (String month : monthList) { %>
                                        <%= seasonalData.get(category).getOrDefault(month, 0) %>,
                                    <% } %>
                                ],
                                borderColor: '<%= colors[colorIndex % colors.length] %>',
                                backgroundColor: '<%= colors[colorIndex % colors.length] %>20',
                                tension: 0.4,
                                fill: true,
                                borderWidth: 3,
                                pointBackgroundColor: '<%= colors[colorIndex % colors.length] %>',
                                pointBorderColor: '#fff',
                                pointBorderWidth: 2,
                                pointRadius: 5,
                                pointHoverRadius: 7
                            },
                            <% 
                                colorIndex++;
                            } 
                            %>
                        ]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                position: 'top',
                                labels: {
                                    padding: 15,
                                    usePointStyle: true
                                }
                            },
                            tooltip: {
                                mode: 'index',
                                intersect: false
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: 'Units Sold',
                                    font: {
                                        weight: 'bold'
                                    }
                                },
                                grid: {
                                    color: 'rgba(0,0,0,0.1)'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Month',
                                    font: {
                                        weight: 'bold'
                                    }
                                },
                                grid: {
                                    display: false
                                }
                            }
                        },
                        interaction: {
                            intersect: false,
                            mode: 'nearest'
                        }
                    }
                });
            }

            // Period filter functionality
            function initializePeriodFilters() {
                $('[data-period]').click(function () {
                    $('[data-period]').removeClass('active');
                    $(this).addClass('active');
                    const period = $(this).data('period');
                    
                    // Show loading state
                    showLoadingState();
                    
                    // Simulate data reload (in real implementation, this would be an AJAX call)
                    setTimeout(() => {
                        hideLoadingState();
                        showNotification('Data updated for ' + period + ' days period', 'success');
                    }, 1000);
                });
            }

            // Loading state functions
            function showLoadingState() {
                $('.chart-container').addClass('opacity-50');
                $('.stat-card').addClass('opacity-50');
            }

            function hideLoadingState() {
                $('.chart-container').removeClass('opacity-50');
                $('.stat-card').removeClass('opacity-50');
            }

            // Notification function
            function showNotification(message, type) {
                const alertClass = type === 'success' ? 'alert-success' : 'alert-info';
                const notification = $(
                    `<div class="alert ${alertClass} alert-dismissible fade show position-fixed" 
                         style="top: 20px; right: 20px; z-index: 1060; min-width: 300px;">
                        ${message}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>`
                );
                $('body').append(notification);
                setTimeout(function () {
                    notification.alert('close');
                }, 3000);
            }

            // Helper function for random colors (fallback)
            function getRandomColor() {
                const colors = [
                    '#28a745', '#dc3545', '#ffc107', '#17a2b8', '#6f42c1',
                    '#e83e8c', '#fd7e14', '#20c997', '#6610f2', '#d63384'
                ];
                return colors[Math.floor(Math.random() * colors.length)];
            }
        </script>
    </body>
</html>