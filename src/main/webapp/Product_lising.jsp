<%@page import="java.sql.*"%>
<%@page import="daos.ProductDAO"%>
<%@page import="models.Product"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");
    boolean isLoggedIn = userEmail != null;

    // Get all products from database
    ProductDAO productDAO = new ProductDAO();
    List<Product> products = productDAO.getAllAvailableProducts();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>All Products - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --secondary-color: #ffc107;
                --light-bg: #f8f9fa;
                --dark-bg: #343a40;
                --card-shadow: 0 5px 15px rgba(0,0,0,0.08);
                --hover-shadow: 0 10px 25px rgba(0,0,0,0.15);
                --border-radius: 12px;
                --transition: all 0.3s ease;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--light-bg);
                line-height: 1.6;
            }

            /* Navigation Styles */
            .navbar-brand {
                font-weight: 700;
                font-size: 1.4rem;
            }

            .nav-button {
                margin: 0 5px;
                border-radius: 6px;
                transition: var(--transition);
            }

            .nav-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            /* Header Styles */
            .page-header {
                background: linear-gradient(135deg, rgba(40, 167, 69, 0.9), rgba(33, 136, 56, 0.95)),
                    url('https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80');
                background-size: cover;
                background-position: center;
                color: white;
                padding: 80px 0 50px;
                margin-bottom: 40px;
                text-align: center;
                position: relative;
            }

            .page-header::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0,0,0,0.3);
            }

            .page-header .container {
                position: relative;
                z-index: 2;
            }

            /* Product Card Styles */
            .product-card {
                transition: var(--transition);
                height: 100%;
                border: none;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                overflow: hidden;
                background: white;
            }

            .product-card:hover {
                transform: translateY(-8px);
                box-shadow: var(--hover-shadow);
            }

            .product-image {
                height: 250px;
                object-fit: cover;
                width: 100%;
                transition: var(--transition);
            }

            .product-card:hover .product-image {
                transform: scale(1.05);
            }

            .product-category {
                background: var(--primary-color);
                color: white;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 600;
                display: inline-block;
            }

            .product-price {
                color: var(--primary-color);
                font-weight: 700;
                font-size: 1.3rem;
            }

            .product-quantity {
                color: #6c757d;
                font-size: 0.9rem;
            }

            .product-description {
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                color: #6c757d;
                line-height: 1.4;
            }

            /* Filter Section Styles */
            .filter-section {
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                padding: 25px;
                margin-bottom: 25px;
                position: sticky;
                top: 20px;
            }

            .filter-header {
                border-bottom: 3px solid var(--primary-color);
                padding-bottom: 15px;
                margin-bottom: 20px;
            }

            /* Stats Card Styles */
            .stats-card {
                background: white;
                border-radius: var(--border-radius);
                padding: 25px;
                text-align: center;
                box-shadow: var(--card-shadow);
                border-left: 4px solid var(--primary-color);
                transition: var(--transition);
            }

            .stats-card:hover {
                transform: translateY(-3px);
                box-shadow: var(--hover-shadow);
            }

            .stats-number {
                font-size: 2.2rem;
                font-weight: 700;
                color: var(--primary-color);
                margin-bottom: 5px;
            }

            .stats-label {
                color: #6c757d;
                font-size: 0.9rem;
                font-weight: 500;
            }

            /* Cart Styles */
            .cart-sidebar {
                width: 400px;
                transform: translateX(100%);
                transition: var(--transition);
                z-index: 1050;
                box-shadow: -5px 0 15px rgba(0,0,0,0.1);
                background-color: white;
            }

            .cart-sidebar.open {
                transform: translateX(0);
            }

            .cart-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.5);
                z-index: 1040;
                display: none;
            }

            .cart-overlay.active {
                display: block;
            }

            .cart-item-img {
                width: 70px;
                height: 70px;
                object-fit: cover;
                border-radius: 8px;
            }

            /* Search Box Styles */
            .search-box {
                max-width: 700px;
                margin: 0 auto 30px;
            }

            .search-box .form-control {
                border-radius: 50px;
                padding: 15px 25px;
                font-size: 1.1rem;
                border: 2px solid transparent;
            }

            .search-box .form-control:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
            }

            .search-box .btn {
                border-radius: 50px;
                padding: 15px 30px;
                font-weight: 600;
            }

            /* User Welcome Styles */
            .user-welcome {
                color: white;
                margin-right: 15px;
                display: flex;
                align-items: center;
                font-weight: 500;
            }

            /* Toast Styles */
            .toast-container {
                z-index: 1060;
            }

            /* List View Styles */
            .list-view .product-card {
                flex-direction: row !important;
                align-items: center;
            }

            .list-view .product-image {
                width: 200px !important;
                height: 150px !important;
                border-radius: var(--border-radius) 0 0 var(--border-radius);
            }

            /* Section Spacing */
            .section-spacing {
                padding: 60px 0;
            }

            /* Demand Forecast Styles */
            .demand-forecast-section {
                background: linear-gradient(135deg, #f8f9fa 0%, #e9f7ef 100%);
            }

            .forecast-card {
                background: white;
                border-radius: var(--border-radius);
                padding: 20px;
                text-align: center;
                box-shadow: var(--card-shadow);
                transition: var(--transition);
                height: 100%;
                border-top: 4px solid var(--primary-color);
            }

            .forecast-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }

            /* Badge Styles */
            .badge-low-stock {
                background: linear-gradient(135deg, #ffc107, #ffb300);
                color: #000;
            }

            .badge-out-stock {
                background: linear-gradient(135deg, #dc3545, #c82333);
                color: white;
            }

            /* Button Styles */
            .btn-success {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                border: none;
                font-weight: 600;
                transition: var(--transition);
            }

            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
            }

            .btn-warning {
                background: linear-gradient(135deg, #ffc107, #ffb300);
                border: none;
                color: #000;
                font-weight: 600;
                transition: var(--transition);
            }

            .btn-warning:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 193, 7, 0.3);
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .cart-sidebar {
                    width: 100%;
                }

                .nav-button {
                    margin: 2px 0;
                    width: 100%;
                }

                .product-image {
                    height: 200px;
                }

                .list-view .product-card {
                    flex-direction: column !important;
                }

                .list-view .product-image {
                    width: 100% !important;
                    height: 200px !important;
                    border-radius: var(--border-radius) var(--border-radius) 0 0;
                }

                .page-header {
                    padding: 60px 0 30px;
                }

                .stats-card {
                    margin-bottom: 15px;
                }

                .search-box .form-control {
                    font-size: 1rem;
                    padding: 12px 20px;
                }

                .search-box .btn {
                    padding: 12px 25px;
                }
            }

            @media (max-width: 576px) {
                .page-header h1 {
                    font-size: 2rem;
                }

                .stats-number {
                    font-size: 1.8rem;
                }

                .filter-section {
                    padding: 20px;
                }
            }

            /* Loading Animation */
            .loading-spinner {
                color: var(--primary-color);
            }

            /* No Results Styles */
            .no-results {
                text-align: center;
                padding: 60px 20px;
            }

            .no-results i {
                font-size: 4rem;
                color: #6c757d;
                margin-bottom: 20px;
            }

            /* Footer Styles */
            .footer {
                background: var(--dark-bg);
                color: white;
                padding: 40px 0 20px;
                margin-top: 60px;
            }

            /* Modal Styles */
            .modal-header {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
            }

            /* Form Control Styles */
            .form-control:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
            }

            .form-select:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
            }

            /* Range Slider Styles */
            .form-range::-webkit-slider-thumb {
                background: var(--primary-color);
            }

            .form-range::-moz-range-thumb {
                background: var(--primary-color);
            }

            /* Checkbox Styles */
            .form-check-input:checked {
                background-color: var(--primary-color);
                border-color: var(--primary-color);
            }
        </style>
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-leaf me-2"></i>AgriYouth Marketplace
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <div class="navbar-nav me-auto">
                        <a class="btn btn-outline-light nav-button" href="index.jsp">
                            <i class="fas fa-home me-1"></i>Home
                        </a>
                        <a class="btn btn-light nav-button" href="analytics.jsp">
                            <i class="fas fa-store me-1"></i>Product Demand Analytics  
                        </a>
                        <% if (isLoggedIn) { %>
                        <% if ("FARMER".equals(session.getAttribute("userRole"))) { %>
                        <a class="btn btn-outline-light nav-button" href="farmers_dashboard.jsp">
                            <i class="fas fa-tachometer-alt me-1"></i>My Dashboard
                        </a>
                        <% } else { %>
                        <a class="btn btn-outline-light nav-button" href="buyer_dashboard.jsp">
                            <i class="fas fa-tachometer-alt me-1"></i>My Dashboard
                        </a>
                        <% } %>
                        <% } else { %>
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-tachometer-alt me-1"></i>My Dashboard
                        </button>
                        <% } %>
                    </div>

                    <div class="navbar-nav ms-auto">
                        <% if (isLoggedIn) {%>
                        <span class="user-welcome">
                            <i class="fas fa-user me-1"></i>Welcome, <%= userName != null ? userName : userEmail%>
                        </span>
                        <a class="btn btn-outline-light nav-button" href="LogoutServlet">
                            <i class="fas fa-sign-out-alt me-1"></i>Logout
                        </a>
                        <% } else { %>
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-sign-in-alt me-1"></i>Sign In
                        </button>
                        <button class="btn btn-light nav-button" data-bs-toggle="modal" data-bs-target="#registerModal">
                            <i class="fas fa-user-plus me-1"></i>Register
                        </button>
                        <% }%>
                        <button class="btn btn-warning nav-button position-relative" id="cartButton">
                            <i class="fas fa-shopping-cart me-1"></i>Cart 
                            <span class="badge bg-danger position-absolute top-0 start-100 translate-middle rounded-pill" id="cartCount">0</span>
                        </button>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Page Header Section -->
        <header class="page-header">
            <div class="container">
                <h1 class="display-4 fw-bold mb-3">All Products</h1>
                <p class="lead mb-4">Discover our complete collection of fresh agricultural products from local farmers</p>

                <!-- Search Box -->
                <div class="search-box">
                    <form class="d-flex" id="searchForm">
                        <input class="form-control me-2" id="searchInput" type="search" 
                               placeholder="Search products by name, category, or description...">
                        <button class="btn btn-warning" type="submit">
                            <i class="fas fa-search me-2"></i>Search
                        </button>
                    </form>
                </div>
            </div>
        </header>

        <!-- Main Content Section -->
        <main class="main-content">
            <div class="container">
                <!-- Statistics Section -->
                <section class="stats-section mb-5">
                    <div class="row g-4">
                        <div class="col-md-3 col-6">
                            <div class="stats-card">
                                <div class="stats-number"><%= products.size()%></div>
                                <div class="stats-label">Total Products</div>
                            </div>
                        </div>
                        <div class="col-md-3 col-6">
                            <%
                                long categoryCount = products.stream()
                                        .map(Product::getCategory)
                                        .distinct()
                                        .count();
                            %>
                            <div class="stats-card">
                                <div class="stats-number"><%= categoryCount%></div>
                                <div class="stats-label">Categories</div>
                            </div>
                        </div>
                        <div class="col-md-3 col-6">
                            <%
                                long farmerCount = products.stream()
                                        .map(Product::getUserId)
                                        .distinct()
                                        .count();
                            %>
                            <div class="stats-card">
                                <div class="stats-number"><%= farmerCount%></div>
                                <div class="stats-label">Active Farmers</div>
                            </div>
                        </div>
                        <div class="col-md-3 col-6">
                            <%
                                double totalStock = products.stream()
                                        .mapToDouble(Product::getQuantity)
                                        .sum();
                            %>
                            <div class="stats-card">
                                <div class="stats-number"><%= String.format("%.0f", totalStock)%></div>
                                <div class="stats-label">Total Stock Available</div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Products Section -->
                <section class="products-section">
                    <div class="row">
                        <!-- Filters Sidebar -->
                        <div class="col-lg-3 mb-4">
                            <div class="filter-section">
                                <div class="filter-header">
                                    <h5><i class="fas fa-filter me-2"></i>Filter Products</h5>
                                </div>

                                <!-- Category Filter -->
                                <div class="mb-4">
                                    <h6 class="fw-bold mb-3">Category</h6>
                                    <%
                                        List<String> categories = products.stream()
                                                .map(Product::getCategory)
                                                .distinct()
                                                .sorted()
                                                .collect(java.util.stream.Collectors.toList());

                                        for (String category : categories) {
                                            String safeId = category.replaceAll("[^a-zA-Z0-9]", "-").toLowerCase();
                                    %>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input category-filter" type="checkbox" 
                                               value="<%= category%>" id="cat-<%= safeId%>">
                                        <label class="form-check-label" for="cat-<%= safeId%>">
                                            <%= category%>
                                        </label>
                                    </div>
                                    <% }%>
                                </div>

                                <!-- Price Range Filter -->
                                <div class="mb-4">
                                    <h6 class="fw-bold mb-3">Price Range</h6>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>M 0</span>
                                        <span>M 1000</span>
                                    </div>
                                    <input type="range" class="form-range" id="priceRange" min="0" max="1000" value="1000">
                                    <div class="text-center mt-2">
                                        <small class="fw-bold">Max: M <span id="priceRangeValue">1000</span></small>
                                    </div>
                                </div>

                                <!-- Sort Options -->
                                <div class="mb-4">
                                    <h6 class="fw-bold mb-3">Sort By</h6>
                                    <select class="form-select" id="sortSelect">
                                        <option value="newest">Newest First</option>
                                        <option value="price_low">Price: Low to High</option>
                                        <option value="price_high">Price: High to Low</option>
                                        <option value="name_asc">Name: A to Z</option>
                                        <option value="name_desc">Name: Z to A</option>
                                    </select>
                                </div>

                                <!-- Stock Availability -->
                                <div class="mb-4">
                                    <h6 class="fw-bold mb-3">Stock Status</h6>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input stock-filter" type="checkbox" value="in_stock" id="stock-in" checked>
                                        <label class="form-check-label" for="stock-in">
                                            In Stock
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input stock-filter" type="checkbox" value="low_stock" id="stock-low">
                                        <label class="form-check-label" for="stock-low">
                                            Low Stock (< 10)
                                        </label>
                                    </div>
                                </div>

                                <!-- Action Buttons -->
                                <div class="d-grid gap-2">
                                    <button id="applyFilters" class="btn btn-success">
                                        <i class="fas fa-check me-2"></i>Apply Filters
                                    </button>
                                    <button id="resetFilters" class="btn btn-outline-secondary">
                                        <i class="fas fa-redo me-2"></i>Reset Filters
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Products Grid -->
                        <div class="col-lg-9">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h3 class="fw-bold">Available Products <span class="badge bg-success fs-6">(<%= products.size()%>)</span></h3>
                                <div class="d-flex align-items-center">
                                    <span class="me-2 fw-medium">View:</span>
                                    <select class="form-select form-select-sm w-auto" id="viewSelect">
                                        <option value="grid">Grid View</option>
                                        <option value="list">List View</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Products Grid -->
                            <div class="row g-4" id="productList">
                                <%
                                    for (Product product : products) {
                                        String description = product.getDescription();
                                        if (description == null) {
                                            description = "No description available";
                                        }
                                        if (description.length() > 100)
                                            description = description.substring(0, 100) + "...";
                                %>
                                <div class="col-xl-4 col-lg-6 product-item">
                                    <div class="card product-card h-100">
                                        <img src="ImageServlet?id=<%= product.getId()%>" 
                                             class="card-img-top product-image" 
                                             alt="<%= product.getName()%>"
                                             onerror="this.onerror=null; this.src='https://placehold.co/400x300/28a745/ffffff?text=No+Image'">
                                        <div class="card-body d-flex flex-column">
                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                <span class="product-category"><%= product.getCategory()%></span>
                                                <% if (product.getQuantity() < 10 && product.getQuantity() > 0) { %>
                                                <span class="badge badge-low-stock">Low Stock</span>
                                                <% } else if (product.getQuantity() == 0) { %>
                                                <span class="badge badge-out-stock">Out of Stock</span>
                                                <% }%>
                                            </div>
                                            <h5 class="card-title fw-bold"><%= product.getName()%></h5>
                                            <p class="card-text product-description flex-grow-1">
                                                <%= description%>
                                            </p>
                                            <div class="mt-auto">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <span class="product-price">M <%= String.format("%.2f", product.getPrice())%></span>
                                                    <span class="product-quantity">
                                                        <i class="fas fa-box me-1"></i>
                                                        <%= product.getQuantity()%> <%= product.getUnit()%>
                                                    </span>
                                                </div>
                                                <button class="btn btn-success w-100 add-to-cart-btn" 
                                                        data-product-id="<%= product.getId()%>" 
                                                        data-product-name="<%= product.getName()%>" 
                                                        data-product-price="<%= product.getPrice()%>" 
                                                        data-product-image="ImageServlet?id=<%= product.getId()%>"
                                                        <%= product.getQuantity() == 0 ? "disabled" : ""%>>
                                                    <i class="fas fa-cart-plus me-2"></i> 
                                                    <%= product.getQuantity() == 0 ? "Out of Stock" : "Add to Cart"%>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>

                            <!-- Loading Indicator -->
                            <div id="loadingIndicator" class="text-center mt-4 d-none">
                                <div class="spinner-border loading-spinner" style="width: 3rem; height: 3rem;" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-3 text-muted">Loading products...</p>
                            </div>

                            <!-- No Results Message -->
                            <div id="noResults" class="no-results d-none">
                                <i class="fas fa-search"></i>
                                <h4 class="text-muted mb-3">No products found</h4>
                                <p class="text-muted mb-4">Try adjusting your search or filters</p>
                                <button id="resetSearch" class="btn btn-success">Reset Search</button>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </main>

        <!-- Demand Forecast Section -->
        <section class="demand-forecast-section section-spacing">
            <div class="container">
                <div class="row mb-4">
                    <div class="col-12 text-center">
                        <h3 class="fw-bold text-success mb-3">
                            <i class="fas fa-chart-line me-2"></i>Crop Demand Forecast
                        </h3>
                        <p class="lead text-muted">Market insights to help you make informed decisions</p>
                    </div>
                </div>
                <div id="demandForecast" class="row">
                    <div class="col-12 text-center">
                        <div class="spinner-border loading-spinner" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3 text-muted">Analyzing crop trends and market demand...</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer Section -->
        <footer class="footer">
            <div class="container">
                <div class="row">
                    <div class="col-12 text-center">
                        <p class="mb-0">&copy; 2025 AgriYouth Marketplace. All rights reserved.</p>
                        <p class="mt-2 mb-0 text-muted">Empowering youth in agriculture</p>
                    </div>
                </div>
            </div>
        </footer>

        <!-- Cart Overlay -->
        <div class="cart-overlay" id="cartOverlay"></div>

        <!-- Cart Sidebar -->
        <div class="cart-sidebar position-fixed top-0 end-0 h-100 bg-white p-4 overflow-auto" id="cartSidebar">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="m-0 fw-bold"><i class="fas fa-shopping-cart me-2"></i>Your Cart</h4>
                <button class="btn btn-sm btn-outline-secondary rounded-circle" onclick="closeCart()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Cart Items -->
            <div id="cartItems">
                <p class="text-muted text-center py-5" id="emptyCartMessage">
                    <i class="fas fa-shopping-cart fa-2x mb-3 d-block"></i>
                    Your cart is empty
                </p>
            </div>

            <!-- Cart Summary -->
            <div id="cartSummary" class="mt-4 d-none">
                <hr>
                <div class="d-flex justify-content-between mb-3">
                    <strong>Subtotal:</strong>
                    <strong id="cartSubtotal">M 0.00</strong>
                </div>
                <div class="d-flex justify-content-between mb-3">
                    <span>Shipping:</span>
                    <span id="shippingCost">M 0.00</span>
                </div>
                <div class="d-flex justify-content-between mb-4">
                    <strong>Total:</strong>
                    <strong id="cartTotal">M 0.00</strong>
                </div>
                <% if (isLoggedIn) { %>
                <button class="btn btn-success w-100 py-3 fw-bold" id="checkoutBtn">
                    <i class="fas fa-credit-card me-2"></i>Proceed to Checkout
                </button>
                <% } else { %>
                <button class="btn btn-warning w-100 py-3 fw-bold" data-bs-toggle="modal" data-bs-target="#loginModal">
                    <i class="fas fa-sign-in-alt me-2"></i>Login to Checkout
                </button>
                <% }%>
            </div>
        </div>

        <!-- Toast Container -->
        <div class="toast-container position-fixed top-0 end-0 p-3"></div>

        <!-- Login Modal -->
        <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold" id="loginModalLabel">
                            <i class="fas fa-sign-in-alt me-2"></i>Sign In
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="LoginServlet" method="post" autocomplete="off">
                            <div class="mb-3">
                                <label for="email" class="form-label fw-medium">Email Address</label>
                                <input type="email" name="email" id="email" class="form-control" placeholder="Enter your email" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label fw-medium">Password</label>
                                <input type="password" name="password" id="password" class="form-control" placeholder="Enter your password" required>
                            </div>
                            <div class="d-grid mb-3">
                                <button type="submit" class="btn btn-success py-2 fw-bold">
                                    <i class="fas fa-sign-in-alt me-2"></i>Login
                                </button>
                            </div>
                        </form>
                        <div class="text-center">
                            <p class="mb-0">Don't have an account? 
                                <a href="#" class="text-success fw-bold" data-bs-toggle="modal" data-bs-target="#registerModal" data-bs-dismiss="modal">
                                    Register here
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Register Modal -->
        <div class="modal fade" id="registerModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold">Create Your Account</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form action="RegisterServlet" method="post">
                            <div class="mb-3">
                                <label class="form-label fw-medium">First Name</label>
                                <input type="text" class="form-control" name="first_name" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-medium">Last Name</label>
                                <input type="text" class="form-control" name="last_name" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-medium">Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-medium">Password</label>
                                <input type="password" class="form-control" name="password" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-medium">Role</label>
                                <select name="role" class="form-select" required>
                                    <option value="">Select Role</option>
                                    <option value="BUYER">Buyer</option>
                                    <option value="FARMER">Farmer</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-success w-100 py-2 fw-bold">Register</button>
                        </form>
                    </div>
                    <div class="modal-footer text-center">
                        <p class="w-100 mb-0">
                            Already have an account? 
                            <a href="#" class="text-success fw-bold" data-bs-toggle="modal" data-bs-target="#loginModal" data-bs-dismiss="modal">Sign In</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                          // Demand Forecast JavaScript
                          document.addEventListener('DOMContentLoaded', function () {
                              fetch('demandForecast')
                                      .then(res => res.json())
                                      .then(data => {
                                          let html = '';
                                          Object.entries(data).forEach(([crop, details]) => {
                                              html += `
                              <div class="col-md-3 col-6 mb-4">
                                  <div class="forecast-card">
                                      <h6 class="fw-bold mb-3">${crop}</h6>
                                      <p class="mb-2">
                                          <strong>Predicted Demand:</strong> ${details.predicted.toFixed(1)} listings
                                      </p>
                                      <p class="mb-0">
                                          <span class="badge bg-${details.trend == 'Increasing' ? 'success' : (details.trend == 'Decreasing' ? 'danger' : 'secondary')}">
            ${details.trend} Trend
                                          </span>
                                      </p>
                                  </div>
                              </div>
                          `;
                                          });
                                          document.getElementById('demandForecast').innerHTML = html;
                                      })
                                      .catch(err => {
                                          document.getElementById('demandForecast').innerHTML = `
                          <div class="col-12 text-center">
                              <i class="fas fa-exclamation-triangle fa-2x text-warning mb-3"></i>
                              <p class="text-muted">Unable to load demand forecast data at this time.</p>
                          </div>
                      `;
                                          console.error('Demand forecast error:', err);
                                      });

                              // Initialize cart display
                              initializeCart();
                          });

                          // Cart functionality
                          function initializeCart() {
                              console.log('Initializing cart...');

                              $.post("CartServlet", {action: "get"}, function (data) {
                                  console.log('Initial cart data:', data);
                                  if (data.success) {
                                      updateCartDisplay(data.cart);
                                  }
                              }, "json").fail(function (xhr, status, error) {
                                  console.error('Failed to load cart:', error);
                              });
                          }

                          function addToCart(id, name, price, image) {
                              console.log('=== ADD TO CART DEBUG ===');
                              console.log('Product ID:', id, 'Type:', typeof id);

                              // Ensure ID is a number
                              const productId = parseInt(id);
                              if (isNaN(productId)) {
                                  console.error('Invalid product ID:', id);
                                  showToast('Error: Invalid product ID', 'error');
                                  return;
                              }

                              $.post("CartServlet", {
                                  action: "add",
                                  id: productId,
                                  qty: 1
                              }, function (data) {
                                  console.log('Cart response:', data);
                                  if (data.success) {
                                      updateCartDisplay(data.cart);
                                      showToast(name + ' added to cart!', 'success');
                                  } else {
                                      showToast(data.message, 'error');
                                  }
                              }, "json").fail(function (xhr, status, error) {
                                  console.error('Cart AJAX error:', error);
                                  showToast('Error adding to cart. Please try again.', 'error');
                              });
                          }

                          function removeFromCart(id) {
                              const productId = parseInt(id);
                              if (isNaN(productId) || productId <= 0) {
                                  console.error('Invalid product ID:', productId);
                                  showToast('Invalid product ID', 'error');
                                  return;
                              }

                              $.post("CartServlet", {
                                  action: "remove",
                                  id: productId
                              }, function (data) {
                                  console.log('Server response:', data);

                                  if (data.success) {
                                      updateCartDisplay(data.cart);
                                      showToast('Item removed from cart', 'success');

                                      if (!data.cart || data.cart.length === 0) {
                                          closeCart();
                                      }
                                  } else {
                                      showToast(data.message, 'error');
                                  }
                              }, "json").fail(function (xhr, status, error) {
                                  console.error('Remove cart error:', error);
                                  showToast('Error removing item from cart. Please try again.', 'error');
                              });
                          }

                          function updateCartDisplay(cart) {
                              console.log('Updating cart display:', cart);
                              let cartItems = $("#cartItems");
                              cartItems.html("");
                              let total = 0;

                              if (!cart || cart.length === 0) {
                                  $("#emptyCartMessage").removeClass("d-none");
                                  $("#cartSummary").addClass("d-none");
                                  $("#cartCount").text("0");
                                  return;
                              }

                              $("#emptyCartMessage").addClass("d-none");

                              cart.forEach(item => {
                                  const price = parseFloat(item.price) || 0;
                                  const quantity = parseInt(item.qty) || 0;
                                  const itemTotal = price * quantity;
                                  total += itemTotal;

                                  let imageUrl = item.image;
                                  if (!imageUrl) {
                                      imageUrl = 'ImageServlet?id=' + item.id;
                                  }

                                  const cartItemElement = $(`
                      <div class="d-flex justify-content-between align-items-center border-bottom py-3 cart-item" data-product-id="${item.id}">
                          <div class="d-flex align-items-center">
                              <img src="${imageUrl}" class="cart-item-img rounded me-3" alt="${item.name}" 
                                   onerror="this.onerror=null; this.src='https://placehold.co/60x60/cccccc/ffffff?text=No+Image'">
                              <div>
                                  <strong class="d-block">${item.name}</strong>
                                  <small class="text-muted">M ${price.toFixed(2)} × ${quantity}</small>
                                  <br>
                                  <small class="text-success fw-bold">M ${itemTotal.toFixed(2)}</small>
                              </div>
                          </div>
                          <button class="btn btn-sm btn-outline-danger remove-cart-item" onclick="removeFromCart(${item.id})">
                              <i class="fas fa-trash"></i>
                          </button>
                      </div>
                  `);

                                  cartItems.append(cartItemElement);
                              });

                              $("#cartCount").text(cart.reduce((sum, item) => sum + (parseInt(item.qty) || 0), 0));
                              $("#cartSubtotal").text("M " + total.toFixed(2));
                              $("#cartTotal").text("M " + total.toFixed(2));
                              $("#cartSummary").removeClass("d-none");
                          }

                          function openCart() {
                              $("#cartSidebar").addClass("open");
                              $("#cartOverlay").addClass("active");
                              $("body").css("overflow", "hidden");
                          }

                          function closeCart() {
                              $("#cartSidebar").removeClass("open");
                              $("#cartOverlay").removeClass("active");
                              $("body").css("overflow", "auto");
                          }

                          // Fixed Toast Function
                          function showToast(message, type = 'success') {
                              const toastId = 'toast-' + Date.now();
                              const bgColor = type === 'success' ? 'bg-success' : 'bg-danger';
                              const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';

                              const toastHtml = `
                  <div id="${toastId}" class="toast align-items-center text-white ${bgColor} border-0" role="alert" aria-live="assertive" aria-atomic="true">
                      <div class="d-flex">
                          <div class="toast-body">
                              <i class="fas ${icon} me-2"></i>${message}
                          </div>
                          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                      </div>
                  </div>
              `;

                              $('.toast-container').append(toastHtml);
                              const toastElement = document.getElementById(toastId);

                              // Create and show toast with proper Bootstrap initialization
                              const toast = new bootstrap.Toast(toastElement, {
                                  delay: 3000,
                                  autohide: true
                              });

                              toast.show();

                              // Remove toast from DOM after it's hidden
                              toastElement.addEventListener('hidden.bs.toast', function () {
                                  $(this).remove();
                              });
                          }

                          // Checkout button handler - FIXED
                          $("#checkoutBtn").click(function (e) {
                              e.preventDefault();
                              e.stopPropagation();
                              console.log('Checkout button clicked');

                              $.post("CartServlet", {action: "checkout"}, function (cartData) {
                                  console.log('Checkout validation response:', cartData);
                                  if (cartData.success) {
                                      showCheckoutForm();
                                  } else {
                                      showToast(cartData.message, 'error');
                                  }
                              }, "json").fail(function (xhr, status, error) {
                                  console.error('Checkout validation error:', error);
                                  showToast('Error validating cart. Please try again.', 'error');
                              });
                          });

                          // Show checkout form modal - FIXED
                          function showCheckoutForm() {
                              const userEmail = '<%= session.getAttribute("userEmail") != null ? session.getAttribute("userEmail") : ""%>';
                              const userName = '<%= session.getAttribute("userName") != null ? session.getAttribute("userName") : ""%>';

                              // Remove existing modal if any
                              if ($('#checkoutModal').length) {
                                  $('#checkoutModal').remove();
                              }

                              const checkoutForm = `
                  <div class="modal fade" id="checkoutModal" tabindex="-1" aria-labelledby="checkoutModalLabel" aria-hidden="true">
                      <div class="modal-dialog modal-lg">
                          <div class="modal-content">
                              <div class="modal-header bg-success text-white">
                                  <h5 class="modal-title fw-bold" id="checkoutModalLabel">
                                      <i class="fas fa-shopping-bag me-2"></i>Complete Your Order
                                  </h5>
                                  <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                              </div>
                              <div class="modal-body">
                                  <form id="checkoutForm" novalidate>
                                      <div class="row">
                                          <div class="col-md-6 mb-3">
                                              <label class="form-label fw-bold">First Name *</label>
                                              <input type="text" class="form-control" name="firstName" required
                                                     value="${userName.split(' ')[0] || ''}">
                                              <div class="invalid-feedback">Please enter your first name</div>
                                          </div>
                                          <div class="col-md-6 mb-3">
                                              <label class="form-label fw-bold">Last Name *</label>
                                              <input type="text" class="form-control" name="lastName" required
                                                     value="${userName.split(' ')[1] || ''}">
                                              <div class="invalid-feedback">Please enter your last name</div>
                                          </div>
                                          <div class="col-12 mb-3">
                                              <label class="form-label fw-bold">Email Address for Receipt *</label>
                                              <input type="email" class="form-control" name="email" required
                                                     value="${userEmail}" placeholder="Enter email to receive receipt">
                                              <div class="form-text">We'll send your order confirmation to this email</div>
                                              <div class="invalid-feedback">Please enter a valid email address</div>
                                          </div>
                                          <div class="col-12 mb-3">
                                              <label class="form-label fw-bold">Delivery Address *</label>
                                              <textarea class="form-control" name="deliveryAddress" required 
                                                        placeholder="Enter your complete delivery address including street, city, and any specific instructions..." 
                                                        rows="3"></textarea>
                                              <div class="form-text">We'll deliver your order to this address</div>
                                              <div class="invalid-feedback">Please enter your delivery address</div>
                                          </div>
                                          <div class="col-md-6 mb-3">
                                              <label class="form-label fw-bold">Phone Number *</label>
                                              <input type="tel" class="form-control" name="phoneNumber" required
                                                     placeholder="Enter your phone number">
                                              <div class="form-text">For delivery updates</div>
                                              <div class="invalid-feedback">Please enter your phone number</div>
                                          </div>
                                          <div class="col-md-6 mb-3">
                                              <label class="form-label fw-bold">Payment Method *</label>
                                              <select class="form-select" name="paymentMethod" required>
                                                  <option value="">Select payment method</option>
                                                  <option value="CASH" selected>Cash on Delivery</option>
                                                  <option value="MOBILE_MONEY">Mobile Money</option>
                                                  <option value="BANK_TRANSFER">Bank Transfer</option>
                                              </select>
                                              <div class="invalid-feedback">Please select a payment method</div>
                                          </div>
                                      </div>
                                      <div class="alert alert-info">
                                          <i class="fas fa-info-circle me-2"></i>
                                          Please review your order in the cart before proceeding. You'll receive an email confirmation after checkout.
                                      </div>
                                  </form>
                              </div>
                              <div class="modal-footer">
                                  <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                      <i class="fas fa-times me-1"></i> Cancel
                                  </button>
                                  <button type="button" class="btn btn-success" id="confirmCheckoutBtn">
                                      <i class="fas fa-check me-1"></i> Place Order
                                  </button>
                              </div>
                          </div>
                      </div>
                  </div>
              `;

                              $('body').append(checkoutForm);

                              // Initialize the modal
                              const checkoutModal = new bootstrap.Modal(document.getElementById('checkoutModal'));

                              // Add event listener for the confirm button
                              $('#confirmCheckoutBtn').off('click').on('click', function () {
                                  processCheckout();
                              });

                              checkoutModal.show();

                              // Focus on first input after modal is shown
                              $('#checkoutModal').on('shown.bs.modal', function () {
                                  $('#checkoutForm input[name="firstName"]').focus();
                              });
                          }

                          // Process final checkout with CheckoutServlet - FIXED
                          function processCheckout() {
                              const form = document.getElementById('checkoutForm');

                              if (!form.checkValidity()) {
                                  form.classList.add('was-validated');
                                  // Show first error message
                                  const firstInvalid = form.querySelector(':invalid');
                                  if (firstInvalid) {
                                      firstInvalid.focus();
                                  }
                                  return;
                              }

                              const formData = new FormData(form);

                              const confirmBtn = $('#confirmCheckoutBtn');
                              const originalText = confirmBtn.html();
                              confirmBtn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Processing...');

                              $.post("CheckoutServlet", {
                                  firstName: formData.get('firstName'),
                                  lastName: formData.get('lastName'),
                                  email: formData.get('email'),
                                  deliveryAddress: formData.get('deliveryAddress'),
                                  phoneNumber: formData.get('phoneNumber'),
                                  paymentMethod: formData.get('paymentMethod')
                              }, function (data) {
                                  console.log('Checkout response:', data);
                                  if (data.success) {
                                      showToast('Order placed successfully! Order ID: #' + data.orderId, 'success');

                                      updateCartDisplay([]);
                                      closeCart();

                                      const checkoutModal = bootstrap.Modal.getInstance(document.getElementById('checkoutModal'));
                                      if (checkoutModal) {
                                          checkoutModal.hide();
                                      }

                                      // Remove modal from DOM after hiding
                                      setTimeout(() => {
                                          $('#checkoutModal').remove();
                                      }, 500);

                                  } else {
                                      showToast(data.message, 'error');
                                  }
                              }, "json").fail(function (xhr, status, error) {
                                  console.error('Checkout error:', error);
                                  showToast('Error processing your order. Please try again.', 'error');
                              }).always(function () {
                                  confirmBtn.prop('disabled', false).html(originalText);
                              });
                          }

                          // Search and Filter functionality
                          $(document).ready(function () {
                              console.log('Document ready - initializing event listeners...');

                              // Add to cart button event delegation
                              $(document).on('click', '.add-to-cart-btn:not(:disabled)', function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();

                                  const id = $(this).data('product-id');
                                  const name = $(this).data('product-name');
                                  const price = $(this).data('product-price');
                                  const image = $(this).data('product-image');
                                  console.log('Add to cart clicked:', {id, name, price, image});
                                  addToCart(id, name, price, image);
                              });

                              // Cart button click
                              $("#cartButton").click(function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  openCart();
                              });

                              // Overlay click to close cart
                              $("#cartOverlay").click(function (e) {
                                  e.stopPropagation();
                                  closeCart();
                              });

                              // Price range display
                              $("#priceRange").on("input", function () {
                                  $("#priceRangeValue").text($(this).val());
                              });

                              // Search form submission
                              $("#searchForm").on("submit", function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  applyFilters();
                              });

                              // Apply filters button
                              $("#applyFilters").on("click", function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  applyFilters();
                              });

                              // Reset filters button
                              $("#resetFilters").on("click", function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  $(".category-filter").prop("checked", false);
                                  $(".stock-filter").prop("checked", false);
                                  $("#stock-in").prop("checked", true);
                                  $("#priceRange").val(1000);
                                  $("#priceRangeValue").text("1000");
                                  $("#sortSelect").val("newest");
                                  $("#searchInput").val("");
                                  applyFilters();
                              });

                              // Reset search button
                              $("#resetSearch").on("click", function (e) {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  $("#searchInput").val("");
                                  applyFilters();
                              });

                              // Sort selection change
                              $("#sortSelect").on("change", function () {
                                  applyFilters();
                              });

                              // View selection change
                              $("#viewSelect").on("change", function () {
                                  const viewType = $(this).val();
                                  const productList = $("#productList");
                                  const productItems = $(".product-item");
                                  const productCards = $(".product-card");
                                  const productImages = $(".product-image");

                                  if (viewType === "list") {
                                      productList.addClass("list-view");
                                      productItems.removeClass("col-xl-4 col-lg-6").addClass("col-12");
                                      productCards.addClass("flex-row");
                                      productImages.css({"height": "150px", "width": "200px"});
                                  } else {
                                      productList.removeClass("list-view");
                                      productItems.removeClass("col-12").addClass("col-xl-4 col-lg-6");
                                      productCards.removeClass("flex-row");
                                      productImages.css({"height": "250px", "width": "100%"});
                                  }
                              });

                              // Close cart with Escape key
                              $(document).keyup(function (e) {
                                  if (e.key === "Escape") {
                                      closeCart();
                                  }
                              });

                              // Initialize Bootstrap components
                              initializeBootstrapComponents();
                          });

                          function applyFilters() {
                              const selectedCategories = [];
                              $(".category-filter:checked").each(function () {
                                  selectedCategories.push($(this).val());
                              });

                              const maxPrice = $("#priceRange").val();
                              const searchTerm = $("#searchInput").val();
                              const sortBy = $("#sortSelect").val();

                              console.log('Applying filters:', {selectedCategories, maxPrice, searchTerm, sortBy});

                              // Show loading indicator
                              $("#loadingIndicator").removeClass("d-none");
                              $("#noResults").addClass("d-none");

                              // Send AJAX request to filter servlet
                              $.get("ProductFilterServlet", {
                                  category: selectedCategories.join(","),
                                  price_max: maxPrice,
                                  search: searchTerm,
                                  sort: sortBy
                              }, function (data) {
                                  $("#productList").html(data);
                                  $("#loadingIndicator").addClass("d-none");

                                  // Show no results message if no products found
                                  if ($("#productList").children().length === 0) {
                                      $("#noResults").removeClass("d-none");
                                  }
                              }).fail(function (xhr, status, error) {
                                  console.error('Filter error:', error);
                                  showToast("Error applying filters. Please try again.", 'error');
                                  $("#loadingIndicator").addClass("d-none");
                              });
                          }

                          // Initialize Bootstrap Components
                          function initializeBootstrapComponents() {
                              // Initialize all tooltips
                              var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
                              var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                                  return new bootstrap.Tooltip(tooltipTriggerEl)
                              });

                              // Initialize any popovers
                              var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
                              var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
                                  return new bootstrap.Popover(popoverTriggerEl)
                              });
                          }

                          // Product Tracking System
                          function trackUserAction(actionType, productId = null, searchQuery = null, category = null) {
                              console.log('Tracking:', {actionType, productId, searchQuery, category});

                              $.post("ProductTrackingServlet", {
                                  action: actionType,
                                  productId: productId,
                                  searchQuery: searchQuery,
                                  category: category
                              }, function (response) {
                                  console.log('Tracking recorded:', response);
                              }).fail(function (xhr, status, error) {
                                  console.error('Tracking error:', error);
                              });
                          }

                          // Track product clicks
                          $(document).on('click', '.product-card, .product-image, .card-title', function (e) {
                              const productCard = $(this).closest('.product-item');
                              if (productCard.length) {
                                  const productId = productCard.find('.add-to-cart-btn').data('product-id');
                                  const category = productCard.find('.product-category').text();

                                  if (productId) {
                                      trackUserAction('product_click', productId, null, category);
                                  }
                              }
                          });

                          // Track search queries
                          $('#searchForm').on('submit', function (e) {
                              const searchQuery = $('#searchInput').val().trim();
                              if (searchQuery) {
                                  trackUserAction('search', null, searchQuery);
                              }
                          });

                          // Track add to cart actions
                          $(document).on('click', '.add-to-cart-btn:not(:disabled)', function () {
                              const productId = $(this).data('product-id');
                              const category = $(this).closest('.product-card').find('.product-category').text();

                              trackUserAction('add_to_cart', productId, null, category);
                          });

                          // Track category filter clicks
                          $(document).on('change', '.category-filter', function () {
                              if ($(this).is(':checked')) {
                                  const category = $(this).val();
                                  trackUserAction('category_view', null, null, category);
                              }
                          });

                          // Track page view
                          $(document).ready(function () {
                              trackUserAction('page_view');
                          });
        </script>
    </body>
</html>