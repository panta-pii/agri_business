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

            psOrders = conn.prepareStatement("SELECT * FROM orders WHERE user_id=? ORDER BY created_at DESC");
            psOrders.setInt(1, userId);
            rsOrders = psOrders.executeQuery();

            if (!rsOrders.isBeforeFirst()) {
                out.println("<p class='text-muted'>You have no orders yet.</p>");
            }

            while (rsOrders.next()) {
                int orderId = rsOrders.getInt("id");
                double total = rsOrders.getDouble("total_amount");
                String status = rsOrders.getString("status");
                Timestamp date = rsOrders.getTimestamp("created_at");
    %>

    <div class="card mb-4 shadow-sm border-0">
        <div class="card-header bg-success text-white">
            <strong>Order #<%=orderId%></strong> — <%=date%> 
            <span class="badge bg-light text-success float-end"><%=status%></span>
        </div>
        <div class="card-body">
            <table class="table table-sm table-borderless">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Qty</th>
                        <th>Price (M)</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        psItems = conn.prepareStatement(
                            "SELECT p.name, oi.quantity, oi.price FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id=?");
                        psItems.setInt(1, orderId);
                        rsItems = psItems.executeQuery();
                        while (rsItems.next()) {
                    %>
                    <tr>
                        <td><%=rsItems.getString("name")%></td>
                        <td><%=rsItems.getInt("quantity")%></td>
                        <td><%=rsItems.getDouble("price")%></td>
                    </tr>
                    <%
                        }
                        rsItems.close();
                        psItems.close();
                    %>
                </tbody>
            </table>
            <hr>
            <div class="d-flex justify-content-between">
                <strong>Total:</strong>
                <span class="fw-bold text-success">M <%=String.format("%.2f", total)%></span>
            </div>
        </div>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red'>Error loading orders: " + e.getMessage() + "</p>");
        } finally {
            if (rsOrders != null) rsOrders.close();
            if (psOrders != null) psOrders.close();
            if (conn != null) conn.close();
        }
    %>
</div>

<footer class="bg-dark text-white text-center py-3 mt-5">
    © 2025 AgriYouth Marketplace. All Rights Reserved.
</footer>
</body>
</html>
