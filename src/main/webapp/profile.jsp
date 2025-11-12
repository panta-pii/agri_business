<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User"%>
<%@page import="java.sql.*, java.util.*"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    if (user == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }

    // Database connection for stats
    int ordersCount = 0;
    int productsCount = 0;
    int messagesCount = 0;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_business", "root", "");

        // Get orders count
        if ("FARMER".equals(user.getRole())) {
            // For farmers: count orders received
            String ordersSql = "SELECT COUNT(*) as count FROM orders o " +
                             "JOIN products p ON o.product_id = p.id " +
                             "WHERE p.user_id = ?";
            pstmt = conn.prepareStatement(ordersSql);
            pstmt.setInt(1, user.getId());
        } else {
            // For buyers: count orders placed
            String ordersSql = "SELECT COUNT(*) as count FROM orders WHERE user_id = ?";
            pstmt = conn.prepareStatement(ordersSql);
            pstmt.setInt(1, user.getId());
        }
        rs = pstmt.executeQuery();
        if (rs.next()) {
            ordersCount = rs.getInt("count");
        }
        rs.close();
        pstmt.close();

        // Get products count
        if ("FARMER".equals(user.getRole())) {
            // For farmers: count products listed
            String productsSql = "SELECT COUNT(*) as count FROM products WHERE user_id = ?";
            pstmt = conn.prepareStatement(productsSql);
            pstmt.setInt(1, user.getId());
            rs = pstmt.executeQuery();
            if (rs.next()) {
                productsCount = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
        } else {
            // For buyers: count products bought
            String productsSql = "SELECT COUNT(DISTINCT oi.product_id) as count " +
                               "FROM orders o " +
                               "JOIN order_items oi ON o.id = oi.order_id " +
                               "WHERE o.user_id = ?";
            pstmt = conn.prepareStatement(productsSql);
            pstmt.setInt(1, user.getId());
            rs = pstmt.executeQuery();
            if (rs.next()) {
                productsCount = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
        }

        // Get unread messages count
        String messagesSql = "SELECT COUNT(*) as count FROM messages m " +
                           "LEFT JOIN message_read_receipts mrr ON m.id = mrr.message_id AND mrr.user_id = ? " +
                           "WHERE mrr.id IS NULL AND m.sender_id != ?";
        pstmt = conn.prepareStatement(messagesSql);
        pstmt.setInt(1, user.getId());
        pstmt.setInt(2, user.getId());
        rs = pstmt.executeQuery();
        if (rs.next()) {
            messagesCount = rs.getInt("count");
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - AgriYouth Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #28a745;
            --primary-dark: #218838;
        }
        
        .profile-header {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            padding: 40px 0;
            margin-bottom: 30px;
        }
        
        .profile-picture {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid white;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .profile-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 5px 25px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .profile-card .card-header {
            background: white;
            border-bottom: 3px solid var(--primary-color);
            font-weight: 600;
            color: var(--primary-dark);
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 3px 15px rgba(0,0,0,0.08);
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .nav-pills .nav-link.active {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .nav-pills .nav-link {
            color: var(--primary-color);
        }
        
        .btn-success {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-success:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .profile-section {
            display: none;
        }
        
        .profile-section.active {
            display: block;
        }
        
        .verification-badge {
            background: #28a745;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .stats-row {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-leaf"></i> AgriYouth Marketplace
            </a>
            <div class="navbar-nav ms-auto">
                <a class="btn btn-outline-light nav-button" href="index.jsp">
                    <i class="fas fa-home"></i> Home
                </a>
                <a class="btn btn-light nav-button" href="profile.jsp">
                    <i class="fas fa-user"></i> Profile
                </a>
                <a class="btn btn-outline-light nav-button" href="LogoutServlet">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Profile Header -->
    <div class="profile-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-auto">
                    <img id="profilePicture" src="ProfilePhotoServlet?id=<%= user.getId() %>" 
                         class="profile-picture" alt="Profile Picture"
                         onerror="this.src='https://ui-avatars.com/api/?name=<%= user.getFirstName() + "+" + user.getLastName() %>&size=150&background=28a745&color=ffffff'">
                </div>
                <div class="col">
                    <h1 class="display-5 fw-bold"><%= user.getFirstName() %> <%= user.getLastName() %></h1>
                    <p class="lead mb-2">
                        <i class="fas fa-envelope me-2"></i><%= user.getEmail() %>
                        <% if(user.getPhoneNumber() != null && !user.getPhoneNumber().isEmpty()) { %>
                            <span class="ms-3"><i class="fas fa-phone me-2"></i><%= user.getPhoneNumber() %></span>
                        <% } %>
                    </p>
                    <div class="d-flex align-items-center">
                        <span class="badge bg-light text-dark me-2">
                            <i class="fas fa-user-tag me-1"></i><%= user.getRole() %>
                        </span>
                        <% if(user.isVerified()) { %>
                            <span class="verification-badge">
                                <i class="fas fa-check-circle me-1"></i>Verified
                            </span>
                        <% } else { %>
                            <span class="badge bg-warning text-dark">
                                <i class="fas fa-clock me-1"></i>Not Verified
                            </span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container mb-5">
        <div class="row">
            <!-- Sidebar Navigation -->
            <div class="col-md-3">
                <div class="profile-card">
                    <div class="card-body">
                        <ul class="nav nav-pills flex-column" id="profileTabs" role="tablist">
                            <li class="nav-item">
                                <a class="nav-link active" href="#" data-section="personal">
                                    <i class="fas fa-user me-2"></i>Personal Info
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#" data-section="security">
                                    <i class="fas fa-shield-alt me-2"></i>Security
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#" data-section="preferences">
                                    <i class="fas fa-cog me-2"></i>Preferences
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-danger" href="#" data-section="danger">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Danger Zone
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Quick Stats -->
                <div class="profile-card">
                    <div class="card-header">
                        <i class="fas fa-chart-bar me-2"></i>Quick Stats
                    </div>
                    <div class="card-body">
                        <div class="stats-row">
                            <div class="stat-card">
                                <div class="stat-number" id="ordersCount"><%= ordersCount %></div>
                                <div class="stat-label">
                                    <%= user.getRole().equals("FARMER") ? "Orders Received" : "My Orders" %>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number" id="productsCount"><%= productsCount %></div>
                                <div class="stat-label">
                                    <%= user.getRole().equals("FARMER") ? "Products Listed" : "Products Bought" %>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number" id="messagesCount"><%= messagesCount %></div>
                                <div class="stat-label">Unread Messages</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Profile Content -->
            <div class="col-md-9">
                <!-- Personal Information Section -->
                <div class="profile-section active" id="personalSection">
                    <div class="profile-card">
                        <div class="card-header">
                            <i class="fas fa-user-edit me-2"></i>Personal Information
                        </div>
                        <div class="card-body">
                            <form id="personalInfoForm">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">First Name *</label>
                                        <input type="text" class="form-control" name="firstName" 
                                               value="<%= user.getFirstName() %>" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Last Name *</label>
                                        <input type="text" class="form-control" name="lastName" 
                                               value="<%= user.getLastName() %>" required>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Email Address *</label>
                                        <input type="email" class="form-control" name="email" 
                                               value="<%= user.getEmail() %>" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Phone Number</label>
                                        <input type="tel" class="form-control" name="phoneNumber" 
                                               value="<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Location</label>
                                    <input type="text" class="form-control" name="location" 
                                           value="<%= user.getLocation() != null ? user.getLocation() : "" %>"
                                           placeholder="Enter your location">
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Bio</label>
                                    <textarea class="form-control" name="bio" rows="4" 
                                              placeholder="Tell us about yourself..."><%= user.getBio() != null ? user.getBio() : "" %></textarea>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Profile Picture</label>
                                    <input type="file" class="form-control" id="profilePhotoInput" 
                                           accept="image/*">
                                    <div class="form-text">Max file size: 2MB. Supported formats: JPG, PNG, GIF</div>
                                </div>
                                
                                <div class="d-flex justify-content-between">
                                    <button type="button" class="btn btn-outline-secondary" onclick="resetPersonalForm()">
                                        <i class="fas fa-undo me-2"></i>Reset
                                    </button>
                                    <button type="submit" class="btn btn-success">
                                        <i class="fas fa-save me-2"></i>Save Changes
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Security Section -->
                <div class="profile-section" id="securitySection">
                    <div class="profile-card">
                        <div class="card-header">
                            <i class="fas fa-shield-alt me-2"></i>Security Settings
                        </div>
                        <div class="card-body">
                            <form id="changePasswordForm">
                                <h6 class="mb-3">Change Password</h6>
                                <div class="mb-3">
                                    <label class="form-label">Current Password *</label>
                                    <input type="password" class="form-control" name="currentPassword" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">New Password *</label>
                                    <input type="password" class="form-control" name="newPassword" required>
                                    <div class="form-text">Password must be at least 6 characters long</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Confirm New Password *</label>
                                    <input type="password" class="form-control" name="confirmPassword" required>
                                </div>
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-key me-2"></i>Change Password
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Preferences Section -->
                <div class="profile-section" id="preferencesSection">
                    <div class="profile-card">
                        <div class="card-header">
                            <i class="fas fa-cog me-2"></i>Preferences
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle me-2"></i>
                                Preferences settings will be available soon.
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Danger Zone Section -->
                <div class="profile-section" id="dangerSection">
                    <div class="profile-card border-danger">
                        <div class="card-header bg-danger text-white">
                            <i class="fas fa-exclamation-triangle me-2"></i>Danger Zone
                        </div>
                        <div class="card-body">
                            <div class="alert alert-warning">
                                <h6><i class="fas fa-exclamation-circle me-2"></i>Warning</h6>
                                <p class="mb-2">These actions are irreversible. Please proceed with caution.</p>
                            </div>
                            
                            <div class="border rounded p-3 mb-3">
                                <h6 class="text-danger">Delete Account</h6>
                                <p class="text-muted small mb-3">
                                    Once you delete your account, there is no going back. All your data will be permanently removed.
                                </p>
                                <button class="btn btn-outline-danger btn-sm" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">
                                    <i class="fas fa-trash me-2"></i>Delete My Account
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Account Modal -->
    <div class="modal fade" id="deleteAccountModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle me-2"></i>Delete Account
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-danger">
                        <h6>This action cannot be undone!</h6>
                        <p class="mb-0">All your data, including orders, products, and messages will be permanently deleted.</p>
                    </div>
                    <form id="deleteAccountForm">
                        <div class="mb-3">
                            <label class="form-label">Enter your password to confirm:</label>
                            <input type="password" class="form-control" name="password" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                        <i class="fas fa-trash me-2"></i>Delete Account
                    </button>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5 text-center">
        <p class="mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
    </footer>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Tab navigation
        $('#profileTabs .nav-link').click(function(e) {
            e.preventDefault();
            const section = $(this).data('section');
            
            // Update active tab
            $('#profileTabs .nav-link').removeClass('active');
            $(this).addClass('active');
            
            // Show corresponding section
            $('.profile-section').removeClass('active');
            $('#' + section + 'Section').addClass('active');
        });

        // Personal Info Form
        $('#personalInfoForm').on('submit', function(e) {
            e.preventDefault();
            updatePersonalInfo();
        });

        // Profile Photo Upload
        $('#profilePhotoInput').change(function() {
            if (this.files.length > 0) {
                uploadProfilePhoto();
            }
        });

        // Change Password Form
        $('#changePasswordForm').on('submit', function(e) {
            e.preventDefault();
            changePassword();
        });

        // Delete Account
        $('#confirmDeleteBtn').click(function() {
            deleteAccount();
        });

        function updatePersonalInfo() {
            const formData = new FormData($('#personalInfoForm')[0]);
            formData.append('action', 'update');
            
            $.ajax({
                url: 'ProfileServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    try {
                        const result = JSON.parse(response);
                        if (result.success) {
                            showAlert('Profile updated successfully!', 'success');
                            // Update profile picture if it changed
                            if (result.profilePictureUrl) {
                                $('#profilePicture').attr('src', result.profilePictureUrl + '&t=' + new Date().getTime());
                            }
                        } else {
                            showAlert(result.message || 'Error updating profile', 'error');
                        }
                    } catch (e) {
                        showAlert('Error parsing response', 'error');
                    }
                },
                error: function() {
                    showAlert('Error updating profile', 'error');
                }
            });
        }

        function uploadProfilePhoto() {
            const fileInput = $('#profilePhotoInput')[0];
            if (!fileInput.files.length) return;
            
            const formData = new FormData();
            formData.append('action', 'uploadPhoto');
            formData.append('profilePhoto', fileInput.files[0]);
            
            $.ajax({
                url: 'ProfileServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    try {
                        const result = JSON.parse(response);
                        if (result.success) {
                            showAlert('Profile photo updated successfully!', 'success');
                            // Refresh profile picture
                            $('#profilePicture').attr('src', 'ProfilePhotoServlet?id=<%= user.getId() %>&t=' + new Date().getTime());
                            $('#profilePhotoInput').val('');
                        } else {
                            showAlert(result.message || 'Error uploading photo', 'error');
                        }
                    } catch (e) {
                        showAlert('Error parsing response', 'error');
                    }
                },
                error: function() {
                    showAlert('Error uploading profile photo', 'error');
                }
            });
        }

        function changePassword() {
            const formData = new FormData($('#changePasswordForm')[0]);
            formData.append('action', 'changePassword');
            
            $.ajax({
                url: 'ProfileServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    try {
                        const result = JSON.parse(response);
                        if (result.success) {
                            showAlert('Password changed successfully!', 'success');
                            $('#changePasswordForm')[0].reset();
                        } else {
                            showAlert(result.message || 'Error changing password', 'error');
                        }
                    } catch (e) {
                        showAlert('Error parsing response', 'error');
                    }
                },
                error: function() {
                    showAlert('Error changing password', 'error');
                }
            });
        }

        function deleteAccount() {
            const formData = new FormData($('#deleteAccountForm')[0]);
            formData.append('action', 'deleteAccount');
            
            $.ajax({
                url: 'ProfileServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    try {
                        const result = JSON.parse(response);
                        if (result.success) {
                            window.location.href = 'index.jsp?message=account_deleted';
                        } else {
                            showAlert(result.message || 'Error deleting account', 'error');
                            $('#deleteAccountModal').modal('hide');
                        }
                    } catch (e) {
                        showAlert('Error parsing response', 'error');
                        $('#deleteAccountModal').modal('hide');
                    }
                },
                error: function() {
                    showAlert('Error deleting account', 'error');
                    $('#deleteAccountModal').modal('hide');
                }
            });
        }

        function resetPersonalForm() {
            // Reset form to original values
            $('input[name="firstName"]').val('<%= user.getFirstName() %>');
            $('input[name="lastName"]').val('<%= user.getLastName() %>');
            $('input[name="email"]').val('<%= user.getEmail() %>');
            $('input[name="phoneNumber"]').val('<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>');
            $('input[name="location"]').val('<%= user.getLocation() != null ? user.getLocation() : "" %>');
            $('textarea[name="bio"]').val('<%= user.getBio() != null ? user.getBio() : "" %>');
            showAlert('Form reset to original values', 'info');
        }

        function showAlert(message, type) {
            const alertClass = type === 'success' ? 'alert-success' : 
                             type === 'error' ? 'alert-danger' : 'alert-info';
            
            const alertHtml = `
                <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            
            // Remove existing alerts
            $('.alert-dismissible').remove();
            
            // Add new alert at the top of the main content
            $('.col-md-9').prepend(alertHtml);
            
            // Auto remove after 5 seconds
            setTimeout(() => {
                $('.alert-dismissible').alert('close');
            }, 5000);
        }

        // Refresh stats periodically
        function refreshStats() {
            // You can implement AJAX call here to refresh stats without page reload
            // For now, we'll just show the server-side calculated stats
            console.log('Stats refreshed');
        }

        // Initialize
        $(document).ready(function() {
            // Stats are already loaded server-side
            console.log('Profile page loaded with stats:', {
                orders: <%= ordersCount %>,
                products: <%= productsCount %>,
                messages: <%= messagesCount %>
            });
        });
    </script>
</body>
</html>