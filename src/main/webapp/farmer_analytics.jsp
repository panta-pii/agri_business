<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="java.sql.*, java.util.*"%>
<%
    HttpSession sessionObj = request.getSession(false);
    String userName = (sessionObj != null) ? (String) sessionObj.getAttribute("userName") : null;
    Integer userId = (sessionObj != null) ? (Integer) sessionObj.getAttribute("userId") : null;

    if (userName == null || userId == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }

    // Analytics data
    Map<String, Object> analytics = new HashMap<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

        // Total revenue
        String revenueSql = "SELECT COALESCE(SUM(oi.quantity * oi.price), 0) as total_revenue "
                + "FROM order_items oi "
                + "JOIN products p ON oi.product_id = p.id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE p.user_id = ? AND o.status = 'DELIVERED'";
        pstmt = conn.prepareStatement(revenueSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            analytics.put("total_revenue", rs.getDouble("total_revenue"));
        }
        rs.close();
        pstmt.close();

        // Total products
        String productsSql = "SELECT COUNT(*) as total_products FROM products WHERE user_id = ?";
        pstmt = conn.prepareStatement(productsSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            analytics.put("total_products", rs.getInt("total_products"));
        }
        rs.close();
        pstmt.close();

        // Total orders
        String ordersSql = "SELECT COUNT(DISTINCT o.id) as total_orders "
                + "FROM orders o "
                + "JOIN order_items oi ON o.id = oi.order_id "
                + "JOIN products p ON oi.product_id = p.id "
                + "WHERE p.user_id = ?";
        pstmt = conn.prepareStatement(ordersSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            analytics.put("total_orders", rs.getInt("total_orders"));
        }
        rs.close();
        pstmt.close();

        // Total items sold
        String soldSql = "SELECT COALESCE(SUM(oi.quantity), 0) as total_sold "
                + "FROM order_items oi "
                + "JOIN products p ON oi.product_id = p.id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE p.user_id = ? AND o.status = 'DELIVERED'";
        pstmt = conn.prepareStatement(soldSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            analytics.put("total_sold", rs.getInt("total_sold"));
        }
        rs.close();
        pstmt.close();

        // Monthly revenue
        String monthlySql = "SELECT DATE_FORMAT(o.created_at, '%Y-%m') as month, "
                + "SUM(oi.quantity * oi.price) as monthly_revenue "
                + "FROM orders o "
                + "JOIN order_items oi ON o.id = oi.order_id "
                + "JOIN products p ON oi.product_id = p.id "
                + "WHERE p.user_id = ? AND o.status = 'DELIVERED' "
                + "GROUP BY DATE_FORMAT(o.created_at, '%Y-%m') "
                + "ORDER BY month DESC LIMIT 6";
        pstmt = conn.prepareStatement(monthlySql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> monthlyRevenue = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> month = new HashMap<>();
            month.put("month", rs.getString("month"));
            month.put("revenue", rs.getDouble("monthly_revenue"));
            monthlyRevenue.add(month);
        }
        analytics.put("monthly_revenue", monthlyRevenue);
        rs.close();
        pstmt.close();

        // Top products
        String topProductsSql = "SELECT p.name, SUM(oi.quantity) as total_sold, "
                + "SUM(oi.quantity * oi.price) as revenue "
                + "FROM products p "
                + "JOIN order_items oi ON p.id = oi.product_id "
                + "JOIN orders o ON oi.order_id = o.id "
                + "WHERE p.user_id = ? AND o.status = 'DELIVERED' "
                + "GROUP BY p.id, p.name "
                + "ORDER BY total_sold DESC LIMIT 5";
        pstmt = conn.prepareStatement(topProductsSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        List<Map<String, Object>> topProducts = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> product = new HashMap<>();
            product.put("name", rs.getString("name"));
            product.put("total_sold", rs.getInt("total_sold"));
            product.put("revenue", rs.getDouble("revenue"));
            topProducts.add(product);
        }
        analytics.put("top_products", topProducts);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try {
            rs.close();
        } catch (Exception e) {
        }
        if (pstmt != null) try {
            pstmt.close();
        } catch (Exception e) {
        }
        if (conn != null) try {
            conn.close();
        } catch (Exception e) {
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Analytics - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            .sidebar {
                width: 250px;
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                background: #28a745;
                color: white;
                z-index: 1000;
            }
            .sidebar .nav-link {
                color: white;
                padding: 12px 20px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
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
                background: linear-gradient(135deg, #28a745, #20c997);
                color: white;
                border-radius: 10px;
            }
            .chart-container {
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header p-3">
                <h5 class="mb-0"><i class="fas fa-tractor me-2"></i><%= userName%></h5>
                <small class="text-white-50">Farmer Account</small>
            </div>
            <nav class="nav flex-column mt-3">
                <a class="nav-link" href="index.jsp"><i class="fas fa-home me-2"></i> Home</a>
                <a class="nav-link" href="profile.jsp"><i class="fas fa-user me-2"></i> My Profile</a>
                <a class="nav-link" href="farmers_dashboard.jsp"><i class="fas fa-shopping-bag me-2"></i> Orders Received</a>
                <a class="nav-link" href="product_management.jsp"><i class="fas fa-plus-circle me-2"></i> Manage Products</a>
                <a class="nav-link" href="my_listings.jsp"><i class="fas fa-boxes me-2"></i> My Listings</a>
                <a class="nav-link" href="messages.jsp"><i class="fas fa-comments me-2"></i> Messages</a>
                <a class="nav-link active" href="farmer_analytics.jsp"><i class="fas fa-chart-bar me-2"></i> Analytics</a>
                <div class="mt-4 p-3"><a class="btn btn-outline-light btn-sm w-100" href="LogoutServlet"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></div>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm">
                <button class="btn btn-success" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                <h5 class="mb-0 text-success">Analytics</h5>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="text-success mb-1"><i class="fas fa-chart-bar me-2"></i>Business Analytics</h2>
                    <p class="text-muted mb-0">Track your farming business performance</p>
                </div>
                <div class="btn-group">
                    <button class="btn btn-outline-success active" data-period="month">This Month</button>
                    <button class="btn btn-outline-success" data-period="quarter">This Quarter</button>
                    <button class="btn btn-outline-success" data-period="year">This Year</button>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="stat-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h3>M <%= String.format("%.2f", analytics.get("total_revenue"))%></h3>
                                <p class="mb-0">Total Revenue</p>
                            </div>
                            <i class="fas fa-money-bill-wave fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h3><%= analytics.get("total_products")%></h3>
                                <p class="mb-0">Products Listed</p>
                            </div>
                            <i class="fas fa-boxes fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h3><%= analytics.get("total_orders")%></h3>
                                <p class="mb-0">Total Orders</p>
                            </div>
                            <i class="fas fa-shopping-bag fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h3><%= analytics.get("total_sold")%></h3>
                                <p class="mb-0">Items Sold</p>
                            </div>
                            <i class="fas fa-chart-line fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts -->
            <div class="row">
                <!-- Revenue Chart -->
                <div class="col-md-8 mb-4">
                    <div class="chart-container">
                        <h5 class="mb-3"><i class="fas fa-chart-line me-2"></i>Revenue Trend</h5>
                        <canvas id="revenueChart" height="250"></canvas>
                    </div>
                </div>

                <!-- Top Products -->
                <div class="col-md-4 mb-4">
                    <div class="chart-container">
                        <h5 class="mb-3"><i class="fas fa-star me-2"></i>Top Products</h5>
                        <div class="list-group">
                            <% for (Map<String, Object> product : (List<Map<String, Object>>) analytics.get("top_products")) {%>
                            <div class="list-group-item d-flex justify-content-between align-items-center">
                                <div>
                                    <strong><%= product.get("name")%></strong>
                                    <br>
                                    <small class="text-muted"><%= product.get("total_sold")%> sold</small>
                                </div>
                                <span class="badge bg-success rounded-pill">M <%= String.format("%.2f", product.get("revenue"))%></span>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Additional Metrics -->
            <div class="row">
                <div class="col-md-6">
                    <div class="chart-container">
                        <h5 class="mb-3"><i class="fas fa-box me-2"></i>Inventory Status</h5>
                        <canvas id="inventoryChart" height="200"></canvas>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="chart-container">
                        <h5 class="mb-3"><i class="fas fa-tags me-2"></i>Sales by Category</h5>
                        <canvas id="categoryChart" height="200"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            $('#sidebarToggle').click(function () {
                $('#sidebar').toggleClass('show');
            });

            // Revenue Chart
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            const revenueChart = new Chart(revenueCtx, {
                type: 'line',
                data: {
                    labels: [<%
                        List<Map<String, Object>> monthlyRevenue = (List<Map<String, Object>>) analytics.get("monthly_revenue");
                        for (int i = monthlyRevenue.size() - 1; i >= 0; i--) {
                            out.print("'" + monthlyRevenue.get(i).get("month") + "'");
                            if (i > 0) {
                                out.print(", ");
                            }
                        }
            %>],
                    datasets: [{
                            label: 'Monthly Revenue (M)',
                            data: [<%
                            for (int i = monthlyRevenue.size() - 1; i >= 0; i--) {
                                out.print(monthlyRevenue.get(i).get("revenue"));
                                if (i > 0) {
                                    out.print(", ");
                                }
                            }
            %>],
                            borderColor: '#28a745',
                            backgroundColor: 'rgba(40, 167, 69, 0.1)',
                            tension: 0.4,
                            fill: true
                        }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {display: false}
                    }
                }
            });

            // Sample charts (you would populate these with real data)
            const inventoryCtx = document.getElementById('inventoryChart').getContext('2d');
            new Chart(inventoryCtx, {
                type: 'doughnut',
                data: {
                    labels: ['In Stock', 'Low Stock', 'Out of Stock'],
                    datasets: [{
                            data: [70, 20, 10],
                            backgroundColor: ['#28a745', '#ffc107', '#dc3545']
                        }]
                }
            });

            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'bar',
                data: {
                    labels: ['Vegetables', 'Fruits', 'Grains', 'Livestock'],
                    datasets: [{
                            label: 'Sales (M)',
                            data: [1200, 800, 600, 400],
                            backgroundColor: '#28a745'
                        }]
                }
            });

            // Period filter
            $('[data-period]').click(function () {
                $('[data-period]').removeClass('active');
                $(this).addClass('active');
                // Here you would reload charts with filtered data
            });
        </script>
    </body>
</html>