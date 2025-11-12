<%@page import="java.math.BigDecimal"%>
<%@ page import="java.util.*, models.Product, daos.ProductDAO, models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }
    
    ProductDAO dao = new ProductDAO();
    List<Product> products = dao.getProductsByUser(user.getId());
    
    // Calculate some stats for the farmer
    int totalProducts = products.size();
    int activeProducts = 0;
    int outOfStockProducts = 0;
    double totalInventoryValue = 0;
    
    for (Product p : products) {
        if (p.isAvailable()) activeProducts++;
        if (p.getQuantity() <= 0) outOfStockProducts++;
        totalInventoryValue += p.getPrice().multiply(BigDecimal.valueOf(p.getQuantity())).doubleValue();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - AgriYouth Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
        
        .stat-card {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            border-radius: 10px;
            transition: transform 0.2s;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
        }
        
        .product-card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        
        .status-available { 
background-color: #d4edda; 
color: #155724; 
}
        .status-unavailable { 
background-color: #f8d7da; 
color: #721c24; 
}
        .status-low-stock { 
background-color: #fff3cd; 
color: #856404; 
}
        
        .form-section {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .category-badge {
            background: #e9f7ef;
            color: #28a745;
            border: 1px solid #28a745;
        }
        
        .action-buttons .btn {
            margin: 2px;
        }
        
        .image-preview {
            max-width: 200px;
            max-height: 150px;
            border-radius: 8px;
            display: none;
        }
    </style>
</head>
<body>
    <!-- Sidebar Navigation -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header p-3 bg-success-dark">
            <h5 class="mb-0">
                <i class="fas fa-tractor me-2"></i>
<%= user.getFirstName() %> <%= user.getLastName() %>
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
            <a class="nav-link" href="farmers_dashboard.jsp">
                <i class="fas fa-shopping-bag me-2"></i> Orders Received
            </a>
            <a class="nav-link active" href="product_management.jsp">
                <i class="fas fa-plus-circle me-2"></i> Manage Products
            </a>
            <a class="nav-link" href="my_listings.jsp">
                <i class="fas fa-boxes me-2"></i> My Listings
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
        <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm rounded">
            <button class="btn btn-success" id="sidebarToggle">
                <i class="fas fa-bars"></i>
            </button>
            <h5 class="mb-0 text-success">Product Management</h5>
            <div></div>
        </div>

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="text-success mb-1">
                    <i class="fas fa-seedling me-2"></i>Product Management
                </h2>
                <p class="text-muted mb-0">Manage your agricultural products and inventory</p>
            </div>
            <div class="btn-group">
                <button class="btn btn-outline-success" onclick="showProductForm()">
                    <i class="fas fa-plus me-2"></i>Add Product
                </button>
                <a href="my_listings.jsp" class="btn btn-success">
                    <i class="fas fa-eye me-2"></i>View Listings
                </a>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="stat-card p-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3 class="mb-0"><%= totalProducts %></h3>
                            <small>Total Products</small>
                        </div>
                        <i class="fas fa-boxes fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card p-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3 class="mb-0"><%= activeProducts %></h3>
                            <small>Active Listings</small>
                        </div>
                        <i class="fas fa-check-circle fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card p-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3 class="mb-0"><%= outOfStockProducts %></h3>
                            <small>Out of Stock</small>
                        </div>
                        <i class="fas fa-exclamation-triangle fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card p-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3 class="mb-0">M <%= String.format("%.2f", totalInventoryValue) %></h3>
                            <small>Inventory Value</small>
                        </div>
                        <i class="fas fa-money-bill-wave fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Form Section -->
        <div class="form-section p-4 mb-4" id="productFormSection">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="text-success mb-0" id="formTitle">
                    <i class="fas fa-plus-circle me-2"></i>Add New Product
                </h4>
                <button type="button" class="btn-close" id="closeForm" aria-label="Close"></button>
            </div>
            
            <form id="productForm" enctype="multipart/form-data">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="id" id="productId">
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Product Name *</label>
                        <input type="text" class="form-control" name="name" id="name" required 
                               placeholder="Enter product name (e.g., Fresh Tomatoes)">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Category *</label>
                        <select class="form-select" name="category" id="category" required>
                            <option value="">Select Category</option>
                            <option value="Vegetables">Vegetables</option>
                            <option value="Fruits">Fruits</option>
                            <option value="Grains">Grains</option>
                            <option value="Livestock">Livestock</option>
                            <option value="Dairy">Dairy Products</option>
                            <option value="Poultry">Poultry</option>
                            <option value="Herbs">Herbs & Spices</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Description</label>
                    <textarea class="form-control" name="description" id="description" 
                              rows="3" placeholder="Describe your product (quality, freshness, growing method, etc.)"></textarea>
                </div>
                
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label fw-bold">Price (M) *</label>
                        <div class="input-group">
                            <span class="input-group-text">M</span>
                            <input type="number" step="0.01" min="0" class="form-control" 
                                   name="price" id="price" required placeholder="0.00">
                        </div>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label fw-bold">Quantity *</label>
                        <input type="number" step="0.01" min="0" class="form-control" 
                               name="quantity" id="quantity" required placeholder="0">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label fw-bold">Unit *</label>
                        <select class="form-select" name="unit" id="unit" required>
                            <option value="kg">Kilogram (kg)</option>
                            <option value="g">Gram (g)</option>
                            <option value="lb">Pound (lb)</option>
                            <option value="piece">Piece</option>
                            <option value="bunch">Bunch</option>
                            <option value="dozen">Dozen</option>
                            <option value="liter">Liter</option>
                            <option value="bag">Bag</option>
                            <option value="crate">Crate</option>
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Product Image</label>
                    <input type="file" class="form-control" name="image" id="image" 
                           accept="image/*" onchange="previewImage(this)">
                    <div class="mt-2">
                        <img id="imagePreview" class="image-preview" alt="Image preview">
                    </div>
                    <div class="form-text">Upload a clear photo of your product (max 5MB, JPG/PNG)</div>
                </div>
                
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-success px-4">
                        <i class="fas fa-save me-2"></i>
                        <span id="submitButtonText">Add Product</span>
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="resetForm()">
                        <i class="fas fa-times me-2"></i>Cancel
                    </button>
                </div>
            </form>
        </div>

        <!-- Products Table -->
        <div class="form-section p-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="text-success mb-0">
                    <i class="fas fa-list me-2"></i>My Products (<%= products.size() %>)
                </h4>
                <div class="btn-group">
                    <button class="btn btn-outline-success btn-sm" onclick="exportProducts()">
                        <i class="fas fa-download me-1"></i>Export
                    </button>
                </div>
            </div>

<% if (products.isEmpty()) { %>
                <div class="text-center py-5">
                    <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">No products added yet</h5>
                    <p class="text-muted">Start by adding your first agricultural product</p>
                    <button class="btn btn-success mt-2" onclick="showProductForm()">
                        <i class="fas fa-plus me-2"></i>Add Your First Product
                    </button>
                </div>
<% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-success">
                            <tr>
                                <th>Product</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
<% for (Product p : products) { 
    String statusClass = "";
    String statusText = "";
    if (!p.isAvailable()) {
        statusClass = "status-unavailable";
        statusText = "Inactive";
    } else if (p.getQuantity() <= 0) {
        statusClass = "status-unavailable";
        statusText = "Out of Stock";
    } else if (p.getQuantity() < 10) {
        statusClass = "status-low-stock";
        statusText = "Low Stock";
    } else {
        statusClass = "status-available";
        statusText = "Available";
    }
%>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
<% if (p.getImage() != null && p.getImage().length > 0) { %>
                                                <img src="ImageServlet?id=<%= p.getId() %>" 
                                                     class="rounded me-3" 
                                                     style="width: 40px; height: 40px; object-fit: cover;" 
                                                     alt="<%= p.getName() %>">
<% } else { %>
                                                <div class="bg-light rounded d-flex align-items-center justify-content-center me-3" 
                                                     style="width: 40px; height: 40px;">
                                                    <i class="fas fa-seedling text-muted"></i>
                                                </div>
<% } %>
                                            <div>
                                                <strong class="d-block"><%= p.getName() %></strong>
                                                <small class="text-muted text-truncate" style="max-width: 200px; display: block;">
<%= p.getDescription() != null && !p.getDescription().isEmpty() ? 
    (p.getDescription().length() > 50 ? p.getDescription().substring(0, 50) + "..." : p.getDescription()) 
    : "No description" %>
                                                </small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge category-badge"><%= p.getCategory() %></span>
                                    </td>
                                    <td>
                                        <strong class="text-success">M <%= String.format("%.2f", p.getPrice()) %></strong>
                                    </td>
                                    <td>
                                        <div>
                                            <strong><%= p.getQuantity() %> <%= p.getUnit() %></strong>
<% if (p.getQuantity() < 10 && p.getQuantity() > 0) { %>
                                                <br><small class="text-warning"><i class="fas fa-exclamation-triangle"></i> Low stock</small>
<% } else if (p.getQuantity() == 0) { %>
                                                <br><small class="text-danger"><i class="fas fa-times-circle"></i> Out of stock</small>
<% } %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge <%= statusClass %>"><%= statusText %></span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="btn btn-sm btn-outline-primary" 
                                                    onclick="editProduct(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', '<%= p.getCategory() %>', <%= p.getPrice() %>, <%= p.getQuantity() %>, '<%= p.getUnit() %>', '<%= p.getDescription() != null ? p.getDescription().replace("'", "\\'") : "" %>')"
                                                    title="Edit Product">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button class="btn btn-sm btn-outline-<%= p.isAvailable() ? "warning" : "success" %>" 
                                                    onclick="toggleProductStatus(<%= p.getId() %>, <%= p.isAvailable() %>)"
                                                    title="<%= p.isAvailable() ? "Deactivate" : "Activate" %> Product">
                                                <i class="fas fa-<%= p.isAvailable() ? "pause" : "play" %>"></i>
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger" 
                                                    onclick="deleteProduct(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>')"
                                                    title="Delete Product">
                                                <i class="fas fa-trash"></i>
                                            </button>
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

    <!-- Success Toast -->
    <div class="toast-container position-fixed top-0 end-0 p-3">
        <div id="successToast" class="toast" role="alert">
            <div class="toast-header bg-success text-white">
                <i class="fas fa-check-circle me-2"></i>
                <strong class="me-auto">Success</strong>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
            </div>
            <div class="toast-body" id="toastMessage"></div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Initialize Bootstrap toast
        const successToast = new bootstrap.Toast(document.getElementById('successToast'));
        
        // Sidebar toggle for mobile
        $('#sidebarToggle').click(function() {
            $('#sidebar').toggleClass('show');
        });

        // Close sidebar when clicking outside on mobile
        $(document).click(function(e) {
            if ($(window).width() <= 768) {
                if (!$(e.target).closest('#sidebar').length && !$(e.target).is('#sidebarToggle')) {
                    $('#sidebar').removeClass('show');
                }
            }
        });

        // Form functionality
        function showProductForm() {
            $('#productFormSection').slideDown();
            $('html, body').animate({
                scrollTop: $('#productFormSection').offset().top - 20
            }, 500);
        }

        function resetForm() {
            $('#productForm')[0].reset();
            $('#productId').val('');
            $('input[name=action]').val('add');
            $('#formTitle').html('<i class="fas fa-plus-circle me-2"></i>Add New Product');
            $('#submitButtonText').text('Add Product');
            $('#imagePreview').hide();
        }

        function previewImage(input) {
            const preview = document.getElementById('imagePreview');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function editProduct(id, name, category, price, quantity, unit, description) {
            resetForm();
            $('#formTitle').html('<i class="fas fa-edit me-2"></i>Edit Product');
            $('input[name=action]').val('update');
            $('#productId').val(id);
            $('#name').val(name);
            $('#category').val(category);
            $('#price').val(price);
            $('#quantity').val(quantity);
            $('#unit').val(unit);
            $('#description').val(description);
            $('#submitButtonText').text('Update Product');
            
            showProductForm();
        }

        function toggleProductStatus(productId, currentStatus) {
            const action = currentStatus ? 'deactivate' : 'activate';
            const confirmMessage = `Are you sure you want to ${action} this product?`;
            
            if (confirm(confirmMessage)) {
                $.post('ToggleProductStatusServlet', {
                    productId: productId,
                    newStatus: !currentStatus
                }, function(response) {
                    if (response.success) {
                        showToast(`Product ${action}d successfully!`);
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        alert('Error: ' + response.message);
                    }
                }).fail(function() {
                    alert('Error updating product status');
                });
            }
        }

        function deleteProduct(id, name) {
            if (confirm(`Are you sure you want to delete "${name}"? This action cannot be undone.`)) {
                $.post("ProductManagementServlet", { 
                    action: "delete", 
                    id: id 
                }, function(response) {
                    if (response.success) {
                        showToast('Product deleted successfully!');
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        alert('Error: ' + response.message);
                    }
                }, "json").fail(function() {
                    alert('Error deleting product');
                });
            }
        }

        function showToast(message) {
            $('#toastMessage').text(message);
            successToast.show();
        }

        function exportProducts() {
            // Simple CSV export functionality
            let csv = 'Product Name,Category,Price,Quantity,Unit,Status\n';
<% for (Product p : products) { %>
                csv += '<%= p.getName().replace(",", " ") %>,<%= p.getCategory() %>,<%= p.getPrice() %>,<%= p.getQuantity() %>,<%= p.getUnit() %>,<%= p.isAvailable() ? "Active" : "Inactive" %>\n';
<% } %>
            
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.setAttribute('hidden', '');
            a.setAttribute('href', url);
            a.setAttribute('download', 'my_products.csv');
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }

        // Form submission
        $("#productForm").submit(function(e) {
            e.preventDefault();
            const submitBtn = $(this).find('button[type="submit"]');
            const originalText = submitBtn.html();
            
            submitBtn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i>Processing...');
            
            let formData = new FormData(this);
            $.ajax({
                url: "ProductManagementServlet",
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        showToast(response.message);
                        resetForm();
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function() {
                    alert('Error submitting form. Please try again.');
                },
                complete: function() {
                    submitBtn.prop('disabled', false).html(originalText);
                }
            });
        });

        // Close form button
        $('#closeForm').click(function() {
            resetForm();
            $('#productFormSection').slideUp();
        });

        // Initialize
        $(document).ready(function() {
            // Hide form section initially if there are products
<% if (!products.isEmpty()) { %>
                $('#productFormSection').hide();
<% } %>
        });
    </script>
</body>
</html>