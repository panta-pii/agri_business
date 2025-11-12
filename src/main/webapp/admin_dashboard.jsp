<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("index.jsp?error=access_denied");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --danger-color: #dc3545;
                --warning-color: #ffc107;
                --info-color: #17a2b8;
                --success-color: #28a745;
            }

            .sidebar {
                width: 250px;
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
                margin-left: 250px;
                padding: 20px;
                transition: all 0.3s;
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
                background: white;
                border-radius: 10px;
                padding: 20px;
                text-align: center;
                box-shadow: 0 3px 15px rgba(0,0,0,0.08);
                border-left: 4px solid var(--primary-color);
                margin-bottom: 20px;
            }

            .stat-card.users {
                border-left-color: var(--info-color);
            }
            .stat-card.products {
                border-left-color: var(--primary-color);
            }
            .stat-card.opportunities {
                border-left-color: var(--warning-color);
            }
            .stat-card.verified {
                border-left-color: var(--success-color);
            }
            .stat-card.learning {
                border-left-color: var(--danger-color);
            }

            .stat-number {
                font-size: 2rem;
                font-weight: 700;
                margin-bottom: 5px;
            }

            .stat-label {
                color: #6c757d;
                font-size: 0.9rem;
            }

            .dashboard-section {
                display: none;
            }

            .dashboard-section.active {
                display: block;
            }

            .table-actions {
                white-space: nowrap;
            }

            .btn-xs {
                padding: 0.25rem 0.5rem;
                font-size: 0.75rem;
            }

            .status-badge {
                font-size: 0.75rem;
                padding: 4px 8px;
            }

            .dataTables_wrapper {
                margin-top: 20px;
            }

            .page-header {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                padding: 30px 0;
                margin: -20px -20px 30px -20px;
            }

            .image-preview {
                max-width: 100px;
                max-height: 100px;
                border-radius: 5px;
                margin-top: 5px;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar Navigation -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header p-3 bg-success-dark">
                <h5 class="mb-0">
                    <i class="fas fa-crown me-2"></i>
                    Admin Dashboard
                </h5>
                <small class="text-white-50"><%= user.getFirstName()%> <%= user.getLastName()%></small>
            </div>

            <nav class="nav flex-column mt-3">
                <a class="nav-link active" href="#" data-section="overview">
                    <i class="fas fa-tachometer-alt me-2"></i> Overview
                </a>
                <a class="nav-link" href="#" data-section="users">
                    <i class="fas fa-users me-2"></i> Manage Users
                </a>
                <a class="nav-link" href="#" data-section="products">
                    <i class="fas fa-shopping-bag me-2"></i> Manage Products
                </a>
                <a class="nav-link" href="#" data-section="opportunities">
                    <i class="fas fa-briefcase me-2"></i> Manage Opportunities
                </a>
                <a class="nav-link" href="#" data-section="learning">
                    <i class="fas fa-graduation-cap me-2"></i> Manage Learning Hub
                </a>
                <div class="mt-4 p-3">
                    <a class="btn btn-outline-light btn-sm w-100 mb-2" href="index.jsp">
                        <i class="fas fa-home me-2"></i> Back to Site
                    </a>
                    <a class="btn btn-outline-light btn-sm w-100" href="LogoutServlet">
                        <i class="fas fa-sign-out-alt me-2"></i> Logout
                    </a>
                </div>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm rounded">
                <button class="btn btn-success" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h5 class="mb-0 text-success">Admin Dashboard</h5>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="page-header">
                <div class="container-fluid">
                    <div class="row align-items-center">
                        <div class="col">
                            <h1 class="display-5 fw-bold">
                                <i class="fas fa-crown me-2"></i>Admin Dashboard
                            </h1>
                            <p class="lead mb-0">Manage users, products, opportunities, and learning materials</p>
                        </div>
                        <div class="col-auto">
                            <div class="btn-group">
                                <button class="btn btn-outline-light" onclick="refreshDashboard()">
                                    <i class="fas fa-sync-alt me-2"></i>Refresh
                                </button>
                                <button class="btn btn-light" onclick="exportData()">
                                    <i class="fas fa-download me-2"></i>Export
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Dashboard Overview Section -->
            <div class="dashboard-section active" id="overviewSection">
                <div class="row">
                    <!-- Statistics Cards -->
                    <div class="col-xl-3 col-md-6">
                        <div class="stat-card users">
                            <div class="stat-number text-info" id="totalUsers">0</div>
                            <div class="stat-label">Total Users</div>
                            <div class="small text-muted mt-2">
                                <span id="totalFarmers">0</span> Farmers • 
                                <span id="totalBuyers">0</span> Buyers
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="stat-card verified">
                            <div class="stat-number text-success" id="verifiedUsers">0</div>
                            <div class="stat-label">Verified Users</div>
                            <div class="small text-muted mt-2">
                                <span id="verificationRate">0%</span> Verification Rate
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="stat-card products">
                            <div class="stat-number text-primary" id="totalProducts">0</div>
                            <div class="stat-label">Total Products</div>
                            <div class="small text-muted mt-2">
                                <span id="availableProducts">0</span> Available •
                                <span id="outOfStockProducts">0</span> Out of Stock
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="stat-card learning">
                            <div class="stat-number text-danger" id="totalLearningMaterials">0</div>
                            <div class="stat-label">Learning Materials</div>
                            <div class="small text-muted mt-2">
                                <span id="publishedMaterials">0</span> Published •
                                <span id="draftMaterials">0</span> Draft
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">
                                    <i class="fas fa-bolt me-2"></i>Quick Actions
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <button class="btn btn-outline-primary w-100 h-100" onclick="showAddUserModal()">
                                            <i class="fas fa-user-plus fa-2x mb-2"></i><br>
                                            Add New User
                                        </button>
                                    </div>
                                    <div class="col-md-3">
                                        <button class="btn btn-outline-success w-100 h-100" onclick="showAddProductModal()">
                                            <i class="fas fa-plus-circle fa-2x mb-2"></i><br>
                                            Add Product
                                        </button>
                                    </div>
                                    <div class="col-md-3">
                                        <button class="btn btn-outline-warning w-100 h-100" onclick="showAddOpportunityModal()">
                                            <i class="fas fa-briefcase fa-2x mb-2"></i><br>
                                            Create Opportunity
                                        </button>
                                    </div>
                                    <div class="col-md-3">
                                        <button class="btn btn-outline-danger w-100 h-100" onclick="showAddLearningMaterialModal()">
                                            <i class="fas fa-graduation-cap fa-2x mb-2"></i><br>
                                            Add Learning Material
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activity -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">
                                    <i class="fas fa-clock me-2"></i>Recent Users
                                </h5>
                            </div>
                            <div class="card-body">
                                <div id="recentUsersList">
                                    <div class="text-center py-4">
                                        <div class="spinner-border text-primary" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">
                                    <i class="fas fa-shopping-bag me-2"></i>Recent Products
                                </h5>
                            </div>
                            <div class="card-body">
                                <div id="recentProductsList">
                                    <div class="text-center py-4">
                                        <div class="spinner-border text-success" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Users Management Section -->
            <div class="dashboard-section" id="usersSection">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-users me-2"></i>User Management
                        </h5>
                        <button class="btn btn-primary btn-sm" onclick="showAddUserModal()">
                            <i class="fas fa-plus me-2"></i>Add User
                        </button>
                    </div>
                    <div class="card-body">
                        <table id="usersTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Profile</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Joined</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Users will be loaded via AJAX -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Products Management Section -->
            <div class="dashboard-section" id="productsSection">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-shopping-bag me-2"></i>Product Management
                        </h5>
                        <button class="btn btn-success btn-sm" onclick="showAddProductModal()">
                            <i class="fas fa-plus me-2"></i>Add Product
                        </button>
                    </div>
                    <div class="card-body">
                        <table id="productsTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Image</th>
                                    <th>Name</th>
                                    <th>Category</th>
                                    <th>Price</th>
                                    <th>Stock</th>
                                    <th>Status</th>
                                    <th>Seller</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Products will be loaded via AJAX -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Opportunities Management Section -->
            <div class="dashboard-section" id="opportunitiesSection">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-briefcase me-2"></i>Opportunity Management
                        </h5>
                        <button class="btn btn-warning btn-sm" onclick="showAddOpportunityModal()">
                            <i class="fas fa-plus me-2"></i>Create Opportunity
                        </button>
                    </div>
                    <div class="card-body">
                        <table id="opportunitiesTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Type</th>
                                    <th>Category</th>
                                    <th>Budget</th>
                                    <th>Deadline</th>
                                    <th>Status</th>
                                    <th>Applications</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Opportunities will be loaded via AJAX -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Learning Materials Management Section -->
            <div class="dashboard-section" id="learningSection">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-graduation-cap me-2"></i>Learning Materials Management
                        </h5>
                        <button class="btn btn-danger btn-sm" onclick="showAddLearningMaterialModal()">
                            <i class="fas fa-plus me-2"></i>Add Learning Material
                        </button>
                    </div>
                    <div class="card-body">
                        <table id="learningMaterialsTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Type</th>
                                    <th>Category</th>
                                    <th>Difficulty</th>
                                    <th>Duration</th>
                                    <th>Status</th>
                                    <th>Created</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Learning Materials will be loaded via AJAX -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add User Modal -->
        <div class="modal fade" id="addUserModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add New User</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="userForm" enctype="multipart/form-data">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">First Name *</label>
                                        <input type="text" class="form-control" name="firstName" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Last Name *</label>
                                        <input type="text" class="form-control" name="lastName" required>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email *</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Phone Number</label>
                                        <input type="tel" class="form-control" name="phoneNumber">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Location</label>
                                        <input type="text" class="form-control" name="location">
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Role *</label>
                                        <select class="form-select" name="role" required>
                                            <option value="FARMER">Farmer</option>
                                            <option value="BUYER">Buyer</option>
                                            <option value="ADMIN">Admin</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Status *</label>
                                        <select class="form-select" name="status" required>
                                            <option value="ACTIVE">Active</option>
                                            <option value="INACTIVE">Inactive</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Profile Picture</label>
                                <input type="file" class="form-control" name="profilePicture" accept="image/*" id="userProfilePicture">
                                <div id="userImagePreview" class="mt-2"></div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Bio</label>
                                <textarea class="form-control" name="bio" rows="3" placeholder="Brief description about the user"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password *</label>
                                <input type="password" class="form-control" name="password" required>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" onclick="saveUser()">Save User</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add Product Modal -->
        <div class="modal fade" id="addProductModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add New Product</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="productForm" enctype="multipart/form-data">
                            <div class="mb-3">
                                <label class="form-label">Product Name *</label>
                                <input type="text" class="form-control" name="name" required>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Category *</label>
                                        <select class="form-select" name="category" required>
                                            <option value="VEGETABLES">Vegetables</option>
                                            <option value="FRUITS">Fruits</option>
                                            <option value="GRAINS">Grains</option>
                                            <option value="DAIRY">Dairy</option>
                                            <option value="POULTRY">Poultry</option>
                                            <option value="OTHER">Other</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Price ($) *</label>
                                        <input type="number" step="0.01" min="0" class="form-control" name="price" required>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Stock Quantity *</label>
                                        <input type="number" class="form-control" name="stock" min="0" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Unit</label>
                                        <input type="text" class="form-control" name="unit" value="unit" placeholder="e.g., kg, lb, piece">
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Product Image</label>
                                <input type="file" class="form-control" name="image" accept="image/*" id="productImage">
                                <div id="productImagePreview" class="mt-2"></div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3" placeholder="Product description"></textarea>
                            </div>
                            <div class="mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="available" value="true" checked>
                                    <label class="form-check-label">Available for sale</label>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-success" onclick="saveProduct()">Save Product</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add Opportunity Modal -->
        <div class="modal fade" id="addOpportunityModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Create Opportunity</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="opportunityForm">
                            <div class="mb-3">
                                <label class="form-label">Title</label>
                                <input type="text" class="form-control" name="title" required>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Type</label>
                                        <select class="form-select" name="type" required>
                                            <option value="JOB">Job</option>
                                            <option value="INTERNSHIP">Internship</option>
                                            <option value="TRAINING">Training</option>
                                            <option value="GRANT">Grant</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Category</label>
                                        <input type="text" class="form-control" name="category" required>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Budget ($)</label>
                                        <input type="number" step="0.01" class="form-control" name="budget">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Deadline</label>
                                        <input type="date" class="form-control" name="deadline" required>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="4" required></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-warning" onclick="saveOpportunity()">Create Opportunity</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add Learning Material Modal -->
        <div class="modal fade" id="addLearningMaterialModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add Learning Material</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="learningMaterialForm">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Title *</label>
                                        <input type="text" class="form-control" name="title" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Content Type *</label>
                                        <select class="form-select" name="contentType" required>
                                            <option value="">Select Type</option>
                                            <option value="ARTICLE">Article</option>
                                            <option value="VIDEO">Video</option>
                                            <option value="BLOG">Blog</option>
                                            <option value="DOCUMENT">Document</option>
                                            <option value="TUTORIAL">Tutorial</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3" placeholder="Brief description of the learning material"></textarea>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Content URL</label>
                                        <input type="url" class="form-control" name="contentUrl" placeholder="https://example.com/video">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Category *</label>
                                        <select class="form-select" name="category" required>
                                            <option value="">Select Category</option>
                                            <option value="Crop Production">Crop Production</option>
                                            <option value="Livestock">Livestock</option>
                                            <option value="Business">Business</option>
                                            <option value="Technology">Technology</option>
                                            <option value="Sustainability">Sustainability</option>
                                            <option value="Marketing">Marketing</option>
                                            <option value="Finance">Finance</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Difficulty Level *</label>
                                        <select class="form-select" name="difficultyLevel" required>
                                            <option value="">Select Level</option>
                                            <option value="BEGINNER">Beginner</option>
                                            <option value="INTERMEDIATE">Intermediate</option>
                                            <option value="ADVANCED">Advanced</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Duration (minutes)</label>
                                        <input type="number" class="form-control" name="durationMinutes" min="1" value="30">
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Content Text</label>
                                <textarea class="form-control" name="contentText" rows="6" placeholder="Enter the main content here..."></textarea>
                            </div>
                            <div class="mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="isPublished" value="true" checked>
                                    <label class="form-check-label">Publish immediately</label>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" onclick="saveLearningMaterial()">Save Material</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

        <script>
            // Initialize DataTables and load data
            let usersTable, productsTable, opportunitiesTable, learningMaterialsTable;

            $(document).ready(function () {
                initializeDataTables();
                loadDashboardStats();
                loadRecentActivity();
                setupImagePreview();
            });

            function initializeDataTables() {
                usersTable = $('#usersTable').DataTable({
                    "ajax": {
                        "url": "AdminDashboardServlet?action=getUsers",
                        "dataSrc": "data",
                        "error": function (xhr, error, thrown) {
                            console.error('Error loading users:', error);
                            showNotification('Error loading users data', 'error');
                        }
                    },
                    "columns": [
                        {"data": "id"},
                        {
                            "data": "profileImage",
                            "render": function (data, type, row) {
                                if (data) {
                                    return '<img src="' + data + '" class="rounded-circle" width="40" height="40" alt="Profile">';
                                } else {
                                    return '<div class="bg-secondary rounded-circle d-flex align-items-center justify-content-center" style="width:40px;height:40px;"><i class="fas fa-user text-white"></i></div>';
                                }
                            }
                        },
                        {
                            "data": null,
                            "render": function (data, type, row) {
                                return (row.firstName || '') + ' ' + (row.lastName || '');
                            }
                        },
                        {"data": "email"},
                        {"data": "role"},
                        {
                            "data": "status",
                            "render": function (data, type, row) {
                                const badgeClass = data === 'ACTIVE' ? 'bg-success' : 'bg-secondary';
                                return '<span class="badge ' + badgeClass + ' status-badge">' + (data || 'UNKNOWN') + '</span>';
                            }
                        },
                        {
                            "data": "createdAt",
                            "render": function (data, type, row) {
                                return data ? new Date(data).toLocaleDateString() : 'N/A';
                            }
                        },
                        {
                            "data": null,
                            "render": function (data, type, row) {
                                let statusButton = '';
                                if (row.status === 'ACTIVE') {
                                    statusButton = '<button class="btn btn-xs btn-outline-warning" onclick="toggleUserStatus(' + row.id + ', \"INACTIVE\")" title="Deactivate"><i class="fas fa-ban"></i></button>';
                                } else {
                                    statusButton = '<button class="btn btn-xs btn-outline-success" onclick="toggleUserStatus(' + row.id + ', \"ACTIVE\")" title="Activate"><i class="fas fa-check"></i></button>';
                                }

                                return '<div class="table-actions">' +
                                        '<button class="btn btn-xs btn-outline-primary" onclick="editUser(' + row.id + ')" title="Edit"><i class="fas fa-edit"></i></button>' +
                                        '<button class="btn btn-xs btn-outline-danger" onclick="deleteUser(' + row.id + ')" title="Delete"><i class="fas fa-trash"></i></button>' +
                                        statusButton +
                                        '</div>';
                            }
                        }
                    ]
                });

                productsTable = $('#productsTable').DataTable({
                    "ajax": {
                        "url": "AdminDashboardServlet?action=getProducts",
                        "dataSrc": "data",
                        "error": function (xhr, error, thrown) {
                            console.error('Error loading products:', error);
                            showNotification('Error loading products data', 'error');
                        }
                    },
                    "columns": [
                        {"data": "id"},
                        {
                            "data": "imageUrl",
                            "render": function (data, type, row) {
                                if (data) {
                                    return '<img src="' + data + '" class="rounded" width="40" height="40" alt="Product">';
                                } else {
                                    return '<div class="bg-light rounded d-flex align-items-center justify-content-center" style="width:40px;height:40px;"><i class="fas fa-image text-muted"></i></div>';
                                }
                            }
                        },
                        {"data": "name"},
                        {"data": "category"},
                        {
                            "data": "price",
                            "render": function (data, type, row) {
                                return data ? '$' + parseFloat(data).toFixed(2) : '$0.00';
                            }
                        },
                        {"data": "stock"},
                        {
                            "data": "status",
                            "render": function (data, type, row) {
                                const badgeClass = data === 'AVAILABLE' ? 'bg-success' : 'bg-warning';
                                return '<span class="badge ' + badgeClass + ' status-badge">' + (data || 'UNKNOWN') + '</span>';
                            }
                        },
                        {"data": "sellerName"},
                        {
                            "data": null,
                            "render": function (data, type, row) {
                                return '<div class="table-actions">' +
                                        '<button class="btn btn-xs btn-outline-primary" onclick="editProduct(' + row.id + ')" title="Edit"><i class="fas fa-edit"></i></button>' +
                                        '<button class="btn btn-xs btn-outline-danger" onclick="deleteProduct(' + row.id + ')" title="Delete"><i class="fas fa-trash"></i></button>' +
                                        '</div>';
                            }
                        }
                    ]
                });

                opportunitiesTable = $('#opportunitiesTable').DataTable({
                    "ajax": {
                        "url": "AdminDashboardServlet?action=getOpportunities",
                        "dataSrc": "",
                        "error": function (xhr, error, thrown) {
                            console.error('Error loading opportunities:', error);
                            showNotification('Error loading opportunities data', 'error');
                        }
                    },
                    "columns": [
                        {"data": "id"},
                        {"data": "title"},
                        {"data": "type"},
                        {"data": "category"},
                        {
                            "data": "budget",
                            "render": function (data, type, row) {
                                return data ? '$' + parseFloat(data).toFixed(2) : 'N/A';
                            }
                        },
                        {
                            "data": "deadline",
                            "render": function (data, type, row) {
                                return data ? new Date(data).toLocaleDateString() : 'N/A';
                            }
                        },
                        {
                            "data": "status",
                            "render": function (data, type, row) {
                                const badgeClass = data === 'ACTIVE' ? 'bg-success' : 'bg-secondary';
                                return '<span class="badge ' + badgeClass + ' status-badge">' + (data || 'UNKNOWN') + '</span>';
                            }
                        },
                        {
                            "data": "applicationsCount",
                            "render": function (data, type, row) {
                                return data || 0;
                            }
                        },
                        {
                            "data": null,
                            "render": function (data, type, row) {
                                return '<div class="table-actions">' +
                                        '<button class="btn btn-xs btn-outline-primary" onclick="editOpportunity(' + row.id + ')" title="Edit"><i class="fas fa-edit"></i></button>' +
                                        '<button class="btn btn-xs btn-outline-danger" onclick="deleteOpportunity(' + row.id + ')" title="Delete"><i class="fas fa-trash"></i></button>' +
                                        '<button class="btn btn-xs btn-outline-info" onclick="viewApplications(' + row.id + ')" title="View Applications"><i class="fas fa-list"></i></button>' +
                                        '</div>';
                            }
                        }
                    ]
                });

                learningMaterialsTable = $('#learningMaterialsTable').DataTable({
                    "ajax": {
                        "url": "AdminDashboardServlet?action=getLearningMaterials",
                        "dataSrc": "data",
                        "error": function (xhr, error, thrown) {
                            console.error('Error loading learning materials:', error);
                            showNotification('Error loading learning materials data', 'error');
                        }
                    },
                    "columns": [
                        {"data": "id"},
                        {"data": "title"},
                        {"data": "contentType"},
                        {"data": "category"},
                        {
                            "data": "difficultyLevel",
                            "render": function (data, type, row) {
                                const badgeClass = data === 'BEGINNER' ? 'bg-success' : 
                                                 data === 'INTERMEDIATE' ? 'bg-warning' : 'bg-danger';
                                return '<span class="badge ' + badgeClass + ' status-badge">' + (data || 'UNKNOWN') + '</span>';
                            }
                        },
                        {
                            "data": "durationMinutes",
                            "render": function (data, type, row) {
                                return data ? data + ' min' : 'N/A';
                            }
                        },
                        {
                            "data": "isPublished",
                            "render": function (data, type, row) {
                                const badgeClass = data ? 'bg-success' : 'bg-secondary';
                                const statusText = data ? 'Published' : 'Draft';
                                return '<span class="badge ' + badgeClass + ' status-badge">' + statusText + '</span>';
                            }
                        },
                        {
                            "data": "createdAt",
                            "render": function (data, type, row) {
                                return data ? new Date(data).toLocaleDateString() : 'N/A';
                            }
                        },
                        {
                            "data": null,
                            "render": function (data, type, row) {
                                let publishButton = '';
                                if (row.isPublished) {
                                    publishButton = '<button class="btn btn-xs btn-outline-warning" onclick="toggleMaterialPublish(' + row.id + ', false)" title="Unpublish"><i class="fas fa-eye-slash"></i></button>';
                                } else {
                                    publishButton = '<button class="btn btn-xs btn-outline-success" onclick="toggleMaterialPublish(' + row.id + ', true)" title="Publish"><i class="fas fa-eye"></i></button>';
                                }

                                return '<div class="table-actions">' +
                                        '<button class="btn btn-xs btn-outline-primary" onclick="editLearningMaterial(' + row.id + ')" title="Edit"><i class="fas fa-edit"></i></button>' +
                                        '<button class="btn btn-xs btn-outline-danger" onclick="deleteLearningMaterial(' + row.id + ')" title="Delete"><i class="fas fa-trash"></i></button>' +
                                        publishButton +
                                        '</div>';
                            }
                        }
                    ]
                });
            }

            // Navigation functions
            function showSection(section) {
                $('.dashboard-section').removeClass('active');
                $('.nav-link').removeClass('active');

                $('#' + section + 'Section').addClass('active');
                $('[data-section="' + section + '"]').addClass('active');

                // Refresh data when switching sections
                switch (section) {
                    case 'users':
                        usersTable.ajax.reload();
                        break;
                    case 'products':
                        productsTable.ajax.reload();
                        break;
                    case 'opportunities':
                        opportunitiesTable.ajax.reload();
                        break;
                    case 'learning':
                        learningMaterialsTable.ajax.reload();
                        break;
                }
            }

            function refreshDashboard() {
                loadDashboardStats();
                loadRecentActivity();
                showNotification('Dashboard refreshed successfully!', 'success');
            }

            function loadDashboardStats() {
                $.get('AdminDashboardServlet?action=getStats', function (data) {
                    if (data && data.stats) {
                        $('#totalUsers').text(data.stats.totalUsers || 0);
                        $('#totalFarmers').text(data.stats.totalFarmers || 0);
                        $('#totalBuyers').text(data.stats.totalBuyers || 0);
                        $('#verifiedUsers').text(data.stats.verifiedUsers || 0);
                        $('#verificationRate').text(data.stats.verificationRate || '0%');
                        $('#totalProducts').text(data.stats.totalProducts || 0);
                        $('#availableProducts').text(data.stats.availableProducts || 0);
                        $('#outOfStockProducts').text(data.stats.outOfStockProducts || 0);
                        $('#totalLearningMaterials').text(data.stats.totalLearningMaterials || 0);
                        $('#publishedMaterials').text(data.stats.publishedMaterials || 0);
                        $('#draftMaterials').text(data.stats.draftMaterials || 0);
                    }
                }).fail(function () {
                    showNotification('Error loading dashboard statistics', 'error');
                });
            }

            function loadRecentActivity() {
                $.get('AdminDashboardServlet?action=getRecentUsers', function (users) {
                    let usersHtml = '';
                    if (users && users.length > 0) {
                        users.slice(0, 5).forEach(function (user) {
                            let profileImg = user.profileImage ?
                                    '<img src="' + user.profileImage + '" class="rounded-circle" width="40" height="40" alt="Profile">' :
                                    '<div class="bg-secondary rounded-circle d-flex align-items-center justify-content-center" style="width:40px;height:40px;"><i class="fas fa-user text-white"></i></div>';

                            let badgeClass = user.role === 'FARMER' ? 'success' : 'primary';

                            usersHtml += '<div class="d-flex align-items-center mb-3">' +
                                    '<div class="flex-shrink-0">' + profileImg + '</div>' +
                                    '<div class="flex-grow-1 ms-3">' +
                                    '<h6 class="mb-0">' + user.firstName + ' ' + user.lastName + '</h6>' +
                                    '<small class="text-muted">' + user.email + '</small>' +
                                    '</div>' +
                                    '<span class="badge bg-' + badgeClass + '">' + user.role + '</span>' +
                                    '</div>';
                        });
                    } else {
                        usersHtml = '<p class="text-muted">No recent users</p>';
                    }
                    $('#recentUsersList').html(usersHtml);
                }).fail(function () {
                    $('#recentUsersList').html('<p class="text-muted">Error loading recent users</p>');
                });

                $.get('AdminDashboardServlet?action=getRecentProducts', function (products) {
                    let productsHtml = '';
                    if (products && products.length > 0) {
                        products.slice(0, 5).forEach(function (product) {
                            let productImg = product.imageUrl ?
                                    '<img src="' + product.imageUrl + '" class="rounded" width="40" height="40" alt="Product">' :
                                    '<div class="bg-light rounded d-flex align-items-center justify-content-center" style="width:40px;height:40px;"><i class="fas fa-image text-muted"></i></div>';

                            let badgeClass = product.status === 'AVAILABLE' ? 'success' : 'warning';

                            productsHtml += '<div class="d-flex align-items-center mb-3">' +
                                    '<div class="flex-shrink-0">' + productImg + '</div>' +
                                    '<div class="flex-grow-1 ms-3">' +
                                    '<h6 class="mb-0">' + product.name + '</h6>' +
                                    '<small class="text-muted">$' + parseFloat(product.price).toFixed(2) + '</small>' +
                                    '</div>' +
                                    '<span class="badge bg-' + badgeClass + '">' + product.status + '</span>' +
                                    '</div>';
                        });
                    } else {
                        productsHtml = '<p class="text-muted">No recent products</p>';
                    }
                    $('#recentProductsList').html(productsHtml);
                }).fail(function () {
                    $('#recentProductsList').html('<p class="text-muted">Error loading recent products</p>');
                });
            }

            // Image Preview Setup
            function setupImagePreview() {
                // User profile picture preview
                $('#userProfilePicture').on('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            $('#userImagePreview').html('<img src="' + e.target.result + '" class="image-preview" alt="Profile Preview">');
                        }
                        reader.readAsDataURL(file);
                    } else {
                        $('#userImagePreview').html('');
                    }
                });

                // Product image preview
                $('#productImage').on('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            $('#productImagePreview').html('<img src="' + e.target.result + '" class="image-preview" alt="Product Preview">');
                        }
                        reader.readAsDataURL(file);
                    } else {
                        $('#productImagePreview').html('');
                    }
                });
            }

            // Modal functions
            function showAddUserModal() {
                $('#userForm')[0].reset();
                $('#userImagePreview').html('');
                var addUserModal = new bootstrap.Modal(document.getElementById('addUserModal'));
                addUserModal.show();
            }

            function showAddProductModal() {
                $('#productForm')[0].reset();
                $('#productImagePreview').html('');
                var addProductModal = new bootstrap.Modal(document.getElementById('addProductModal'));
                addProductModal.show();
            }

            function showAddOpportunityModal() {
                $('#opportunityForm')[0].reset();
                // Set minimum date to today
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                $('#opportunityForm input[name="deadline"]').attr('min', tomorrow.toISOString().split('T')[0]);
                var addOpportunityModal = new bootstrap.Modal(document.getElementById('addOpportunityModal'));
                addOpportunityModal.show();
            }

            function showAddLearningMaterialModal() {
                $('#learningMaterialForm')[0].reset();
                var addLearningMaterialModal = new bootstrap.Modal(document.getElementById('addLearningMaterialModal'));
                addLearningMaterialModal.show();
            }

            // Save functions
            function saveUser() {
                const formData = new FormData($('#userForm')[0]);

                $.ajax({
                    url: 'AdminDashboardServlet?action=addUser',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        if (response.success) {
                            $('#addUserModal').modal('hide');
                            usersTable.ajax.reload();
                            loadDashboardStats();
                            showNotification('User added successfully!', 'success');
                        } else {
                            showNotification('Error adding user: ' + (response.message || 'Unknown error'), 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error adding user: ' + error, 'error');
                    }
                });
            }

            function saveProduct() {
                const formData = new FormData($('#productForm')[0]);

                $.ajax({
                    url: 'AdminDashboardServlet?action=addProduct',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        if (response.success) {
                            $('#addProductModal').modal('hide');
                            productsTable.ajax.reload();
                            loadDashboardStats();
                            showNotification('Product added successfully!', 'success');
                        } else {
                            showNotification('Error adding product: ' + (response.message || 'Unknown error'), 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error adding product: ' + error, 'error');
                    }
                });
            }

            function saveOpportunity() {
                const formData = new FormData($('#opportunityForm')[0]);

                $.ajax({
                    url: 'AdminDashboardServlet?action=addOpportunity',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        if (response.success) {
                            $('#addOpportunityModal').modal('hide');
                            opportunitiesTable.ajax.reload();
                            loadDashboardStats();
                            showNotification('Opportunity created successfully!', 'success');
                        } else {
                            showNotification('Error creating opportunity: ' + (response.message || 'Unknown error'), 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error creating opportunity: ' + error, 'error');
                    }
                });
            }

            function saveLearningMaterial() {
                const formData = new FormData($('#learningMaterialForm')[0]);

                $.ajax({
                    url: 'AdminDashboardServlet?action=addLearningMaterial',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        if (response.success) {
                            $('#addLearningMaterialModal').modal('hide');
                            learningMaterialsTable.ajax.reload();
                            loadDashboardStats();
                            showNotification('Learning material added successfully!', 'success');
                        } else {
                            showNotification('Error adding learning material: ' + (response.message || 'Unknown error'), 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error adding learning material: ' + error, 'error');
                    }
                });
            }

            // User Management Functions
            function editUser(id) {
                $.get('AdminDashboardServlet?action=getUsers', function(response) {
                    if (response && response.data) {
                        const user = response.data.find(u => u.id === id);
                        if (user) {
                            // Populate edit form
                            $('#userForm input[name="firstName"]').val(user.firstName || '');
                            $('#userForm input[name="lastName"]').val(user.lastName || '');
                            $('#userForm input[name="email"]').val(user.email || '');
                            $('#userForm select[name="role"]').val(user.role || 'FARMER');
                            $('#userForm select[name="status"]').val(user.status || 'ACTIVE');
                            
                            // Remove password requirement for edit
                            $('#userForm input[name="password"]').removeAttr('required');
                            
                            // Store the user ID in a data attribute
                            $('#userForm').data('editing-id', id);
                            
                            // Show modal with update action
                            const modal = new bootstrap.Modal(document.getElementById('addUserModal'));
                            modal.show();
                            
                            // Change modal title and button
                            $('.modal-title').text('Edit User');
                            $('.modal-footer .btn-primary').text('Update User').attr('onclick', 'updateUser()');
                        } else {
                            showNotification('User not found', 'error');
                        }
                    }
                }).fail(function() {
                    showNotification('Error loading user data', 'error');
                });
            }

            function updateUser() {
                const editingId = $('#userForm').data('editing-id');
                
                if (!editingId) {
                    showNotification('User ID not found', 'error');
                    return;
                }
                
                const formData = new FormData($('#userForm')[0]);
                formData.append('id', editingId);
                
                $.ajax({
                    url: 'AdminDashboardServlet?action=updateUser&id=' + editingId,
                    type: 'PUT',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        if (response.success) {
                            $('#addUserModal').modal('hide');
                            usersTable.ajax.reload();
                            // Clear the editing ID
                            $('#userForm').removeData('editing-id');
                            showNotification(response.message, 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    },
                    error: function(xhr, status, error) {
                        showNotification('Error updating user: ' + error, 'error');
                    }
                });
            }

            function deleteUser(id) {
                if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
                    $.ajax({
                        url: 'AdminDashboardServlet?action=deleteUser&id=' + id,
                        type: 'DELETE',
                        success: function(response) {
                            if (response.success) {
                                usersTable.ajax.reload();
                                loadDashboardStats();
                                showNotification(response.message, 'success');
                            } else {
                                showNotification(response.message, 'error');
                            }
                        },
                        error: function(xhr, status, error) {
                            showNotification('Error deleting user: ' + error, 'error');
                        }
                    });
                }
            }

            function toggleUserStatus(id, status) {
                const action = status === 'ACTIVE' ? 'activate' : 'deactivate';
                if (confirm(`Are you sure you want to ${action} this user?`)) {
                    $.ajax({
                        url: 'AdminDashboardServlet?action=toggleUserStatus&id=' + id + '&status=' + status,
                        type: 'PUT',
                        success: function(response) {
                            if (response.success) {
                                usersTable.ajax.reload();
                                showNotification(response.message, 'success');
                            } else {
                                showNotification(response.message, 'error');
                            }
                        },
                        error: function(xhr, status, error) {
                            showNotification('Error updating user status: ' + error, 'error');
                        }
                    });
                }
            }

            // Product Management Functions
            function editProduct(id) {
                $.get('AdminDashboardServlet?action=getProducts', function(response) {
                    if (response && response.data) {
                        const product = response.data.find(p => p.id === id);
                        if (product) {
                            // Populate edit form
                            $('#productForm input[name="name"]').val(product.name || '');
                            $('#productForm select[name="category"]').val(product.category || 'VEGETABLES');
                            $('#productForm input[name="price"]').val(product.price || '0.00');
                            $('#productForm input[name="stock"]').val(product.stock || 0);
                            $('#productForm input[name="unit"]').val(product.unit || 'unit');
                            $('#productForm textarea[name="description"]').val(product.description || '');
                            $('#productForm input[name="available"]').prop('checked', product.status === 'AVAILABLE');
                            
                            // Store the product ID in a data attribute
                            $('#productForm').data('editing-id', id);
                            
                            // Show modal with update action
                            const modal = new bootstrap.Modal(document.getElementById('addProductModal'));
                            modal.show();
                            
                            // Change modal title and button
                            $('.modal-title').text('Edit Product');
                            $('.modal-footer .btn-success').text('Update Product').attr('onclick', 'updateProduct()');
                        } else {
                            showNotification('Product not found', 'error');
                        }
                    }
                }).fail(function() {
                    showNotification('Error loading product data', 'error');
                });
            }

            function updateProduct() {
                const editingId = $('#productForm').data('editing-id');
                
                if (!editingId) {
                    showNotification('Product ID not found', 'error');
                    return;
                }
                
                const formData = new FormData($('#productForm')[0]);
                formData.append('id', editingId);
                
                $.ajax({
                    url: 'AdminDashboardServlet?action=updateProduct&id=' + editingId,
                    type: 'PUT',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        if (response.success) {
                            $('#addProductModal').modal('hide');
                            productsTable.ajax.reload();
                            // Clear the editing ID
                            $('#productForm').removeData('editing-id');
                            showNotification(response.message, 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    },
                    error: function(xhr, status, error) {
                        showNotification('Error updating product: ' + error, 'error');
                    }
                });
            }

            function deleteProduct(id) {
                if (confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
                    $.ajax({
                        url: 'AdminDashboardServlet?action=deleteProduct&id=' + id,
                        type: 'DELETE',
                        success: function(response) {
                            if (response.success) {
                                productsTable.ajax.reload();
                                loadDashboardStats();
                                showNotification(response.message, 'success');
                            } else {
                                showNotification(response.message, 'error');
                            }
                        },
                        error: function(xhr, status, error) {
                            showNotification('Error deleting product: ' + error, 'error');
                        }
                    });
                }
            }

            // Learning Material Management Functions
            function editLearningMaterial(id) {
                $.get('AdminDashboardServlet?action=getLearningMaterials', function (response) {
                    if (response && response.data) {
                        const material = response.data.find(m => m.id === id);
                        if (material) {
                            // Populate edit form
                            $('#learningMaterialForm input[name="title"]').val(material.title || '');
                            $('#learningMaterialForm select[name="contentType"]').val(material.contentType || 'ARTICLE');
                            $('#learningMaterialForm textarea[name="description"]').val(material.description || '');
                            $('#learningMaterialForm input[name="contentUrl"]').val(material.contentUrl || '');
                            $('#learningMaterialForm select[name="category"]').val(material.category || '');
                            $('#learningMaterialForm select[name="difficultyLevel"]').val(material.difficultyLevel || 'BEGINNER');
                            $('#learningMaterialForm input[name="durationMinutes"]').val(material.durationMinutes || 30);
                            $('#learningMaterialForm textarea[name="contentText"]').val(material.contentText || '');
                            $('#learningMaterialForm input[name="isPublished"]').prop('checked', material.isPublished || false);

                            // Store the material ID in a data attribute
                            $('#learningMaterialForm').data('editing-id', id);

                            // Show modal with update action
                            const modal = new bootstrap.Modal(document.getElementById('addLearningMaterialModal'));
                            modal.show();

                            // Change modal title and button
                            $('.modal-title').text('Edit Learning Material');
                            $('.modal-footer .btn-danger').text('Update Material').attr('onclick', 'updateLearningMaterial()');
                        }
                    }
                }).fail(function () {
                    showNotification('Error loading learning material data', 'error');
                });
            }

            function updateLearningMaterial() {
                const editingId = $('#learningMaterialForm').data('editing-id');

                if (!editingId) {
                    showNotification('Learning Material ID not found', 'error');
                    return;
                }

                const formData = new FormData($('#learningMaterialForm')[0]);
                formData.append('id', editingId);

                $.ajax({
                    url: 'AdminDashboardServlet?action=updateLearningMaterial&id=' + editingId,
                    type: 'PUT',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        if (response.success) {
                            $('#addLearningMaterialModal').modal('hide');
                            learningMaterialsTable.ajax.reload();
                            // Clear the editing ID
                            $('#learningMaterialForm').removeData('editing-id');
                            showNotification(response.message, 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error updating learning material: ' + error, 'error');
                    }
                });
            }

            function deleteLearningMaterial(id) {
                if (confirm('Are you sure you want to delete this learning material? This action cannot be undone.')) {
                    $.ajax({
                        url: 'AdminDashboardServlet?action=deleteLearningMaterial&id=' + id,
                        type: 'DELETE',
                        success: function (response) {
                            if (response.success) {
                                learningMaterialsTable.ajax.reload();
                                loadDashboardStats();
                                showNotification(response.message, 'success');
                            } else {
                                showNotification(response.message, 'error');
                            }
                        },
                        error: function (xhr, status, error) {
                            showNotification('Error deleting learning material: ' + error, 'error');
                        }
                    });
                }
            }

            function toggleMaterialPublish(id, publish) {
                const action = publish ? 'publish' : 'unpublish';
                $.ajax({
                    url: 'AdminDashboardServlet?action=toggleMaterialPublish&id=' + id + '&publish=' + publish,
                    type: 'POST',
                    success: function (response) {
                        if (response.success) {
                            learningMaterialsTable.ajax.reload();
                            loadDashboardStats();
                            showNotification(response.message, 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    },
                    error: function (xhr, status, error) {
                        showNotification('Error updating material status: ' + error, 'error');
                    }
                });
            }

            // Opportunity Management Functions (placeholder)
            function editOpportunity(id) {
                showNotification('Edit opportunity feature coming soon!', 'info');
            }

            function deleteOpportunity(id) {
                if (confirm('Are you sure you want to delete this opportunity?')) {
                    $.ajax({
                        url: 'AdminDashboardServlet?action=deleteOpportunity&id=' + id,
                        type: 'DELETE',
                        success: function (response) {
                            if (response.success) {
                                opportunitiesTable.ajax.reload();
                                showNotification(response.message, 'success');
                            } else {
                                showNotification(response.message, 'error');
                            }
                        },
                        error: function (xhr, status, error) {
                            showNotification('Error deleting opportunity: ' + error, 'error');
                        }
                    });
                }
            }

            function viewApplications(id) {
                showNotification('View applications feature coming soon!', 'info');
            }

            // Utility functions
            function showNotification(message, type) {
                const alertClass = type === 'success' ? 'alert-success' : 
                                 type === 'error' ? 'alert-danger' : 
                                 type === 'warning' ? 'alert-warning' : 'alert-info';
                const notification = $(
                        '<div class="alert ' + alertClass + ' alert-dismissible fade show position-fixed" ' +
                        'style="top: 20px; right: 20px; z-index: 1050; min-width: 300px;">' +
                        message +
                        '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                        '</div>'
                        );
                $('body').append(notification);
                setTimeout(function () {
                    notification.alert('close');
                }, 5000);
            }

            function exportData() {
                showNotification('Export feature coming soon!', 'info');
            }

            // Mobile sidebar toggle
            document.getElementById('sidebarToggle').addEventListener('click', function () {
                document.getElementById('sidebar').classList.toggle('show');
            });

            // Navigation click handlers
            document.querySelectorAll('.nav-link[data-section]').forEach(function (link) {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    const section = this.getAttribute('data-section');
                    showSection(section);

                    // Close sidebar on mobile after selection
                    if (window.innerWidth <= 768) {
                        document.getElementById('sidebar').classList.remove('show');
                    }
                });
            });

            // Reset modal when hidden
            $('#addUserModal, #addProductModal, #addOpportunityModal, #addLearningMaterialModal').on('hidden.bs.modal', function () {
                const $form = $(this).find('form');
                $form[0].reset();
                $('.modal-title').text($(this).attr('id').includes('User') ? 'Add New User' :
                        $(this).attr('id').includes('Product') ? 'Add New Product' :
                        $(this).attr('id').includes('Opportunity') ? 'Create Opportunity' : 'Add Learning Material');
                $('.modal-footer .btn-primary, .modal-footer .btn-success, .modal-footer .btn-warning, .modal-footer .btn-danger')
                        .text(function () {
                            return $(this).hasClass('btn-primary') ? 'Save User' :
                                    $(this).hasClass('btn-success') ? 'Save Product' :
                                    $(this).hasClass('btn-warning') ? 'Create Opportunity' : 'Save Material';
                        })
                        .attr('onclick', function () {
                            return $(this).hasClass('btn-primary') ? 'saveUser()' :
                                    $(this).hasClass('btn-success') ? 'saveProduct()' :
                                    $(this).hasClass('btn-warning') ? 'saveOpportunity()' : 'saveLearningMaterial()';
                        });

                // Clear image previews
                $('#userImagePreview, #productImagePreview').html('');
                
                // Re-add password requirement for add user
                if ($(this).attr('id') === 'addUserModal') {
                    $('#userForm input[name="password"]').attr('required', true);
                }
                
                // Clear editing IDs
                $form.removeData('editing-id');
            });
        </script>
    </body>
</html>