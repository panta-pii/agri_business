<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="java.sql.*, java.util.*"%>
<%
    HttpSession sessionObj = request.getSession(false);
    String userName = (sessionObj != null) ? (String) sessionObj.getAttribute("userName") : null;
    String userEmail = (sessionObj != null) ? (String) sessionObj.getAttribute("userEmail") : null;
    Integer userId = (sessionObj != null) ? (Integer) sessionObj.getAttribute("userId") : null;
    
    if (userName == null || userId == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }

    // Database connection for buyer's orders with order items
    List<Map<String, Object>> orders = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

        // Updated SQL to include order items count
        String sql = "SELECT o.id AS order_id, o.created_at, o.total_amount, o.status, " +
                     "o.delivery_address, o.payment_method, o.phone_number, " +
                     "COUNT(oi.id) as item_count " +
                     "FROM orders o " +
                     "LEFT JOIN order_items oi ON o.id = oi.order_id " +
                     "WHERE o.user_id = ? " +
                     "GROUP BY o.id " +
                     "ORDER BY o.created_at DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> order = new HashMap<>();
            order.put("order_id", rs.getInt("order_id"));
            order.put("order_date", rs.getTimestamp("created_at"));
            order.put("total_amount", rs.getDouble("total_amount"));
            order.put("status", rs.getString("status"));
            order.put("delivery_address", rs.getString("delivery_address"));
            order.put("payment_method", rs.getString("payment_method"));
            order.put("phone_number", rs.getString("phone_number"));
            order.put("item_count", rs.getInt("item_count"));
            orders.add(order);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    // Calculate stats
    int pendingCount = 0;
    int paidCount = 0;
    int deliveredCount = 0;
    
    for (Map<String, Object> order : orders) {
        String status = (String) order.get("status");
        switch (status) {
            case "PENDING": pendingCount++; break;
            case "PAID": paidCount++; break;
            case "DELIVERED": deliveredCount++; break;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - AgriYouth Marketplace</title>
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
        .status-PENDING { background-color: #fff3cd; color: #856404; }
        .status-PAID { background-color: #d1ecf1; color: #0c5460; }
        .status-DELIVERED { background-color: #d4edda; color: #155724; }
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
        .tracking-progress {
            height: 8px;
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
        }
        .tracking-progress-bar {
            height: 100%;
            background-color: #28a745;
            transition: width 0.3s ease;
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
                <i class="fas fa-user-circle me-2"></i>
                <%= userName %>
            </h5>
            <small class="text-white-50"><%= userEmail %></small>
        </div>

        <nav class="nav flex-column mt-3">
            <a class="nav-link" href="index.jsp"><i class="fas fa-home me-2"></i> Home</a>
            <a class="nav-link" href="profile.jsp"><i class="fas fa-user me-2"></i> My Profile</a>
            <a class="nav-link" href="messages.jsp"><i class="fas fa-comments me-2"></i> Messages</a>
            <a class="nav-link active" href="user_dashboard.jsp"><i class="fas fa-shopping-bag me-2"></i> My Orders</a>
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
            <button class="btn btn-success" id="sidebarToggle"><i class="fas fa-bars"></i></button>
            <h5 class="mb-0 text-success">My Dashboard</h5>
            <div></div>
        </div>

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="text-success mb-1"><i class="fas fa-shopping-bag me-2"></i>My Orders</h2>
                <p class="text-muted mb-0">Manage and track your purchases</p>
            </div>
            <a href="index.jsp" class="btn btn-success"><i class="fas fa-plus me-2"></i>Continue Shopping</a>
        </div>

        <!-- Quick Stats -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="pendingCount"><%= pendingCount %></h4>
                                <p class="mb-0">Pending</p>
                            </div>
                            <i class="fas fa-clock fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="paidCount"><%= paidCount %></h4>
                                <p class="mb-0">Paid</p>
                            </div>
                            <i class="fas fa-check-circle fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="deliveredCount"><%= deliveredCount %></h4>
                                <p class="mb-0">Delivered</p>
                            </div>
                            <i class="fas fa-truck fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 id="totalCount"><%= orders.size() %></h4>
                                <p class="mb-0">Total Orders</p>
                            </div>
                            <i class="fas fa-shopping-bag fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Orders Table -->
        <div class="row">
            <div class="col-12">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="fas fa-receipt me-2"></i>Order History
                            <span class="badge bg-success ms-2" id="ordersCount"><%= orders.size() %> orders</span>
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (orders.isEmpty()) { %>
                            <div class="text-center py-5">
                                <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No orders yet</h5>
                                <p class="text-muted">Start shopping to see your orders here</p>
                                <a href="index.jsp" class="btn btn-success mt-2">
                                    <i class="fas fa-shopping-cart me-2"></i>Start Shopping
                                </a>
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Date</th>
                                            <th>Items</th>
                                            <th>Total</th>
                                            <th>Status</th>
                                            <th>Payment</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ordersTableBody">
                                        <% for (Map<String, Object> order : orders) { 
                                            Timestamp orderDate = (Timestamp) order.get("order_date");
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy");
                                        %>
                                            <tr id="orderRow_<%= order.get("order_id") %>">
                                                <td><strong>#<%= order.get("order_id") %></strong></td>
                                                <td><%= sdf.format(orderDate) %></td>
                                                <td><span class="badge bg-secondary"><%= order.get("item_count") %> item(s)</span></td>
                                                <td><strong>M <%= String.format("%.2f", order.get("total_amount")) %></strong></td>
                                                <td>
                                                    <span class="badge status-<%= order.get("status") %>">
                                                        <%= order.get("status") %>
                                                    </span>
                                                </td>
                                                <td><small class="text-muted"><%= order.get("payment_method") %></small></td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <button class="btn btn-outline-primary view-order" data-order-id="<%= order.get("order_id") %>">
                                                            <i class="fas fa-eye"></i> View
                                                        </button>
                                                        <button class="btn btn-outline-success track-order" data-order-id="<%= order.get("order_id") %>">
                                                            <i class="fas fa-truck"></i> Track
                                                        </button>
                                                        <% if ("PENDING".equals(order.get("status"))) { %>
                                                            <button class="btn btn-outline-danger cancel-order" data-order-id="<%= order.get("order_id") %>">
                                                                <i class="fas fa-times"></i> Cancel
                                                            </button>
                                                        <% } %>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
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
                    <!-- Content will be loaded via AJAX -->
                </div>
            </div>
        </div>
    </div>

    <!-- Tracking Modal -->
    <div class="modal fade" id="trackingModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title">Order Tracking - #<span id="trackingOrderId"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="trackingContent">
                    <!-- Tracking content will be loaded via AJAX -->
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sidebar toggle
        $('#sidebarToggle').click(function() { 
            $('#sidebar').toggleClass('show'); 
        });

        $(document).click(function(e) {
            if ($(window).width() <= 768 && !$(e.target).closest('#sidebar').length && !$(e.target).is('#sidebarToggle')) {
                $('#sidebar').removeClass('show');
            }
        });

        // View Order Details
        $(document).on('click', '.view-order', function() {
            const orderId = $(this).data('order-id');
            $('#modalOrderId').text(orderId);
            $('#orderDetailsContent').html('<div class="text-center py-4"><div class="spinner-border text-success"></div><p class="mt-2">Loading order details...</p></div>');
            
            $.get('OrderDetailsServlet', { orderId: orderId })
                .done(function(data) {
                    $('#orderDetailsContent').html(data);
                })
                .fail(function() {
                    $('#orderDetailsContent').html('<div class="alert alert-danger">Failed to load order details. Please try again.</div>');
                });
            
            $('#orderDetailsModal').modal('show');
        });

        // Track Order
        $(document).on('click', '.track-order', function() {
            const orderId = $(this).data('order-id');
            $('#trackingOrderId').text(orderId);
            $('#trackingContent').html('<div class="text-center py-4"><div class="spinner-border text-info"></div><p class="mt-2">Loading tracking information...</p></div>');
            
            $.get('OrderTrackingServlet', { orderId: orderId })
                .done(function(data) {
                    $('#trackingContent').html(data);
                })
                .fail(function() {
                    $('#trackingContent').html('<div class="alert alert-danger">Failed to load tracking information. Please try again.</div>');
                });
            
            $('#trackingModal').modal('show');
        });

        // Cancel Order
        $(document).on('click', '.cancel-order', function() {
            const orderId = $(this).data('order-id');
            const orderRow = $('#orderRow_' + orderId);
            
            if (confirm('Are you sure you want to cancel order #' + orderId + '? This order will be permanently removed.')) {
                const btn = $(this);
                btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Cancelling...');
                
                $.post('CancelOrderServlet', { orderId: orderId })
                    .done(function(response) {
                        if (response.success) {
                            // Remove the row from the table with animation
                            orderRow.fadeOut(300, function() {
                                $(this).remove();
                                updateDashboardStats();
                            });
                            
                            showNotification('Order cancelled successfully!', 'success');
                        } else {
                            showNotification('Failed to cancel order: ' + response.message, 'error');
                            btn.prop('disabled', false).html('<i class="fas fa-times"></i> Cancel');
                        }
                    })
                    .fail(function() {
                        showNotification('Error cancelling order. Please try again.', 'error');
                        btn.prop('disabled', false).html('<i class="fas fa-times"></i> Cancel');
                    });
            }
        });

        // Update dashboard statistics after order cancellation
        function updateDashboardStats() {
            const remainingOrders = $('#ordersTableBody tr').length;
            
            // Update orders count
            $('#ordersCount').text(remainingOrders + ' orders');
            $('#totalCount').text(remainingOrders);
            
            // Recalculate status counts
            const pendingCount = $('.status-PENDING').length;
            const paidCount = $('.status-PAID').length;
            const deliveredCount = $('.status-DELIVERED').length;
            
            $('#pendingCount').text(pendingCount);
            $('#paidCount').text(paidCount);
            $('#deliveredCount').text(deliveredCount);
            
            // Show message if no orders left
            if (remainingOrders === 0) {
                $('#ordersTableBody').html(`
                    <tr>
                        <td colspan="7" class="text-center py-5">
                            <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">No orders yet</h5>
                            <p class="text-muted">Start shopping to see your orders here</p>
                            <a href="index.jsp" class="btn btn-success mt-2">
                                <i class="fas fa-shopping-cart me-2"></i>Start Shopping
                            </a>
                        </td>
                    </tr>
                `);
            }
        }

        // Notification function
        function showNotification(message, type) {
            // Remove existing notifications
            $('.notification').remove();
            
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            const notification = $(`
                <div class="alert ${alertClass} alert-dismissible fade show notification">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `);
            $('body').append(notification);
            
            // Auto remove after 5 seconds
            setTimeout(function() {
                notification.alert('close');
            }, 5000);
        }

        // Initialize tooltips
        $(function () {
            $('[data-bs-toggle="tooltip"]').tooltip();
        });
    </script>
</body>
</html>