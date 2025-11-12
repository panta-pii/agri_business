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

    // Database connection for farmer's orders
    List<Map<String, Object>> orders = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

        // Query to get orders for products created by this farmer
        String sql = "SELECT "
                + "o.id as order_id, "
                + "o.total_amount, "
                + "o.status, "
                + "o.delivery_address, "
                + "o.phone_number, "
                + "o.payment_method, "
                + "o.created_at, "
                + "oi.quantity as item_quantity, "
                + "oi.price as item_price, "
                + "p.name as product_name, "
                + "p.id as product_id, "
                + "u.first_name as customer_name, "
                + "u.email as customer_email "
                + "FROM orders o "
                + "JOIN order_items oi ON o.id = oi.order_id "
                + "JOIN products p ON oi.product_id = p.id "
                + "JOIN users u ON o.user_id = u.id "
                + "WHERE p.user_id = ? "
                + // Only products created by this farmer
                "ORDER BY o.created_at DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> order = new HashMap<>();
            order.put("order_id", rs.getInt("order_id"));
            order.put("total_amount", rs.getDouble("total_amount"));
            order.put("status", rs.getString("status"));
            order.put("delivery_address", rs.getString("delivery_address"));
            order.put("phone_number", rs.getString("phone_number"));
            order.put("payment_method", rs.getString("payment_method"));
            order.put("created_at", rs.getTimestamp("created_at"));
            order.put("item_quantity", rs.getInt("item_quantity"));
            order.put("item_price", rs.getDouble("item_price"));
            order.put("product_name", rs.getString("product_name"));
            order.put("product_id", rs.getInt("product_id"));
            order.put("customer_name", rs.getString("customer_name"));
            order.put("customer_email", rs.getString("customer_email"));
            orders.add(order);
        }

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

    // Calculate stats
    int pendingCount = 0;
    int paidCount = 0;
    int deliveredCount = 0;

    for (Map<String, Object> order : orders) {
        String status = (String) order.get("status");
        switch (status) {
            case "PENDING":
                pendingCount++;
                break;
            case "PAID":
                paidCount++;
                break;
            case "DELIVERED":
                deliveredCount++;
                break;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Farmer Dashboard - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --sidebar-width: 250px;
            }

            .sidebar {
                width: var(--sidebar-width);
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                background: var(--primary-color);
                color: white;
                transition: all 0.3s;
                z-index: 1000;
            }

            .sidebar .nav-link {
                color: white;
                padding: 12px 20px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                transition: all 0.3s;
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
                margin-left: var(--sidebar-width);
                padding: 20px;
                transition: all 0.3s;
            }

            @media (max-width: 768px) {
                .sidebar {
                    width: 0;
                    transform: translateX(-100%);
                }

                .sidebar.show {
                    width: var(--sidebar-width);
                    transform: translateX(0);
                }

                .main-content {
                    margin-left: 0;
                }
            }

            .status-PENDING {
                background-color: #fff3cd;
                color: #856404;
            }
            .status-PAID {
                background-color: #d1ecf1;
                color: #0c5460;
            }
            .status-DELIVERED {
                background-color: #d4edda;
                color: #155724;
            }

            .order-card {
                border: none;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                transition: transform 0.2s;
            }

            .order-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 15px rgba(0,0,0,0.15);
            }

            .farmer-stats-card {
                background: linear-gradient(135deg, #28a745, #20c997);
                color: white;
                border-radius: 10px;
            }

            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 1060;
                min-width: 300px;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header p-3 bg-success-dark">
                <h5 class="mb-0">
                    <i class="fas fa-tractor me-2"></i>
                    <%= userName%>
                </h5>
                <small class="text-white-50">Farmer Account</small>
            </div>

            <nav class="nav flex-column mt-3">
                <a class="nav-link" href="index.jsp">
                    <i class="fas fa-home me-2"></i> Home
                </a>
                <a class="nav-link" href="profile.jsp">
                    <i class="fas fa-user me-2"></i> My Profile
                </a>
                <a class="nav-link active" href="farmers_dashboard.jsp">
                    <i class="fas fa-shopping-bag me-2"></i> Orders Received
                </a>
                <a class="nav-link" href="messages.jsp">
                    <i class="fas fa-comments me-2"></i> Messages
                </a>
                <a class="nav-link" href="farmer_analytics.jsp">
                    <i class="fas fa-chart-bar me-2"></i> Analytics
                </a>
                <div class="mt-4 p-3">
                    <a class="btn btn-outline-light btn-sm w-100" href="LogoutServlet">
                        <i class="fas fa-sign-out-alt me-2"></i> Logout
                    </a>
                </div>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm">
                <button class="btn btn-success" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h5 class="mb-0 text-success">Farmer Dashboard</h5>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="text-success mb-1">
                        <i class="fas fa-tractor me-2"></i>Farmer Dashboard
                    </h2>
                    <p class="text-muted mb-0">Manage your products and orders</p>
                </div>
                <a href="product_management.jsp" class="btn btn-success">
                    <i class="fas fa-plus me-2"></i>Add New Product
                </a>
            </div>

            <!-- Farmer Statistics -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="farmer-stats-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="totalOrders"><%= orders.size()%></h4>
                                <p class="mb-0">Total Orders</p>
                            </div>
                            <i class="fas fa-shopping-bag fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="farmer-stats-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="pendingOrders"><%= pendingCount%></h4>
                                <p class="mb-0">Pending</p>
                            </div>
                            <i class="fas fa-clock fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="farmer-stats-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="paidOrders"><%= paidCount%></h4>
                                <p class="mb-0">Paid</p>
                            </div>
                            <i class="fas fa-check-circle fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="farmer-stats-card p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="deliveredOrders"><%= deliveredCount%></h4>
                                <p class="mb-0">Delivered</p>
                            </div>
                            <i class="fas fa-truck fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Orders Section -->
            <div class="row">
                <div class="col-12">
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-receipt me-2"></i>Orders for Your Products
                                <span class="badge bg-success ms-2" id="ordersCount"><%= orders.size()%> orders</span>
                            </h5>
                        </div>
                        <div class="card-body">
                            <% if (orders.isEmpty()) { %>
                            <div class="text-center py-5">
                                <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No orders yet</h5>
                                <p class="text-muted">Your products haven't received any orders yet</p>
                                <a href="product_management.jsp" class="btn btn-success mt-2">
                                    <i class="fas fa-plus me-2"></i>Add Products
                                </a>
                            </div>
                            <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Product</th>
                                            <th>Customer</th>
                                            <th>Quantity</th>
                                            <th>Price</th>
                                            <th>Total</th>
                                            <th>Status</th>
                                            <th>Date</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ordersTableBody">
                                        <% for (Map<String, Object> order : orders) {
                                                Timestamp orderDate = (Timestamp) order.get("created_at");
                                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                                                String phoneNumber = order.get("phone_number") != null ? order.get("phone_number").toString() : "";
                                        %>
                                        <tr id="orderRow_<%= order.get("order_id")%>">
                                            <td>
                                                <strong>#<%= order.get("order_id")%></strong>
                                            </td>
                                            <td>
                                                <strong><%= order.get("product_name")%></strong>
                                                <br>
                                                <small class="text-muted">ID: <%= order.get("product_id")%></small>
                                            </td>
                                            <td>
                                                <strong><%= order.get("customer_name")%></strong>
                                                <br>
                                                <small class="text-muted"><%= order.get("customer_email")%></small>
                                                <br>
                                                <small class="text-muted"><%= phoneNumber%></small>
                                            </td>
                                            <td>
                                                <%= order.get("item_quantity")%>
                                            </td>
                                            <td>
                                                M <%= String.format("%.2f", order.get("item_price"))%>
                                            </td>
                                            <td>
                                                <strong>M <%= String.format("%.2f", order.get("total_amount"))%></strong>
                                            </td>
                                            <td>
                                                <span class="badge status-<%= order.get("status")%>" id="status_<%= order.get("order_id")%>">
                                                    <%= order.get("status")%>
                                                </span>
                                            </td>
                                            <td>
                                                <small class="text-muted">
                                                    <%= sdf.format(orderDate)%>
                                                </small>
                                            </td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <button class="btn btn-outline-primary view-order-details" 
                                                            data-order-id="<%= order.get("order_id")%>">
                                                        <i class="fas fa-eye"></i> View
                                                    </button>
                                                    <% if ("PENDING".equals(order.get("status"))) {%>
                                                    <button class="btn btn-outline-success update-status"
                                                            data-order-id="<%= order.get("order_id")%>"
                                                            data-new-status="PAID"
                                                            data-customer-email="<%= order.get("customer_email")%>"
                                                            data-customer-phone="<%= phoneNumber%>"
                                                            data-customer-name="<%= order.get("customer_name")%>">
                                                        <i class="fas fa-check"></i> Mark Paid
                                                    </button>
                                                    <% } else if ("PAID".equals(order.get("status"))) {%>
                                                    <button class="btn btn-outline-info update-status"
                                                            data-order-id="<%= order.get("order_id")%>"
                                                            data-new-status="DELIVERED"
                                                            data-customer-email="<%= order.get("customer_email")%>"
                                                            data-customer-phone="<%= phoneNumber%>"
                                                            data-customer-name="<%= order.get("customer_name")%>">
                                                        <i class="fas fa-truck"></i> Mark Delivered
                                                    </button>
                                                    <% } else { %>
                                                    <button class="btn btn-outline-secondary" disabled>
                                                        <i class="fas fa-check-double"></i> Completed
                                                    </button>
                                                    <% }%>
                                                    <button class="btn btn-outline-warning contact-customer"
                                                            data-customer-email="<%= order.get("customer_email")%>"
                                                            data-customer-phone="<%= phoneNumber%>"
                                                            data-customer-name="<%= order.get("customer_name")%>">
                                                        <i class="fas fa-envelope"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% }%>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Order Details Modal -->
        <div class="modal fade" id="orderDetailsModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">Order Details - #<span id="modalOrderId"></span></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="orderDetailsContent">
                        <!-- Order details will be loaded here via AJAX -->
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            // Sidebar toggle for mobile
            document.getElementById('sidebarToggle').addEventListener('click', function () {
                document.getElementById('sidebar').classList.toggle('show');
            });

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', function (e) {
                if (window.innerWidth <= 768) {
                    var sidebar = document.getElementById('sidebar');
                    var toggle = document.getElementById('sidebarToggle');
                    if (!sidebar.contains(e.target) && e.target !== toggle) {
                        sidebar.classList.remove('show');
                    }
                }
            });

            // View order details
            document.addEventListener('click', function (e) {
                if (e.target.closest('.view-order-details')) {
                    var button = e.target.closest('.view-order-details');
                    var orderId = button.getAttribute('data-order-id');
                    document.getElementById('modalOrderId').textContent = orderId;

                    // Show loading
                    document.getElementById('orderDetailsContent').innerHTML =
                            '<div class="text-center py-4">' +
                            '<div class="spinner-border text-success" role="status">' +
                            '<span class="visually-hidden">Loading...</span>' +
                            '</div>' +
                            '<p class="mt-2">Loading order details...</p>' +
                            '</div>';

                    // Load order details via AJAX
                    fetch('FarmerOrderDetailsServlet?orderId=' + orderId)
                            .then(function (response) {
                                return response.text();
                            })
                            .then(function (data) {
                                document.getElementById('orderDetailsContent').innerHTML = data;
                            })
                            .catch(function (error) {
                                document.getElementById('orderDetailsContent').innerHTML =
                                        '<div class="alert alert-danger">' +
                                        '<i class="fas fa-exclamation-triangle me-2"></i>' +
                                        'Failed to load order details. Please try again.' +
                                        '</div>';
                            });

                    var modal = new bootstrap.Modal(document.getElementById('orderDetailsModal'));
                    modal.show();
                }
            });

            // Update order status - FIXED VERSION
            document.addEventListener('click', function (e) {
                if (e.target.closest('.update-status')) {
                    var button = e.target.closest('.update-status');
                    var orderId = button.getAttribute('data-order-id');
                    var newStatus = button.getAttribute('data-new-status');
                    var customerEmail = button.getAttribute('data-customer-email');
                    var customerPhone = button.getAttribute('data-customer-phone');
                    var customerName = button.getAttribute('data-customer-name');

                    if (confirm('Are you sure you want to update order #' + orderId + ' status to ' + newStatus + '?')) {
                        button.disabled = true;
                        button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';

                        // Use URL parameters instead of FormData
                        var params = 'orderId=' + encodeURIComponent(orderId) + '&newStatus=' + encodeURIComponent(newStatus);

                        fetch('UpdateOrderStatusServlet', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                            },
                            body: params
                        })
                                .then(function (response) {
                                    return response.json();
                                })
                                .then(function (data) {
                                    if (data.success) {
                                        // Update the status badge
                                        var statusBadge = document.getElementById('status_' + orderId);
                                        statusBadge.className = 'badge status-' + newStatus;
                                        statusBadge.textContent = newStatus;

                                        // Update the button based on new status
                                        var buttonGroup = button.closest('.btn-group');
                                        if (newStatus === 'PAID') {
                                            buttonGroup.innerHTML =
                                                    '<button class="btn btn-outline-primary view-order-details" data-order-id="' + orderId + '">' +
                                                    '<i class="fas fa-eye"></i> View' +
                                                    '</button>' +
                                                    '<button class="btn btn-outline-info update-status" data-order-id="' + orderId + '" data-new-status="DELIVERED" data-customer-email="' + customerEmail + '" data-customer-phone="' + customerPhone + '" data-customer-name="' + customerName + '">' +
                                                    '<i class="fas fa-truck"></i> Mark Delivered' +
                                                    '</button>' +
                                                    '<button class="btn btn-outline-warning contact-customer" data-customer-email="' + customerEmail + '" data-customer-phone="' + customerPhone + '" data-customer-name="' + customerName + '">' +
                                                    '<i class="fas fa-envelope"></i>' +
                                                    '</button>';
                                        } else if (newStatus === 'DELIVERED') {
                                            buttonGroup.innerHTML =
                                                    '<button class="btn btn-outline-primary view-order-details" data-order-id="' + orderId + '">' +
                                                    '<i class="fas fa-eye"></i> View' +
                                                    '</button>' +
                                                    '<button class="btn btn-outline-secondary" disabled>' +
                                                    '<i class="fas fa-check-double"></i> Completed' +
                                                    '</button>' +
                                                    '<button class="btn btn-outline-warning contact-customer" data-customer-email="' + customerEmail + '" data-customer-phone="' + customerPhone + '" data-customer-name="' + customerName + '">' +
                                                    '<i class="fas fa-envelope"></i>' +
                                                    '</button>';
                                        }

                                        // Update statistics
                                        updateStatistics();
                                        showNotification('Order status updated successfully!', 'success');
                                    } else {
                                        showNotification('Failed to update status: ' + data.message, 'error');
                                        button.disabled = false;
                                        button.innerHTML = '<i class="fas fa-check"></i> ' + (newStatus === 'PAID' ? 'Mark Paid' : 'Mark Delivered');
                                    }
                                })
                                .catch(function (error) {
                                    showNotification('Error updating status. Please try again.', 'error');
                                    button.disabled = false;
                                    button.innerHTML = '<i class="fas fa-check"></i> ' + (newStatus === 'PAID' ? 'Mark Paid' : 'Mark Delivered');
                                });
                    }
                }
            });

            // Contact customer
            document.addEventListener('click', function (e) {
                if (e.target.closest('.contact-customer')) {
                    var button = e.target.closest('.contact-customer');
                    var email = button.getAttribute('data-customer-email');
                    var phone = button.getAttribute('data-customer-phone');
                    var name = button.getAttribute('data-customer-name');

                    var contactHtml =
                            '<div class="contact-info">' +
                            '<h6><i class="fas fa-user me-2"></i>' + name + '</h6>' +
                            '<p><i class="fas fa-envelope me-2"></i><a href="mailto:' + email + '">' + email + '</a></p>';

                    if (phone && phone !== '') {
                        contactHtml += '<p><i class="fas fa-phone me-2"></i><a href="tel:' + phone + '">' + phone + '</a></p>';
                    }

                    contactHtml +=
                            '<div class="mt-3">' +
                            '<button class="btn btn-success btn-sm me-2" onclick="window.location.href=\'mailto:' + email + '\'">' +
                            '<i class="fas fa-envelope me-1"></i>Send Email' +
                            '</button>';

                    if (phone && phone !== '') {
                        contactHtml +=
                                '<button class="btn btn-primary btn-sm" onclick="window.location.href=\'tel:' + phone + '\'">' +
                                '<i class="fas fa-phone me-1"></i>Call Customer' +
                                '</button>';
                    }

                    contactHtml += '</div></div>';

                    document.getElementById('orderDetailsContent').innerHTML = contactHtml;
                    document.getElementById('modalOrderId').textContent = 'Contact Customer';
                    var modal = new bootstrap.Modal(document.getElementById('orderDetailsModal'));
                    modal.show();
                }
            });

            // Update statistics function
            function updateStatistics() {
                var pendingCount = document.querySelectorAll('.status-PENDING').length;
                var paidCount = document.querySelectorAll('.status-PAID').length;
                var deliveredCount = document.querySelectorAll('.status-DELIVERED').length;
                var totalCount = document.querySelectorAll('#ordersTableBody tr').length;

                document.getElementById('pendingOrders').textContent = pendingCount;
                document.getElementById('paidOrders').textContent = paidCount;
                document.getElementById('deliveredOrders').textContent = deliveredCount;
                document.getElementById('totalOrders').textContent = totalCount;
                document.getElementById('ordersCount').textContent = totalCount + ' orders';
            }

            // Notification function
            function showNotification(message, type) {
                // Remove existing notifications
                var existingNotifications = document.querySelectorAll('.notification');
                existingNotifications.forEach(function (notification) {
                    notification.remove();
                });

                var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
                var notification = document.createElement('div');
                notification.className = 'alert ' + alertClass + ' alert-dismissible fade show notification';
                notification.innerHTML =
                        message +
                        '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';

                document.body.appendChild(notification);

                // Auto remove after 5 seconds
                setTimeout(function () {
                    if (notification.parentNode) {
                        notification.remove();
                    }
                }, 5000);
            }
        </script>
    </body>
</html>