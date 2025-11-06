<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String url = "jdbc:mysql://localhost:3306/agri_business";
    String username = "root";
    String password = "";

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM products WHERE is_available = 1");
    } catch (Exception e) {
        out.println("<p style='color:red'>Database connection error: " + e.getMessage() + "</p>");
    }

    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    boolean isLoggedIn = userEmail != null;
    String userRole = null;

    if (session != null && session.getAttribute("userEmail") != null) {
        isLoggedIn = true;
        userName = (String) session.getAttribute("userName");
        userEmail = (String) session.getAttribute("userEmail");
        userRole = (String) session.getAttribute("userRole");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --light-bg: #f8f9fa;
                --card-shadow: 0 5px 15px rgba(0,0,0,0.08);
                --hover-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--light-bg);
            }

            .navbar-brand {
                font-weight: 700;
                font-size: 1.4rem;
            }

            .nav-button {
                margin: 0 5px;
                border-radius: 6px;
                transition: all 0.3s ease;
            }

            .nav-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            .hero-section {
                background: linear-gradient(135deg, rgba(40, 100, 69, 0.85), rgba(33, 100, 56, 0.9)), url('https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80');
                background-size: cover;
                background-position: center;
                color: white;
                padding: 100px 0;
                margin-bottom: 30px;
            }

            .product-card {
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                height: 100%;
                border: none;
                border-radius: 10px;
                box-shadow: var(--card-shadow);
            }

            .product-card:hover {
                transform: translateY(-8px);
                box-shadow: var(--hover-shadow);
            }

            .product-image {
                height: 200px;
                object-fit: cover;
                width: 100%;
                border-radius: 10px 10px 0 0;
            }

            .cart-sidebar {
                width: 380px;
                transform: translateX(100%);
                transition: transform 0.3s ease-in-out;
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
                width: 60px;
                height: 60px;
                object-fit: cover;
                border-radius: 8px;
            }

            /* ===== AgriBot Chat ===== */
            #chatbot-button {
                position: fixed;
                bottom: 25px;
                right: 25px;
                background: #28a745;
                color: white;
                border-radius: 50%;
                width: 55px;
                height: 55px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                cursor: pointer;
                z-index: 1051;
                box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                transition: background 0.3s;
            }

            #chatbot-button:hover {
                background: #218838;
            }

            #chatbot-modal {
                display: none;
                position: fixed;
                bottom: 95px;
                right: 25px;
                width: 350px;
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 8px 25px rgba(0,0,0,0.3);
                z-index: 1050;
                overflow: hidden;
                flex-direction: column;
            }

            .chat-header {
                background: #28a745;
                color: white;
                padding: 12px 15px;
                font-weight: 600;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            #chat-window {
                max-height: 350px;
                overflow-y: auto;
                padding: 10px;
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .chat-message {
                padding: 10px 12px;
                border-radius: 8px;
                max-width: 80%;
                word-wrap: break-word;
            }

            .chat-bot {
                background: #e9f7ef;
                align-self: flex-start;
            }

            .chat-user {
                background: #d1e7dd;
                align-self: flex-end;
            }

            .chat-input {
                display: flex;
                padding: 8px;
                border-top: 1px solid #eee;
                background: #fafafa;
            }

            .chat-input input {
                flex: 1;
                margin-right: 6px;
            }

            .chat-input button {
                background: #28a745;
                border: none;
                color: white;
            }

            .chat-input button:hover {
                background: #218838;
            }

            .expert-links a {
                display: block;
                color: #198754;
                font-size: 0.9rem;
                margin-top: 3px;
                text-decoration: none;
            }

            .expert-links a:hover {
                text-decoration: underline;
            }

            .filter-sidebar {
                background: white;
                border-radius: 10px;
                box-shadow: var(--card-shadow);
                padding: 20px;
                margin-bottom: 20px;
            }

            .filter-header {
                border-bottom: 2px solid var(--primary-color);
                padding-bottom: 10px;
                margin-bottom: 15px;
            }

            .user-welcome {
                color: white;
                margin-right: 15px;
                display: flex;
                align-items: center;
            }

            .search-box {
                max-width: 600px;
                margin: 0 auto;
            }

            /* Market Trends Styles */
            .market-trends {
                background: linear-gradient(135deg, #f8f9fa 0%, #e9f7ef 100%);
            }

            .trend-card {
                transition: all 0.3s ease;
                border: none;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            }

            .trend-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            }

            .price-up {
                color: #28a745;
            }

            .price-down {
                color: #dc3545;
            }

            .price-stable {
                color: #6c757d;
            }

            .commodity-price {
                font-size: 1.4rem;
                font-weight: 700;
            }

            .news-item {
                border-left: 3px solid #28a745;
                padding-left: 15px;
                transition: all 0.3s ease;
            }

            .news-item:hover {
                background-color: #f8f9fa;
                border-left-color: #218838;
            }

            @media (max-width: 768px) {
                .cart-sidebar {
                    width: 100%;
                }

                .nav-button {
                    margin: 2px 0;
                    width: 100%;
                }

                .commodity-price {
                    font-size: 1.2rem;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-leaf"></i> AgriYouth Marketplace
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <div class="navbar-nav me-auto">
                        <a class="btn btn-outline-light nav-button" href="opportunities.jsp">
                            <i class="fas fa-book"></i> Opportunities  
                        </a>
                        <a class="btn btn-outline-light nav-button" href="learning_support.jsp">
                            <i class="fas fa-pen"></i> learning hub
                        </a>
                        <a class="btn btn-outline-light nav-button" href="Product_lising.jsp">
                            <i class="fas fa-store"></i> All Products
                        </a>
                        <a class="btn btn-outline-light nav-button" href="testMarketstack.jsp">
                            <i class="fas fa-store"></i> test yahoo
                        </a>

                        <% if (isLoggedIn) { %>
                        <!-- Logged-in users see their correct dashboard -->
                        <% if ("FARMER".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="farmers_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else if ("BUYER".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="buyer_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else if ("ADMIN".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="admin_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else { %>
                        <a class="btn btn-outline-light nav-button" href="dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } %>
                        <% } else { %>
                        <!-- Not logged in: show login modal -->
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </button>
                        <% } %>
                    </div>

                    <div class="navbar-nav ms-auto">
                        <% if (isLoggedIn) {%>
                        <span class="user-welcome">
                            <i class="fas fa-user me-1"></i> Welcome, <%= userName != null ? userName : userEmail%>
                        </span>
                        <a class="btn btn-outline-light nav-button" href="LogoutServlet">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                        <% } else { %>
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-sign-in-alt"></i> Sign In
                        </button>
                        <button class="btn btn-light nav-button" data-bs-toggle="modal" data-bs-target="#registerModal">
                            <i class="fas fa-user-plus"></i> Register
                        </button>
                        <% } %>
                        <button class="btn btn-warning nav-button position-relative" id="cartButton">
                            <i class="fas fa-shopping-cart"></i> Cart 
                            <span class="badge bg-danger position-absolute top-0 start-100 translate-middle rounded-pill" id="cartCount">0</span>
                        </button>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <div class="hero-section text-center">
            <div class="container">
                <h1 class="display-4 fw-bold">Connect. Grow. Prosper.</h1>
                <p class="lead">Lesotho's premier marketplace for youth-led agri-businesses</p>
                <div class="search-box">
                    <form class="d-flex mt-4" id="searchForm">
                        <input class="form-control me-2" id="searchInput" type="search" placeholder="Search for products...">
                        <button class="btn btn-warning" type="submit">
                            <i class="fas fa-search"></i> Search
                        </button>
                    </form>
                </div>

            </div>
        </div>

        <!-- 🌍 Market Trends Section -->
        <section class="market-trends py-5">
            <div class="container">
                <div class="row">
                    <div class="col-12 text-center mb-5">
                        <h2 class="text-success">
                            <i class="fas fa-chart-line me-2"></i>Agricultural Market Trends
                        </h2>
                        <p class="lead">Stay updated with global agricultural markets and demands</p>
                    </div>
                </div>

                <!-- Commodity Prices -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card trend-card">
                            <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="fas fa-seedling me-2"></i>Global Agri-Stocks
                                </h5>
                                <small id="lastUpdated" class="fw-light">Loading...</small>
                            </div>
                            <div class="card-body">
                                <div class="row" id="marketStackData">
                                    <div class="col-12 text-center">
                                        <div class="spinner-border text-success" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                        <p class="mt-2">Loading global market data...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Market News & Trends -->
                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="card trend-card h-100">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-newspaper me-2"></i>Latest Market News
                                </h5>
                            </div>
                            <div class="card-body">
                                <div id="marketNews">
                                    <div class="text-center">
                                        <div class="spinner-border text-info" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                        <p class="mt-2">Loading news...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Price Trends -->
                    <div class="col-md-6 mb-4">
                        <div class="card trend-card h-100">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-bar me-2"></i>Local Price Trends
                                </h5>
                            </div>
                            <div class="card-body">
                                <div id="priceTrends">
                                    <div class="text-center">
                                        <div class="spinner-border text-warning" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                        <p class="mt-2">Loading trends...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Main Content -->
        <div class="container mb-5">
            <div class="row">
                <!-- Filters Sidebar -->
                <div class="col-md-3">
                    <div class="filter-sidebar">
                        <div class="filter-header">
                            <h5><i class="fas fa-filter"></i> Filters</h5>
                        </div>

                        <!-- Category Filter -->
                        <div class="mb-4">
                            <h6>Category</h6>
                            <%
                                try {
                                    Statement catStmt = conn.createStatement();
                                    ResultSet catRs = catStmt.executeQuery("SELECT DISTINCT category FROM products WHERE is_available = 1");
                                    while (catRs.next()) {
                                        String category = catRs.getString("category");
                            %>
                            <div class="form-check">
                                <input class="form-check-input category-filter" type="checkbox" value="<%=category%>" id="cat-<%=category.replace(" ", "-")%>">
                                <label class="form-check-label" for="cat-<%=category.replace(" ", "-")%>">
                                    <%=category%>
                                </label>
                            </div>
                            <%
                                    }
                                    catRs.close();
                                    catStmt.close();
                                } catch (Exception e) {
                                    out.println("Error fetching categories: " + e.getMessage());
                                }
                            %>
                        </div>

                        <!-- Price Range Filter -->
                        <div class="mb-4">
                            <h6>Price Range</h6>
                            <div class="d-flex justify-content-between mb-2">
                                <span>M 0</span>
                                <span>M 500</span>
                            </div>
                            <input type="range" class="form-range" id="priceRange" min="0" max="500" value="500">
                            <div class="text-center mt-2">
                                <small>Max: M <span id="priceRangeValue">500</span></small>
                            </div>
                        </div>

                        <!-- Sort Options -->
                        <div class="mb-4">
                            <h6>Sort By</h6>
                            <select class="form-select" id="sortSelect">
                                <option value="newest">Newest First</option>
                                <option value="price_low">Price: Low to High</option>
                                <option value="price_high">Price: High to Low</option>
                                <option value="name_asc">Name: A to Z</option>
                                <option value="name_desc">Name: Z to A</option>
                            </select>
                        </div>

                        <!-- Apply Filters Button -->
                        <button id="applyFilters" class="btn btn-success w-100">
                            <i class="fas fa-check"></i> Apply Filters
                        </button>

                        <!-- Reset Filters Button -->
                        <button id="resetFilters" class="btn btn-outline-secondary w-100 mt-2">
                            <i class="fas fa-redo"></i> Reset Filters
                        </button>
                    </div>
                </div>

                <!-- Products Grid -->
                <div class="col-md-9">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3>Featured Products</h3>
                        <div class="d-flex align-items-center">
                            <span class="me-2">View:</span>
                            <select class="form-select form-select-sm w-auto" id="viewSelect">
                                <option value="grid">Grid View</option>
                                <option value="list">List View</option>
                            </select>
                        </div>
                    </div>

                    <div class="row g-4" id="productList">
                        <%
                            if (rs != null) {
                                while (rs.next()) {
                                    int id = rs.getInt("id");
                                    String name = rs.getString("name");
                                    String desc = rs.getString("description");
                                    double price = rs.getDouble("price");
                                    String category = rs.getString("category");
                                    double qty = rs.getDouble("quantity");
                                    String unit = rs.getString("unit");
                                    String img = "ImageServlet?id=" + id;
                        %>
                        <div class="col-md-4 col-sm-6 product-item">
                            <div class="card product-card h-100">
                                <img src="<%=img%>" class="card-img-top product-image" alt="<%=name%>">
                                <div class="card-body d-flex flex-column">
                                    <div class="mb-2">
                                        <span class="badge bg-success"><%=category%></span>
                                    </div>
                                    <h5 class="card-title"><%=name%></h5>
                                    <p class="card-text flex-grow-1"><%=desc.length() > 100 ? desc.substring(0, 100) + "..." : desc%></p>
                                    <div class="mt-auto">
                                        <p class="text-success fw-bold mb-1">M <%=String.format("%.2f", price)%></p>
                                        <p class="text-muted small mb-2"><%=qty%> <%=unit%> available</p>
                                        <button class="btn btn-outline-success btn-sm w-100 add-to-cart-btn" 
                                                data-id="<%=id%>" 
                                                data-name="<%=name%>" 
                                                data-price="<%=price%>" 
                                                data-image="<%=img%>">
                                            <i class="fas fa-cart-plus"></i> Add to Cart
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                            }
                        %>
                    </div>

                    <!-- Loading Indicator -->
                    <div id="loadingIndicator" class="text-center mt-4 d-none">
                        <div class="spinner-border text-success" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading products...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 🌱 AGRIBOT FLOATING BUTTON -->
        <div id="chatbot-button" onclick="toggleChatbot()">
            <i class="fas fa-comments"></i>
        </div>

        <!-- 🌱 AGRIBOT MODAL -->
        <div id="chatbot-modal">
            <div class="chat-header">
                <span><i class="fas fa-seedling me-2"></i> AgriBot Assistant</span>
                <button type="button" class="btn-close btn-close-white" aria-label="Close" onclick="closeChatbot()"></button>
            </div>

            <div id="chat-window">
                <div class="chat-message chat-bot">
                    Welcome! I'm AgriBot — your smart farming assistant.  
                    Ask me about crops, livestock, or agri-market trends!
                </div>
            </div>

            <div class="chat-input">
                <input type="text" id="chat-input-text" class="form-control" placeholder="Ask me anything..." onkeypress="if (event.key === 'Enter')
                            sendMessage()">
                <button class="btn btn-agri-primary" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>

        <!-- Cart Overlay -->
        <div class="cart-overlay" id="cartOverlay"></div>

        <!-- Cart Sidebar -->
        <div class="cart-sidebar position-fixed top-0 end-0 h-100 bg-white p-4 overflow-auto" id="cartSidebar">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="m-0"><i class="fas fa-shopping-cart me-2"></i> Your Cart</h4>
                <button class="btn btn-sm btn-outline-secondary rounded-circle" onclick="closeCart()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Cart Items -->
            <div id="cartItems">
                <p class="text-muted text-center py-4" id="emptyCartMessage">Your cart is empty</p>
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
                <div class="d-flex justify-content-between mb-3">
                    <strong>Total:</strong>
                    <strong id="cartTotal">M 0.00</strong>
                </div>
                <button class="btn btn-success w-100 py-2" id="checkoutBtn">
                    <i class="fas fa-credit-card me-2"></i> Proceed to Checkout
                </button>
            </div>
        </div>

        <!-- Login Modal -->
        <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="loginModalLabel">
                            <i class="fas fa-sign-in-alt"></i> Sign In
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>

                    <div class="modal-body">
                        <%
                            String errorMessage = (String) request.getAttribute("errorMessage");
                            if (errorMessage != null) {
                        %>
                        <div class="alert alert-danger text-center"><%= errorMessage%></div>
                        <% }%>

                        <form action="LoginServlet" method="post" autocomplete="off">
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <input type="email" name="email" id="email" class="form-control" placeholder="Enter your email" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" name="password" id="password" class="form-control" placeholder="Enter your password" required>
                            </div>

                            <div class="d-grid mb-3">
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-sign-in-alt"></i> Login
                                </button>
                            </div>
                        </form>

                        <div class="text-center">
                            <p class="mb-0">Don't have an account? 
                                <a href="#" class="text-success fw-bold" 
                                   data-bs-toggle="modal" 
                                   data-bs-target="#registerModal" 
                                   data-bs-dismiss="modal">
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
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">Create Your Account</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body">
                        <form action="RegisterServlet" method="post" enctype="multipart/form-data">
                            <!-- First Name -->
                            <div class="mb-3">
                                <label class="form-label">First Name</label>
                                <input type="text" class="form-control" name="firstName" required>
                            </div>

                            <!-- Last Name -->
                            <div class="mb-3">
                                <label class="form-label">Last Name</label>
                                <input type="text" class="form-control" name="lastName" required>
                            </div>

                            <!-- Email -->
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>

                            <!-- Password -->
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" class="form-control" name="password" required>
                            </div>

                            <!-- Confirm Password -->
                            <div class="mb-3">
                                <label class="form-label">Confirm Password</label>
                                <input type="password" class="form-control" name="confirmPassword" required>
                            </div>

                            <!-- Phone Number -->
                            <div class="mb-3">
                                <label class="form-label">Phone Number</label>
                                <input type="text" class="form-control" name="phoneNumber" placeholder="+266 5xxxxxxx" required>
                            </div>

                            <!-- Location -->
                            <div class="mb-3">
                                <label class="form-label">Location</label>
                                <input type="text" class="form-control" name="location" placeholder="Enter your location">
                            </div>

                            <!-- Bio -->
                            <div class="mb-3">
                                <label class="form-label">Bio</label>
                                <textarea class="form-control" name="bio" rows="3" placeholder="Tell us a bit about yourself..."></textarea>
                            </div>

                            <!-- Profile Picture -->
                            <div class="mb-3">
                                <label class="form-label">Profile Picture</label>
                                <input type="file" class="form-control" name="profilePicture">
                            </div>

                            <!-- Role -->
                            <div class="mb-3">
                                <label class="form-label">Role</label>
                                <select name="role" class="form-select" required>
                                    <option value="">Select Role</option>
                                    <option value="BUYER">Buyer</option>
                                    <option value="FARMER">Farmer</option>
                                    <option value="ADMIN">Admin</option>
                                </select>
                            </div>

                            <button type="submit" class="btn btn-success w-100">Register</button>
                        </form>
                    </div>

                    <div class="modal-footer text-center">
                        <p class="w-100 mb-0">
                            Already have an account?
                            <a href="#" class="text-success fw-bold"
                               data-bs-toggle="modal" data-bs-target="#loginModal" data-bs-dismiss="modal">
                                Sign In
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </div>


        <footer class="bg-dark text-white py-4 mt-5 text-center">
            <p class="mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
        </footer>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                    // MarketStack API Configuration
                    const MARKETSTACK_API_KEY = '3d9a370c91d3274063b1b58608f6ece3';
                    const MARKETSTACK_BASE_URL = 'http://api.marketstack.com/v2/eod';

// Market Trends JavaScript
                    document.addEventListener('DOMContentLoaded', function () {
                        loadMarketStackData();
                        loadMarketNews();
                        loadPriceTrends();
                        // Refresh data every 10 minutes
                        setInterval(loadMarketStackData, 600000);
                    });

                    async function loadMarketStackData() {
                        try {
                            const response = await fetch('market-data');
                            const data = await response.json();

                            if (data.status === 'success') {
                                displayMarketStackData(data);
                            } else {
                                showFallbackMarketData();
                            }
                        } catch (error) {
                            console.error('Error fetching market data:', error);
                            showFallbackMarketData();
                        }
                    }

                    function displayMarketStackData(data) {
                        const marketData = data.data.market;
                        let html = '';

                        marketData.forEach(stock => {
                            const change = ((stock.close - stock.open) / stock.open * 100);
                            const isPositive = change >= 0;
                            const changeFormatted = change.toFixed(2);
                            const sign = isPositive ? '+' : '';

                            html += `
            <div class="col-md-3 col-6 mb-3">
                <div class="card h-100 border-0">
                    <div class="card-body text-center p-3">
                        <h6 class="card-title text-dark mb-2">${stock.symbol}</h6>
                        <div class="commodity-price ${isPositive ? 'price-up' : 'price-down'}">
                            $${stock.close.toFixed(2)}
                        </div>
                        <small class="text-muted">${stock.category}</small>
                        <div class="mt-2">
                            <small class="${isPositive ? 'price-up' : 'price-down'}">
                                <i class="fas fa-arrow-${isPositive ? 'up' : 'down'} me-1"></i>
            ${sign}${changeFormatted}%
                            </small>
                        </div>
                        <div class="mt-2">
                            <small class="text-muted">
                                Vol: ${(stock.volume / 1000000).toFixed(1)}M
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        `;
                        });

                        document.getElementById('marketStackData').innerHTML = html;
                        document.getElementById('lastUpdated').textContent = `Updated: ${data.lastUpdated} (${data.source})`;
                    }

                    function showFallbackMarketData() {
                        // Use the fallback data from your servlet
                        const fallbackData = {
                            status: "success",
                            source: "fallback",
                            lastUpdated: new Date().toISOString().split('T')[0],
                            data: {
                                market: [
                                    {"symbol": "DE", "date": "2024-01-01", "open": 385.5, "high": 388.2, "low": 382.1, "close": 386.75, "volume": 2450000, "currency": "USD", "category": "Agri Machinery"},
                                    {"symbol": "ADM", "date": "2024-01-01", "open": 58.2, "high": 59.1, "low": 57.8, "close": 58.9, "volume": 3200000, "currency": "USD", "category": "Grain Processing"},
                                    {"symbol": "BG", "date": "2024-01-01", "open": 92.5, "high": 93.8, "low": 91.9, "close": 93.2, "volume": 1100000, "currency": "USD", "category": "Grain Trading"},
                                    {"symbol": "CTVA", "date": "2024-01-01", "open": 54.1, "high": 55.0, "low": 53.7, "close": 54.6, "volume": 2800000, "currency": "USD", "category": "Seeds & Crop Protection"}
                                ]
                            }
                        };

                        displayMarketStackData(fallbackData);
                        document.getElementById('lastUpdated').textContent = 'Updated: Fallback Data';
                    }

// Keep your existing functions for news and trends
                    function loadMarketNews() {
                        const newsItems = [
                            {
                                title: 'Global Agri-Stocks Show Mixed Performance',
                                source: 'MarketStack',
                                date: 'Live',
                                summary: 'Agricultural equipment and processing stocks trading actively'
                            },
                            {
                                title: 'Lesotho Farmers Adopt New Irrigation Techniques',
                                source: 'Local Agriculture',
                                date: '5 hours ago',
                                summary: 'Water-efficient methods boosting yields'
                            },
                            {
                                title: 'Organic Farming Demand Increases in Southern Africa',
                                source: 'Market Watch',
                                date: '1 day ago',
                                summary: 'Consumers driving organic produce market'
                            },
                            {
                                title: 'New Export Opportunities for African Produce',
                                source: 'Trade Digest',
                                date: '2 days ago',
                                summary: 'European markets opening for African crops'
                            }
                        ];

                        let newsHtml = '';
                        newsItems.forEach(news => {
                            newsHtml += `
            <div class="news-item mb-3">
                <h6 class="mb-1 fw-bold">${news.title}</h6>
                <p class="mb-1 small">${news.summary}</p>
                <small class="text-muted">
                    <i class="fas fa-source me-1"></i>${news.source} • 
                    <i class="fas fa-clock me-1"></i>${news.date}
                </small>
            </div>
        `;
                        });

                        document.getElementById('marketNews').innerHTML = newsHtml;
                    }

                    function loadPriceTrends() {
                        const trends = [
                            {product: 'Tomatoes', trend: 'up', change: 15, currentPrice: 12.50},
                            {product: 'Potatoes', trend: 'down', change: 8, currentPrice: 8.75},
                            {product: 'Onions', trend: 'up', change: 12, currentPrice: 9.25},
                            {product: 'Cabbage', trend: 'stable', change: 2, currentPrice: 6.50},
                            {product: 'Carrots', trend: 'up', change: 5, currentPrice: 7.80}
                        ];

                        let trendsHtml = '';
                        trends.forEach(trend => {
                            const icon = trend.trend === 'up' ? 'arrow-up' :
                                    trend.trend === 'down' ? 'arrow-down' : 'minus';
                            const color = trend.trend === 'up' ? 'success' :
                                    trend.trend === 'down' ? 'danger' : 'warning';

                            trendsHtml += `
            <div class="trend-item mb-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="fw-medium">${trend.product}</span>
                    <span class="text-${color} fw-bold">
                        <i class="fas fa-${icon} me-1"></i>
            ${trend.change}%
                    </span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <small class="text-muted">M ${trend.currentPrice.toFixed(2)}/kg</small>
                    <div class="progress flex-grow-1 ms-2" style="height: 6px; max-width: 100px;">
                        <div class="progress-bar bg-${color}" 
                             style="width: ${Math.min(Math.abs(trend.change) * 3, 100)}%"></div>
                    </div>
                </div>
            </div>
        `;
                        });

                        document.getElementById('priceTrends').innerHTML = trendsHtml;
                    }
                    // Cart functionality
                    function addToCart(id, name, price, image) {
                        console.log('Adding to cart:', id, name, price, image);

                        $.post("CartServlet", {
                            action: "add",
                            id: id,
                            qty: 1
                        }, function (data) {
                            console.log('Cart response:', data);
                            if (data.success) {
                                updateCartDisplay(data.cart);
                                showToast(name + ' added to cart!');
                            } else {
                                alert(data.message);
                            }
                        }, "json").fail(function (xhr, status, error) {
                            console.error('Cart AJAX error:', error);
                            alert('Error adding to cart. Please try again.');
                        });
                    }

                    function removeFromCart(id) {
                        $.post("CartServlet", {
                            action: "remove",
                            id: id
                        }, function (data) {
                            if (data.success) {
                                updateCartDisplay(data.cart);
                                showToast('Item removed from cart');
                                if (!data.cart || data.cart.length === 0) {
                                    closeCart();
                                }
                            } else {
                                alert(data.message);
                            }
                        }, "json").fail(function (xhr, status, error) {
                            console.error('Remove cart error:', error);
                            alert('Error removing item from cart.');
                        });
                    }

                    function updateCartDisplay(cart) {
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

                        cart.forEach(i => {
                            const price = parseFloat(i.price) || 0;
                            const quantity = parseInt(i.qty) || 0;
                            const itemTotal = price * quantity;
                            total += itemTotal;

                            let imageUrl = i.image;
                            if (!imageUrl) {
                                imageUrl = 'ImageServlet?id=' + i.id;
                            }

                            cartItems.append(`
                        <div class="d-flex justify-content-between align-items-center border-bottom py-3">
                            <div class="d-flex align-items-center">
                                <img src="${imageUrl}" class="cart-item-img rounded me-3" alt="${i.name}" 
                                     onerror="this.onerror=null; this.src='https://placehold.co/60x60/cccccc/ffffff?text=No+Image'">
                                <div>
                                    <strong class="d-block">${i.name}</strong>
                                    <small class="text-muted">M ${price.toFixed(2)} × ${quantity}</small>
                                </div>
                            </div>
                            <button class="btn btn-sm btn-outline-danger" onclick="removeFromCart(${i.id})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    `);
                        });

                        $("#cartCount").text(cart.reduce((sum, i) => sum + (parseInt(i.qty) || 0), 0));
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

                    function showToast(message) {
                        const toast = document.createElement('div');
                        toast.className = 'position-fixed bottom-0 end-0 p-3';
                        toast.style.zIndex = '1060';
                        toast.innerHTML = `
                    <div class="toast show" role="alert">
                        <div class="toast-header bg-success text-white">
                            <i class="fas fa-check-circle me-2"></i>
                            <strong class="me-auto">Success</strong>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
                        </div>
                        <div class="toast-body">${message}</div>
                    </div>
                `;
                        document.body.appendChild(toast);

                        setTimeout(() => {
                            toast.remove();
                        }, 3000);
                    }

                    // Checkout button handler
                    $("#checkoutBtn").click(function (e) {
                        e.preventDefault();
                        console.log('Checkout button clicked');

                        // First validate cart with CartServlet
                        $.post("CartServlet", {action: "checkout"}, function (cartData) {
                            console.log('Checkout validation response:', cartData);
                            if (cartData.success) {
                                // Cart is valid, show checkout form
                                showCheckoutForm();
                            } else {
                                alert("❌ " + cartData.message);
                            }
                        }, "json").fail(function (xhr, status, error) {
                            console.error('Checkout validation error:', error);
                            alert('Error validating cart. Please try again.');
                        });
                    });

                    // Show checkout form modal
                    function showCheckoutForm() {
                        // Get user info from session
                        const userEmail = '<%= session.getAttribute("userEmail") != null ? session.getAttribute("userEmail") : ""%>';
                        const userName = '<%= session.getAttribute("userName") != null ? session.getAttribute("userName") : ""%>';

                        const checkoutForm = `
                    <div class="modal fade" id="checkoutModal" tabindex="-1">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header bg-success text-white">
                                    <h5 class="modal-title"><i class="fas fa-shopping-bag me-2"></i>Complete Your Order</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="checkoutForm">
                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label fw-bold">First Name *</label>
                                                <input type="text" class="form-control" name="firstName" required
                                                       value="${userName.split(' ')[0] || ''}">
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label fw-bold">Last Name *</label>
                                                <input type="text" class="form-control" name="lastName" required
                                                       value="${userName.split(' ')[1] || ''}">
                                            </div>
                                            <div class="col-12 mb-3">
                                                <label class="form-label fw-bold">Email Address for Receipt *</label>
                                                <input type="email" class="form-control" name="email" required
                                                       value="${userEmail}" placeholder="Enter email to receive receipt">
                                                <div class="form-text">We'll send your order confirmation to this email</div>
                                            </div>
                                            <div class="col-12 mb-3">
                                                <label class="form-label fw-bold">Delivery Address *</label>
                                                <textarea class="form-control" name="deliveryAddress" required 
                                                          placeholder="Enter your complete delivery address including street, city, and any specific instructions..." 
                                                          rows="3"></textarea>
                                                <div class="form-text">We'll deliver your order to this address</div>
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label fw-bold">Phone Number *</label>
                                                <input type="tel" class="form-control" name="phoneNumber" required
                                                       placeholder="Enter your phone number">
                                                <div class="form-text">For delivery updates</div>
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label fw-bold">Payment Method *</label>
                                                <select class="form-select" name="paymentMethod" required>
                                                    <option value="">Select payment method</option>
                                                    <option value="CASH" selected>Cash on Delivery</option>
                                                    <option value="MOBILE_MONEY">Mobile Money</option>
                                                    <option value="BANK_TRANSFER">Bank Transfer</option>
                                                </select>
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
                                    <button type="button" class="btn btn-success" id="confirmCheckoutBtn" onclick="processCheckout()">
                                        <i class="fas fa-check me-1"></i> Place Order
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `;

                        // Remove existing modal if any
                        if ($('#checkoutModal').length) {
                            $('#checkoutModal').remove();
                        }

                        // Add modal to page
                        $('body').append(checkoutForm);

                        // Show modal
                        const checkoutModal = new bootstrap.Modal(document.getElementById('checkoutModal'));
                        checkoutModal.show();

                        // Focus on first field
                        setTimeout(() => {
                            $('#checkoutForm input[name="firstName"]').focus();
                        }, 500);
                    }

                    // Process final checkout with CheckoutServlet
                    function processCheckout() {
                        const form = document.getElementById('checkoutForm');

                        // Basic form validation
                        if (!form.checkValidity()) {
                            // Show validation messages
                            form.classList.add('was-validated');
                            form.reportValidity();
                            return;
                        }

                        const formData = new FormData(form);

                        // Show loading state
                        const confirmBtn = $('#confirmCheckoutBtn');
                        const originalText = confirmBtn.html();
                        confirmBtn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Processing...');

                        console.log('Sending checkout data:', {
                            firstName: formData.get('firstName'),
                            lastName: formData.get('lastName'),
                            email: formData.get('email'),
                            deliveryAddress: formData.get('deliveryAddress'),
                            phoneNumber: formData.get('phoneNumber'),
                            paymentMethod: formData.get('paymentMethod')
                        });

                        $.post("CheckoutServlet", {
                            firstName: formData.get('firstName'),
                            lastName: formData.get('lastName'),
                            email: formData.get('email'),
                            deliveryAddress: formData.get('deliveryAddress'),
                            phoneNumber: formData.get('phoneNumber'),
                            paymentMethod: formData.get('paymentMethod')
                        }, function (response) {
                            console.log('Checkout response:', response);

                            if (response.success) {
                                // Success - show confirmation
                                showOrderConfirmation(response.orderId);

                                // Close modals
                                bootstrap.Modal.getInstance(document.getElementById('checkoutModal')).hide();
                                closeCart();

                                // Clear cart
                                $("#cartCount").text("0");
                                $("#cartItems").html('<p class="text-muted text-center py-4" id="emptyCartMessage">Your cart is empty</p>');
                                $("#cartSummary").addClass("d-none");
                            } else {
                                alert("❌ " + response.message);
                                confirmBtn.prop('disabled', false).html(originalText);
                            }
                        }, "json").fail(function (xhr, status, error) {
                            console.error('Checkout error:', error);
                            alert('Error processing checkout. Please try again.');
                            confirmBtn.prop('disabled', false).html(originalText);
                        });
                    }

                    function showOrderConfirmation(orderId) {
                        const confirmation = `
                    <div class="modal fade" id="confirmationModal" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header bg-success text-white">
                                    <h5 class="modal-title"><i class="fas fa-check-circle me-2"></i>Order Confirmed!</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body text-center">
                                    <div class="mb-4">
                                        <i class="fas fa-check-circle text-success" style="font-size: 4rem;"></i>
                                    </div>
                                    <h4 class="text-success mb-3">Thank You For Your Order!</h4>
                                    <p class="mb-2">Your order has been received and is being processed.</p>
                                    <p class="mb-3"><strong>Order ID:</strong> ${orderId}</p>
                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle me-2"></i>
                                        You will receive an email confirmation shortly with your order details.
                                    </div>
                                </div>
                                <div class="modal-footer justify-content-center">
                                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">
                                        <i class="fas fa-shopping-bag me-1"></i> Continue Shopping
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `;

                        // Remove existing modal if any
                        if ($('#confirmationModal').length) {
                            $('#confirmationModal').remove();
                        }

                        // Add modal to page
                        $('body').append(confirmation);

                        // Show modal
                        const confirmationModal = new bootstrap.Modal(document.getElementById('confirmationModal'));
                        confirmationModal.show();
                    }

                    // Event Listeners
                    $(document).ready(function () {
                        // Add to cart buttons
                        $(document).on("click", ".add-to-cart-btn", function () {
                            const id = $(this).data("id");
                            const name = $(this).data("name");
                            const price = $(this).data("price");
                            const image = $(this).data("image");
                            addToCart(id, name, price, image);
                        });

                        // Cart button
                        $("#cartButton").click(function () {
                            openCart();
                        });

                        // Cart overlay
                        $("#cartOverlay").click(function () {
                            closeCart();
                        });

                        // Search form
                        $("#searchForm").on("submit", function (e) {
                            e.preventDefault();
                            const query = $("#searchInput").val().trim();
                            if (query) {
                                searchProducts(query);
                            }
                        });

                        // Price range display
                        $("#priceRange").on("input", function () {
                            $("#priceRangeValue").text($(this).val());
                        });

                        // Apply filters
                        $("#applyFilters").click(function () {
                            applyFilters();
                        });

                        // Reset filters
                        $("#resetFilters").click(function () {
                            resetFilters();
                        });

                        // View selector
                        $("#viewSelect").change(function () {
                            const view = $(this).val();
                            if (view === "list") {
                                $("#productList").addClass("list-view");
                                $(".product-item").addClass("col-12");
                                $(".product-card").addClass("flex-row");
                            } else {
                                $("#productList").removeClass("list-view");
                                $(".product-item").removeClass("col-12");
                                $(".product-card").removeClass("flex-row");
                            }
                        });

                        // Load initial cart
                        $.get("CartServlet", {action: "get"}, function (data) {
                            if (data.success) {
                                updateCartDisplay(data.cart);
                            }
                        }, "json").fail(function (xhr, status, error) {
                            console.error("Error loading cart:", error);
                        });
                    });

                    // Search products function
                    function searchProducts(query) {
                        $("#loadingIndicator").removeClass("d-none");
                        $("#productList").addClass("opacity-25");

                        $.get("ProductSearchServlet", {q: query}, function (data) {
                            $("#productList").html(data);
                        }).always(function () {
                            $("#loadingIndicator").addClass("d-none");
                            $("#productList").removeClass("opacity-25");
                        });
                    }

                    // Apply filters function
                    function applyFilters() {
                        const selectedCategories = [];
                        $(".category-filter:checked").each(function () {
                            selectedCategories.push($(this).val());
                        });

                        const maxPrice = $("#priceRange").val();
                        const sortBy = $("#sortSelect").val();

                        $("#loadingIndicator").removeClass("d-none");
                        $("#productList").addClass("opacity-25");

                        $.get("ProductFilterServlet", {
                            categories: selectedCategories.join(","),
                            maxPrice: maxPrice,
                            sortBy: sortBy
                        }, function (data) {
                            $("#productList").html(data);
                        }).always(function () {
                            $("#loadingIndicator").addClass("d-none");
                            $("#productList").removeClass("opacity-25");
                        });
                    }

                    // Reset filters function
                    function resetFilters() {
                        $(".category-filter").prop("checked", false);
                        $("#priceRange").val(500);
                        $("#priceRangeValue").text("500");
                        $("#sortSelect").val("newest");

                        $("#loadingIndicator").removeClass("d-none");
                        $("#productList").addClass("opacity-25");

                        $.get("ProductFilterServlet", function (data) {
                            $("#productList").html(data);
                        }).always(function () {
                            $("#loadingIndicator").addClass("d-none");
                            $("#productList").removeClass("opacity-25");
                        });
                    }
        </script>

        <script>
            // Toggle chatbot visibility
            function toggleChatbot() {
                const modal = document.getElementById('chatbot-modal');
                modal.style.display = modal.style.display === 'flex' ? 'none' : 'flex';
                if (modal.style.display === 'flex') {
                    document.getElementById('chat-input-text').focus();
                }
            }

            function closeChatbot() {
                document.getElementById('chatbot-modal').style.display = 'none';
            }

            // Send message to AI servlet
            async function sendMessage() {
                const input = document.getElementById('chat-input-text');
                const message = input.value.trim();
                if (message === '')
                    return;

                addMessage(message, 'user');
                input.value = '';

                // Show typing indicator
                const typingId = 'typing-' + Date.now();
                addMessage('<i class="fas fa-circle-notch fa-spin"></i> AgriBot is thinking...', 'bot-typing', typingId);

                try {
                    const response = await fetch('ChatServlet', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'message=' + encodeURIComponent(message)
                    });

                    const data = await response.json();

                    // Remove typing indicator
                    const typingElem = document.getElementById(typingId);
                    if (typingElem)
                        typingElem.remove();

                    if (data.reply) {
                        addMessage(data.reply, 'bot');
                    } else if (data.error) {
                        addMessage('⚠️ ' + data.error, 'bot');
                    } else {
                        addMessage('Sorry, I encountered an issue. Please try again!', 'bot');
                    }

                } catch (err) {
                    console.error('Chatbot error:', err);
                    const typingElem = document.getElementById(typingId);
                    if (typingElem)
                        typingElem.remove();
                    addMessage('❌ Unable to connect to Agribot. Please check your internet connection and try again.', 'bot');
                }
            }

            // Updated addMessage function with ID support
            function addMessage(text, sender, id = null) {
                const chatWindow = document.getElementById('chat-window');
                const messageDiv = document.createElement('div');

                if (id) {
                    messageDiv.id = id;
                }

                if (sender === 'bot-typing') {
                    messageDiv.className = 'chat-message chat-bot-typing';
                    messageDiv.innerHTML = text;
                } else if (sender === 'bot') {
                    messageDiv.className = 'chat-message chat-bot';
                    messageDiv.innerHTML = `<strong>AgriBot:</strong> ${text}`;
                } else {
                    messageDiv.className = 'chat-message chat-user';
                    messageDiv.innerHTML = `<strong>You:</strong> ${text}`;
                }

                chatWindow.appendChild(messageDiv);
                chatWindow.scrollTop = chatWindow.scrollHeight;
            }

            // Press Enter to send
            document.addEventListener('DOMContentLoaded', () => {
                document.getElementById('chat-input-text').addEventListener('keypress', function (e) {
                    if (e.key === 'Enter')
                        sendMessage();
                });
            });
        </script>

    </body>
</html>

<%
    // Close database connection
    if (rs != null) try {
        rs.close();
    } catch (Exception e) {
    }
    if (stmt != null) try {
        stmt.close();
    } catch (Exception e) {
    }
    if (conn != null) try {
        conn.close();
    } catch (Exception e) {
    }
%>