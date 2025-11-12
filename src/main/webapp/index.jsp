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
        rs = stmt.executeQuery("SELECT * FROM products WHERE is_available = 1 LIMIT 6");
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
                height: 500px;
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
                flex-grow: 1;
                overflow-y: auto;
                padding: 15px;
                display: flex;
                flex-direction: column;
                gap: 12px;
                background: #f8f9fa;
            }

            .message-container {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }

            .message-user {
                align-items: flex-end;
            }

            .message-bot {
                align-items: flex-start;
            }

            .message-bubble {
                max-width: 85%;
                padding: 10px 15px;
                border-radius: 18px;
                word-wrap: break-word;
                position: relative;
            }

            .message-user .message-bubble {
                background: #007bff;
                color: white;
                border-bottom-right-radius: 5px;
            }

            .message-bot .message-bubble {
                background: white;
                color: #333;
                border: 1px solid #e0e0e0;
                border-bottom-left-radius: 5px;
            }

            .message-sender {
                font-size: 0.75rem;
                color: #666;
                margin: 0 10px;
            }

            .message-user .message-sender {
                text-align: right;
            }

            .message-bot .message-sender {
                text-align: left;
            }

            .typing-indicator {
                display: flex;
                align-items: center;
                gap: 5px;
                padding: 10px 15px;
                background: white;
                border-radius: 18px;
                border: 1px solid #e0e0e0;
                max-width: 85%;
                align-self: flex-start;
            }

            .typing-dots {
                display: flex;
                gap: 3px;
            }

            .typing-dot {
                width: 6px;
                height: 6px;
                background: #999;
                border-radius: 50%;
                animation: typing 1.4s infinite ease-in-out;
            }

            .typing-dot:nth-child(1) { animation-delay: -0.32s; }
            .typing-dot:nth-child(2) { animation-delay: -0.16s; }

            @keyframes typing {
                0%, 80%, 100% { transform: scale(0.8); opacity: 0.5; }
                40% { transform: scale(1); opacity: 1; }
            }

            .chat-input {
                display: flex;
                padding: 12px;
                border-top: 1px solid #eee;
                background: white;
            }

            .chat-input input {
                flex: 1;
                margin-right: 8px;
                border: 1px solid #ddd;
                border-radius: 20px;
                padding: 8px 15px;
                outline: none;
            }

            .chat-input input:focus {
                border-color: #28a745;
            }

            .chat-input button {
                background: #28a745;
                border: none;
                color: white;
                border-radius: 50%;
                width: 40px;
                height: 40px;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: background 0.3s;
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

            .feature-card {
                background: white;
                border-radius: 15px;
                padding: 30px;
                text-align: center;
                box-shadow: var(--card-shadow);
                transition: all 0.3s ease;
                height: 100%;
            }

            .feature-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }

            .feature-icon {
                font-size: 3rem;
                margin-bottom: 20px;
                color: var(--primary-color);
            }

            @media (max-width: 768px) {
                .cart-sidebar {
                    width: 100%;
                }

                .nav-button {
                    margin: 2px 0;
                    width: 100%;
                }

                #chatbot-modal {
                    width: 90%;
                    right: 5%;
                    height: 70vh;
                }

                .message-bubble {
                    max-width: 90%;
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
                            <i class="fas fa-briefcase"></i> Opportunities  
                        </a>
                        <a class="btn btn-outline-light nav-button" href="learning-materials">
                            <i class="fas fa-graduation-cap"></i> Learning Hub
                        </a>
                        <a class="btn btn-outline-light nav-button" href="Product_lising.jsp">
                            <i class="fas fa-store"></i> All Products
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

        <!-- Features Section -->
        <div class="container mb-5">
            <div class="row text-center mb-5">
                <div class="col-12">
                    <h2 class="display-5 fw-bold text-success">Why Choose AgriYouth?</h2>
                    <p class="lead">Empowering the next generation of agricultural entrepreneurs</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-handshake"></i>
                        </div>
                        <h4>Direct Marketplace</h4>
                        <p>Connect directly with farmers and buyers. No middlemen, better prices for everyone.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <h4>Learning Hub</h4>
                        <p>Access educational resources, tutorials, and expert guidance to grow your agri-business.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-briefcase"></i>
                        </div>
                        <h4>Opportunities</h4>
                        <p>Discover jobs, internships, grants, and training opportunities in agriculture.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Featured Products -->
        <div class="container mb-5">
            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-bold text-success">Featured Products</h2>
                    <p class="text-muted">Fresh from our local farmers</p>
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
                        <img src="<%=img%>" class="card-img-top product-image" alt="<%=name%>"
                             onerror="this.src='https://placehold.co/300x200/28a745/ffffff?text=🌱'">
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
                                        data-image="ImageServlet?id=<%=id%>">
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

            <div class="row mt-4">
                <div class="col-12 text-center">
                    <a href="Product_lising.jsp" class="btn btn-success btn-lg">
                        <i class="fas fa-store me-2"></i> View All Products
                    </a>
                </div>
            </div>
        </div>

        <!-- Call to Action -->
        <div class="bg-success text-white py-5">
            <div class="container text-center">
                <h2 class="display-6 fw-bold mb-3">Ready to Grow Your Agri-Business?</h2>
                <p class="lead mb-4">Join thousands of farmers and buyers in our thriving marketplace</p>
                <% if (!isLoggedIn) { %>
                <button class="btn btn-light btn-lg me-3" data-bs-toggle="modal" data-bs-target="#registerModal">
                    <i class="fas fa-user-plus me-2"></i> Get Started
                </button>
                <% } %>
                <a href="learning-materials" class="btn btn-outline-light btn-lg">
                    <i class="fas fa-graduation-cap me-2"></i> Learn More
                </a>
            </div>
        </div>

        <!-- 🌱 AGRIBOT FLOATING BUTTON -->
        <div id="chatbot-button" onclick="toggleChatbot()">
            <i class="fas fa-comments"></i>
        </div>

        <!-- 🌱 AGRIBOT MODAL -->
        <div id="chatbot-modal">
            <div class="chat-header">
                <span><i class="fas fa-seedling me-2"></i> AgriBot - Powered by Google Gemini</span>
                <button type="button" class="btn-close btn-close-white" aria-label="Close" onclick="closeChatbot()"></button>
            </div>

            <div id="chat-window">
                <div class="message-container message-bot">
                    <div class="message-bubble">
                        Welcome! I'm AgriBot, powered by Google Gemini. Ask me about crops, livestock, agri-market trends, or anything related to agriculture!
                    </div>
                    <div class="message-sender">AgriBot</div>
                </div>
            </div>

            <div class="chat-input">
                <input type="text" id="chat-input-text" class="form-control" placeholder="Ask me anything..." onkeypress="if (event.key === 'Enter') sendMessage()">
                <button class="btn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>

        <!-- Cart Overlay -->
        <div class="cart-overlay" id="cartOverlay"></div>

        <!-- Cart Sidebar -->
        <div class="cart-sidebar position-fixed top-0 end-0 h-100 bg-white p-4 overflow-auto shadow-lg" id="cartSidebar">
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
            // Cart functionality - COMPLETELY FIXED VERSION
            function addToCart(id, name, price, image) {
                console.log('➕ Adding to cart - ID:', id, 'Name:', name, 'Type:', typeof id);

                // Ensure ID is a number
                const productId = parseInt(id);
                if (isNaN(productId) || productId <= 0) {
                    console.error('❌ Invalid product ID for adding:', id);
                    alert('Invalid product ID');
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
                console.log('🗑️ removeFromCart called with:', id, 'Type:', typeof id);
                
                // Handle the ID parameter properly
                let productId;
                
                if (typeof id === 'number') {
                    productId = id;
                } else if (typeof id === 'string') {
                    // Remove any non-numeric characters and parse
                    productId = parseInt(id.replace(/\D/g, ''));
                } else {
                    console.error('❌ Invalid ID parameter:', id);
                    alert('Invalid product ID');
                    return;
                }
                
                console.log('🛑 Processing removal for product ID:', productId);
                
                if (isNaN(productId) || productId <= 0) {
                    console.error('❌ Invalid product ID after processing:', productId);
                    alert('Invalid product ID');
                    return;
                }

                $.post("CartServlet", {
                    action: "remove",
                    id: productId
                }, function (data) {
                    console.log('Remove response:', data);
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

                console.log('🛒 Updating cart display with:', cart);

                if (!cart || cart.length === 0) {
                    cartItems.append('<p class="text-muted text-center py-4" id="emptyCartMessage">Your cart is empty</p>');
                    $("#cartSummary").addClass("d-none");
                    $("#cartCount").text("0");
                    return;
                }

                $("#emptyCartMessage").addClass("d-none");

                // Filter valid items
                const validCartItems = cart.filter(item => {
                    const isValid = item && item.id !== undefined && item.id !== null && !isNaN(item.id) && item.id > 0;
                    if (!isValid) {
                        console.warn('⚠️ Filtering out invalid cart item:', item);
                    }
                    return isValid;
                });

                if (validCartItems.length === 0) {
                    cartItems.append('<p class="text-muted text-center py-4">Cart contains invalid items</p>');
                    $("#cartSummary").addClass("d-none");
                    $("#cartCount").text("0");
                    return;
                }

                validCartItems.forEach(item => {
                    const price = parseFloat(item.price) || 0;
                    const quantity = parseInt(item.qty) || 0;
                    const itemTotal = price * quantity;
                    total += itemTotal;

                    const imageUrl = `ImageServlet?id=${item.id}`;
                    
                    console.log('✅ Creating cart item:', item.name, 'ID:', item.id);

                    // Use simple onclick approach with proper data-id
                    const cartItemHtml = `
                        <div class="d-flex justify-content-between align-items-center border-bottom py-3">
                            <div class="d-flex align-items-center">
                                <img src="${imageUrl}" 
                                     class="cart-item-img rounded me-3" 
                                     alt="${item.name}"
                                     onerror="this.src='https://placehold.co/60x60/28a745/ffffff?text=🌱'"
                                     style="width: 60px; height: 60px; object-fit: cover;">
                                <div>
                                    <strong class="d-block">${item.name}</strong>
                                    <small class="text-muted">M ${price.toFixed(2)} × ${quantity}</small>
                                    <small class="text-success d-block">M ${itemTotal.toFixed(2)}</small>
                                </div>
                            </div>
                            <button class="btn btn-sm btn-outline-danger remove-cart-btn" 
                                    data-product-id="${item.id}">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    `;
                    
                    cartItems.append(cartItemHtml);
                });

                // Update cart count and totals
                const itemCount = validCartItems.reduce((sum, item) => sum + (parseInt(item.qty) || 0), 0);
                $("#cartCount").text(itemCount);
                $("#cartSubtotal").text("M " + total.toFixed(2));
                $("#cartTotal").text("M " + total.toFixed(2));
                $("#cartSummary").removeClass("d-none");
            }

            // Cart UI functions
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
                try {
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
                        if (toast && toast.parentNode) {
                            toast.remove();
                        }
                    }, 3000);
                } catch (error) {
                    console.log('Toast error, using alert:', error);
                    alert(message);
                }
            }

            // Event Listeners
            $(document).ready(function () {
                console.log('📋 Document ready - initializing cart...');

                // Load initial cart
                $.get("CartServlet", {action: "get"}, function (data) {
                    console.log('Initial cart data:', data);
                    if (data.success) {
                        updateCartDisplay(data.cart);
                    }
                }, "json").fail(function (xhr, status, error) {
                    console.error("Error loading cart:", error);
                });

                // Add to cart buttons
                $(document).on("click", ".add-to-cart-btn", function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    const id = $(this).data("id");
                    const name = $(this).data("name");
                    const price = $(this).data("price");
                    const image = $(this).data("image");
                    
                    console.log('🛒 Add to cart clicked:', { id, name, price, image });
                    addToCart(id, name, price, image);
                });

                // Remove cart items with proper event handling
                $(document).on("click", ".remove-cart-btn", function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    const productId = $(this).data("product-id");
                    console.log('🛑 Remove button clicked - Product ID:', productId, 'Type:', typeof productId);
                    
                    if (productId && !isNaN(productId)) {
                        removeFromCart(productId);
                    } else {
                        console.error('❌ Invalid product ID from remove button:', productId);
                        alert('Error: Invalid product ID');
                    }
                });

                // Cart button
                $("#cartButton").click(function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Refresh cart before opening
                    $.get("CartServlet", {action: "get"}, function (data) {
                        if (data.success) {
                            updateCartDisplay(data.cart);
                            openCart();
                        }
                    }, "json");
                });

                // Cart overlay
                $("#cartOverlay").click(function (e) {
                    e.preventDefault();
                    e.stopPropagation();
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
            });

            // Search products function
            function searchProducts(query) {
                window.location.href = 'Product_lising.jsp?search=' + encodeURIComponent(query);
            }

            // Checkout functionality
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
                        
                        // Clear session cart
                        $.post("CartServlet", {action: "clear"});
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
        </script>

        <!-- 🌱 AGRIBOT FUNCTIONALITY -->
        <script>
            const GEMINI_API_KEY = "AIzaSyASe6B-IW9Vf1AKTID9yYVLwpGdQzxIG2s";
            const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=" + GEMINI_API_KEY;

            let chatHistory = [
                {role: "user", parts: [{text: "You are AgriBot, a friendly AI assistant for farmers in Lesotho. Focus on agriculture, crops, markets, and youth in farming. Keep answers short and helpful."}]},
                {role: "model", parts: [{text: "Hello! I'm AgriBot. Ask me anything about farming in Lesotho!"}]}
            ];

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

            // Send message to Gemini API
            async function sendMessage() {
                const input = document.getElementById('chat-input-text');
                const message = input.value.trim();
                if (!message) return;

                // Add user message
                addMessage(message, 'user', 'You');
                input.value = '';

                // Show typing indicator
                const typingId = 'typing-' + Date.now();
                showTypingIndicator(typingId);

                chatHistory.push({role: "user", parts: [{text: message}]});

                try {
                    console.log("Sending to:", GEMINI_API_URL);

                    const response = await fetch(GEMINI_API_URL, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Referer': window.location.href
                        },
                        body: JSON.stringify({
                            contents: chatHistory,
                            generationConfig: {
                                temperature: 0.7,
                                maxOutputTokens: 256
                            }
                        })
                    });

                    if (!response.ok) {
                        const errText = await response.text();
                        throw new Error(`HTTP ${response.status}: ${errText}`);
                    }

                    const data = await response.json();
                    const reply = data.candidates[0].content.parts[0].text;

                    // Remove typing indicator
                    removeTypingIndicator(typingId);
                    
                    // Add bot message
                    addMessage(reply, 'bot', 'AgriBot');
                    chatHistory.push({role: "model", parts: [{text: reply}]});

                } catch (err) {
                    console.error('Full Gemini Error:', err);
                    removeTypingIndicator(typingId);
                    addMessage(`Error: ${err.message}`, 'bot', 'AgriBot');
                }
            }

            function addMessage(text, type, sender) {
                const chatWindow = document.getElementById('chat-window');
                const messageContainer = document.createElement('div');
                messageContainer.className = `message-container message-${type}`;
                
                const messageBubble = document.createElement('div');
                messageBubble.className = 'message-bubble';
                messageBubble.textContent = text;
                
                const senderElement = document.createElement('div');
                senderElement.className = 'message-sender';
                senderElement.textContent = sender;
                
                messageContainer.appendChild(messageBubble);
                messageContainer.appendChild(senderElement);
                chatWindow.appendChild(messageContainer);
                
                chatWindow.scrollTop = chatWindow.scrollHeight;
            }

            function showTypingIndicator(id) {
                const chatWindow = document.getElementById('chat-window');
                const typingContainer = document.createElement('div');
                typingContainer.className = 'typing-indicator';
                typingContainer.id = id;
                
                typingContainer.innerHTML = `
                    <div class="typing-dots">
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                    </div>
                    <span style="margin-left: 8px; color: #666; font-size: 0.9rem;">AgriBot is typing...</span>
                `;
                
                chatWindow.appendChild(typingContainer);
                chatWindow.scrollTop = chatWindow.scrollHeight;
            }

            function removeTypingIndicator(id) {
                const typingElement = document.getElementById(id);
                if (typingElement) {
                    typingElement.remove();
                }
            }

            // Press Enter to send message
            document.getElementById('chat-input-text').addEventListener('keypress', function (e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });

            // Close chatbot when clicking outside
            document.addEventListener('click', function (e) {
                const chatbotModal = document.getElementById('chatbot-modal');
                const chatbotButton = document.getElementById('chatbot-button');
                
                if (chatbotModal.style.display === 'flex' && 
                    !chatbotModal.contains(e.target) && 
                    !chatbotButton.contains(e.target)) {
                    closeChatbot();
                }
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