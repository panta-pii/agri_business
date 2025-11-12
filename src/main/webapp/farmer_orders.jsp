<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, javax.servlet.http.*"%>

<%
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("user") == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }

    int userId = ((models.User) sessionObj.getAttribute("user")).getId();

    String url = "jdbc:mysql://localhost:3306/agri_business";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    PreparedStatement psOrders = null;
    PreparedStatement psItems = null;
    ResultSet rsOrders = null;
    ResultSet rsItems = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Orders - AgriYouth Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top">
    <div class="container">
        <a class="navbar-brand" href="#"><i class="fas fa-leaf"></i> AgriYouth Marketplace</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><a class="nav-link text-white" href="user_dashboard.jsp"><i class="fas fa-arrow-left"></i> Back to Dashboard</a></li>
            <li class="nav-item"><a class="nav-link text-white" href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>
</nav>

<div class="container mt-5">
    <h2 class="mb-4 text-success"><i class="fas fa-receipt"></i> My Orders</h2>

    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // FIXED: Replaced text blocks with regular string
            String sql = "SELECT o.id AS order_id, o.created_at, o.total_amount, o.status, " +
                        "u.first_name, u.last_name, u.email " +
                        "FROM orders o " +
                        "JOIN users u ON o.user_id = u.id " +
                        "JOIN order_items oi ON o.id = oi.order_id " +
                        "JOIN products p ON oi.product_id = p.id " +
                        "WHERE p.user_id = ? " +
                        "GROUP BY o.id " +
                        "ORDER BY o.created_at DESC";
            
            psOrders = conn.prepareStatement(sql);
            psOrders.setInt(1, userId);
            rsOrders = psOrders.executeQuery();

            if (!rsOrders.isBeforeFirst()) {
                out.println("<p class='text-muted'>You have no orders yet.</p>");
            }

            while (rsOrders.next()) {
                int orderId = rsOrders.getInt("order_id");
                double total = rsOrders.getDouble("total_amount");
                String status = rsOrders.getString("status");
                Timestamp date = rsOrders.getTimestamp("created_at");
                String customerName = rsOrders.getString("first_name") + " " + rsOrders.getString("last_name");
                String customerEmail = rsOrders.getString("email");
    %>

    <div class="card mb-4 shadow-sm border-0">
        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
            <div>
                <strong>Order #<%=orderId%></strong> — <%=date%>
            </div>
            <div>
                <span class="badge bg-light text-success me-2"><%=status%></span>
            </div>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-6">
                    <strong>Customer:</strong> <%=customerName%>
                </div>
                <div class="col-md-6">
                    <strong>Email:</strong> <%=customerEmail%>
                </div>
            </div>
            
            <table class="table table-sm table-borderless">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Qty</th>
                        <th>Price (M)</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        // FIXED: Replaced text blocks with regular string
                        String itemsSql = "SELECT p.name, oi.quantity, oi.price, (oi.quantity * oi.price) as subtotal " +
                                         "FROM order_items oi " +
                                         "JOIN products p ON oi.product_id = p.id " +
                                         "WHERE oi.order_id = ? AND p.user_id = ?";
                        psItems = conn.prepareStatement(itemsSql);
                        psItems.setInt(1, orderId);
                        psItems.setInt(2, userId);
                        rsItems = psItems.executeQuery();
                        
                        while (rsItems.next()) {
                    %>
                    <tr>
                        <td><%=rsItems.getString("name")%></td>
                        <td><%=rsItems.getInt("quantity")%></td>
                        <td>M <%=rsItems.getDouble("price")%></td>
                        <td>M <%=rsItems.getDouble("subtotal")%></td>
                    </tr>
                    <%
                        }
                        if (rsItems != null) {
                            rsItems.close();
                        }
                        if (psItems != null) {
                            psItems.close();
                        }
                    %>
                </tbody>
            </table>
            <hr>
            <div class="d-flex justify-content-between align-items-center">
                <strong>Total Amount:</strong>
                <span class="fw-bold text-success fs-5">M <%=String.format("%.2f", total)%></span>
            </div>
            
            <!-- Order Actions -->
            <div class="mt-3">
                <%
                    if ("PENDING".equals(status)) {
                %>
                <form action="UpdateOrderStatusServlet" method="post" class="d-inline">
                    <input type="hidden" name="orderId" value="<%=orderId%>">
                    <input type="hidden" name="status" value="CONFIRMED">
                    <button type="submit" class="btn btn-success btn-sm">
                        <i class="fas fa-check"></i> Confirm Order
                    </button>
                </form>
                <form action="UpdateOrderStatusServlet" method="post" class="d-inline">
                    <input type="hidden" name="orderId" value="<%=orderId%>">
                    <input type="hidden" name="status" value="CANCELLED">
                    <button type="submit" class="btn btn-danger btn-sm">
                        <i class="fas fa-times"></i> Cancel Order
                    </button>
                </form>
                <%
                    } else if ("CONFIRMED".equals(status)) {
                %>
                <form action="UpdateOrderStatusServlet" method="post" class="d-inline">
                    <input type="hidden" name="orderId" value="<%=orderId%>">
                    <input type="hidden" name="status" value="COMPLETED">
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="fas fa-shipping-fast"></i> Mark as Delivered
                    </button>
                </form>
                <%
                    }
                %>
            </div>
        </div>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error loading orders: " + e.getMessage() + "</div>");
            e.printStackTrace();
        } finally {
            // Close resources in finally block
            try {
                if (rsOrders != null) rsOrders.close();
                if (psOrders != null) psOrders.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</div>

<footer class="bg-dark text-white text-center py-3 mt-5">
    © 2025 AgriYouth Marketplace. All Rights Reserved.
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>