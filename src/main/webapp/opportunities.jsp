<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User, models.Opportunity"%>
<%@page import="java.util.List"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;

    List<Opportunity> opportunities = (List<Opportunity>) request.getAttribute("opportunities");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String categoryFilter = (String) request.getAttribute("categoryFilter");
    String typeFilter = (String) request.getAttribute("typeFilter");

    // Check if user is logged in (copied from index.jsp for consistency)
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

    // If opportunities is null, redirect to servlet
    if (opportunities == null) {
        response.sendRedirect("OpportunitiesServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Agricultural Opportunities - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
                padding: 80px 0;
                margin-bottom: 40px;
            }

            .opportunity-card {
                border: none;
                border-radius: 15px;
                box-shadow: var(--card-shadow);
                transition: all 0.3s ease;
                margin-bottom: 25px;
                height: 100%;
            }

            .opportunity-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }

            .opportunity-type {
                position: absolute;
                top: 15px;
                right: 15px;
                padding: 5px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 600;
            }

            .type-JOB {
                background: #007bff;
                color: white;
            }
            .type-INTERNSHIP {
                background: #6f42c1;
                color: white;
            }
            .type-TRAINING {
                background: #20c997;
                color: white;
            }
            .type-GRANT {
                background: #fd7e14;
                color: white;
            }

            .budget-badge {
                background: var(--primary-color);
                color: white;
                padding: 8px 15px;
                border-radius: 25px;
                font-weight: 600;
            }

            .deadline-warning {
                color: #dc3545;
                font-weight: 600;
            }

            .filter-section {
                background: white;
                border-radius: 10px;
                box-shadow: var(--card-shadow);
                padding: 20px;
                margin-bottom: 30px;
            }

            .search-box {
                position: relative;
            }

            .search-box .form-control {
                padding-left: 45px;
                border-radius: 25px;
            }

            .search-box i {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #6c757d;
            }

            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 1060;
                min-width: 300px;
            }

            .share-buttons {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                margin-top: 15px;
            }

            .share-btn {
                flex: 1;
                min-width: 120px;
                border: none;
                border-radius: 8px;
                padding: 10px;
                color: white;
                font-weight: 600;
                transition: all 0.3s ease;
                text-align: center;
                text-decoration: none;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }

            .share-btn:hover {
                transform: translateY(-2px);
                color: white;
                text-decoration: none;
            }

            .share-email { background: #ea4335; }
            .share-whatsapp { background: #25d366; }
            .share-message { background: #007bff; }
            .share-copy { background: #6c757d; }

            .user-welcome {
                color: white;
                margin-right: 15px;
                display: flex;
                align-items: center;
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
                max-height: 350px;
                overflow-y: auto;
                padding: 15px;
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .chat-message {
                padding: 10px 12px;
                border-radius: 18px;
                max-width: 85%;
                word-wrap: break-word;
                line-height: 1.4;
                position: relative;
            }

            .chat-bot {
                background: #e9f7ef;
                align-self: flex-start;
                border-bottom-left-radius: 5px;
                color: #2d5016;
                border: 1px solid #d1e7dd;
            }

            .chat-user {
                background: #d1e7dd;
                align-self: flex-end;
                border-bottom-right-radius: 5px;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .chat-typing {
                background: #e9f7ef;
                align-self: flex-start;
                font-style: italic;
                color: #6c757d;
                border-bottom-left-radius: 5px;
            }

            .chat-input {
                display: flex;
                padding: 12px;
                border-top: 1px solid #eee;
                background: #fafafa;
            }

            .chat-input input {
                flex: 1;
                margin-right: 8px;
                border-radius: 20px;
                padding: 8px 15px;
                border: 1px solid #ddd;
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
            }

            .chat-input button:hover {
                background: #218838;
            }

            @media (max-width: 768px) {
                .nav-button {
                    margin: 2px 0;
                    width: 100%;
                }
                
                .share-buttons {
                    flex-direction: column;
                }
                
                .share-btn {
                    min-width: 100%;
                }

                #chatbot-modal {
                    width: 90%;
                    right: 5%;
                    height: 70vh;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navigation Bar (consistent with index.jsp) -->
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
        <div class="hero-section">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 fw-bold mb-3">Agricultural Opportunities</h1>
                        <p class="lead mb-4">Find jobs, internships, training programs, and grants to grow your agricultural career</p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <% if (isLoggedIn) { %>
                        <a href="create-opportunity.jsp" class="btn btn-light btn-lg">
                            <i class="fas fa-plus me-2"></i>Post Opportunity
                        </a>
                        <% } else { %>
                        <button class="btn btn-light btn-lg" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-sign-in-alt me-2"></i>Login to Post
                        </button>
                        <% }%>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container">
            <!-- Search and Filters -->
            <div class="filter-section">
                <form action="OpportunitiesServlet" method="get" id="filterForm">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" class="form-control" name="search" placeholder="Search opportunities in Lesotho..." 
                                       value="<%= searchQuery != null ? searchQuery : ""%>">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="category" onchange="document.getElementById('filterForm').submit()">
                                <option value="">All Categories</option>
                                <option value="CROP_PRODUCTION" <%= "CROP_PRODUCTION".equals(categoryFilter) ? "selected" : ""%>>Crop Production</option>
                                <option value="LIVESTOCK" <%= "LIVESTOCK".equals(categoryFilter) ? "selected" : ""%>>Livestock</option>
                                <option value="AGRI_TECH" <%= "AGRI_TECH".equals(categoryFilter) ? "selected" : ""%>>Agri-Tech</option>
                                <option value="ORGANIC_FARMING" <%= "ORGANIC_FARMING".equals(categoryFilter) ? "selected" : ""%>>Organic Farming</option>
                                <option value="SUSTAINABLE_AGRICULTURE" <%= "SUSTAINABLE_AGRICULTURE".equals(categoryFilter) ? "selected" : ""%>>Sustainable Agriculture</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="type" onchange="document.getElementById('filterForm').submit()">
                                <option value="">All Types</option>
                                <option value="JOB" <%= "JOB".equals(typeFilter) ? "selected" : ""%>>Jobs</option>
                                <option value="INTERNSHIP" <%= "INTERNSHIP".equals(typeFilter) ? "selected" : ""%>>Internships</option>
                                <option value="TRAINING" <%= "TRAINING".equals(typeFilter) ? "selected" : ""%>>Training</option>
                                <option value="GRANT" <%= "GRANT".equals(typeFilter) ? "selected" : ""%>>Grants</option>
                            </select>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Opportunities Count -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        Showing <strong><%= opportunities.size()%></strong> agricultural opportunities available in Lesotho
                    </div>
                </div>
            </div>

            <!-- Opportunities Grid -->
            <div class="row">
                <% if (opportunities != null && !opportunities.isEmpty()) { %>
                <% for (Opportunity opportunity : opportunities) {
                        String description = opportunity.getDescription();
                        if (description == null) {
                            description = "";
                        }
                        String shortDescription = description.length() > 120 ? description.substring(0, 120) + "..." : description;

                        boolean isDeadlinePassed = opportunity.getDeadline() != null && opportunity.getDeadline().before(new java.util.Date());
                %>
                <div class="col-lg-6 col-xl-4">
                    <div class="card opportunity-card" data-opportunity-id="<%= opportunity.getId()%>">
                        <div class="card-body">
                            <div class="position-relative">
                                <span class="opportunity-type type-<%= opportunity.getType()%>">
                                    <%= opportunity.getType()%>
                                </span>
                                <h5 class="card-title mb-3"><%= opportunity.getTitle() != null ? opportunity.getTitle() : "No Title"%></h5>
                            </div>

                            <p class="card-text text-muted mb-3">
                                <%= shortDescription%>
                            </p>

                            <div class="mb-3">
                                <span class="badge bg-light text-dark">
                                    <i class="fas fa-tag me-1"></i><%= opportunity.getCategory() != null ? opportunity.getCategory() : "General"%>
                                </span>
                                <span class="badge bg-light text-dark ms-1">
                                    <i class="fas fa-map-marker-alt me-1"></i>Lesotho
                                </span>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <% if (opportunity.getBudget() > 0) {%>
                                <div class="budget-badge">
                                    M<%= String.format("%,.2f", opportunity.getBudget())%>
                                </div>
                                <% } else { %>
                                <div class="text-muted">Funding not specified</div>
                                <% }%>

                                <div class="text-end">
                                    <small class="text-muted d-block">Posted by <%= opportunity.getCreatorName() != null ? opportunity.getCreatorName() : "Anonymous"%></small>
                                    <small class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>
                                        <%= opportunity.getCreatedAt() != null
                                                ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(opportunity.getCreatedAt()) : "Recently"%>
                                    </small>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <small class="<%= isDeadlinePassed ? "deadline-warning" : "text-muted"%>">
                                        <i class="fas fa-clock me-1"></i>
                                        <% if (opportunity.getDeadline() != null) {%>
                                        Deadline: <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(opportunity.getDeadline())%>
                                        <% } else { %>
                                        No deadline
                                        <% }%>
                                    </small>
                                </div>
                                <button class="btn btn-outline-success btn-sm view-details-btn" data-opportunity-id="<%= opportunity.getId()%>">
                                    <i class="fas fa-eye me-1"></i>View Details
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                <% } else { %>
                <div class="col-12 text-center py-5">
                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                    <h4 class="text-muted">No opportunities found in Lesotho</h4>
                    <p class="text-muted">Try adjusting your search criteria or check back later for new opportunities.</p>
                    <% if (isLoggedIn) { %>
                    <a href="create-opportunity.jsp" class="btn btn-success">
                        <i class="fas fa-plus me-2"></i>Post First Opportunity
                    </a>
                    <% } else { %>
                    <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#loginModal">
                        <i class="fas fa-sign-in-alt me-2"></i>Login to Post Opportunity
                    </button>
                    <% } %>
                </div>
                <% } %>
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
                <div class="chat-message chat-bot">
                    Welcome! I'm AgriBot, powered by Google Gemini. Ask me about agricultural opportunities, farming techniques, or anything related to agriculture in Lesotho!
                </div>
            </div>

            <div class="chat-input">
                <input type="text" id="chat-input-text" class="form-control" placeholder="Ask me anything..." onkeypress="if (event.key === 'Enter') sendMessage()">
                <button class="btn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>

        <!-- Opportunity Details Modal -->
        <div class="modal fade" id="opportunityDetailsModal" tabindex="-1" aria-labelledby="opportunityDetailsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="opportunityDetailsModalLabel">
                            <i class="fas fa-seedling me-2"></i>Opportunity Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-8">
                                <h4 id="detailTitle" class="text-success mb-3"></h4>
                                <p id="detailDescription" class="mb-4"></p>

                                <div class="row mb-3">
                                    <div class="col-sm-6">
                                        <strong><i class="fas fa-tag me-2"></i>Category:</strong>
                                        <span id="detailCategory" class="badge bg-success ms-2"></span>
                                    </div>
                                    <div class="col-sm-6">
                                        <strong><i class="fas fa-map-marker-alt me-2"></i>Location:</strong>
                                        <span class="badge bg-light text-dark ms-2">Lesotho</span>
                                    </div>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-sm-6">
                                        <strong><i class="fas fa-briefcase me-2"></i>Type:</strong>
                                        <span id="detailType" class="badge bg-primary ms-2"></span>
                                    </div>
                                    <div class="col-sm-6">
                                        <strong><i class="fas fa-wallet me-2"></i>Budget:</strong>
                                        <span id="detailBudget" class="fw-bold text-success ms-2"></span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-4">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h6 class="card-title"><i class="fas fa-info-circle me-2"></i>Quick Info</h6>

                                        <div class="mb-3">
                                            <small class="text-muted">Posted by</small>
                                            <div id="detailCreator" class="fw-bold"></div>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted">Date Posted</small>
                                            <div id="detailCreatedAt" class="fw-bold"></div>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted">Status</small>
                                            <div>
                                                <span id="detailStatus" class="badge bg-success"></span>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted">Application Deadline</small>
                                            <div id="detailDeadline" class="fw-bold"></div>
                                        </div>

                                        <div class="mt-4">
                                            <% if (isLoggedIn) { %>
                                            <button class="btn btn-success w-100 mb-2" id="applyNowBtn">
                                                <i class="fas fa-paper-plane me-2"></i>Apply Now
                                            </button>
                                            <% } else { %>
                                            <button class="btn btn-outline-success w-100 mb-2" data-bs-toggle="modal" data-bs-target="#loginModal">
                                                <i class="fas fa-sign-in-alt me-2"></i>Login to Apply
                                            </button>
                                            <% }%>
                                            <button class="btn btn-outline-primary w-100" id="shareBtn">
                                                <i class="fas fa-share-alt me-2"></i>Share
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Share Options Section (Hidden by default) -->
                        <div id="shareOptions" class="mt-4" style="display: none;">
                            <h6 class="border-bottom pb-2">Share this opportunity</h6>
                            <div class="share-buttons">
                                <a href="#" class="share-btn share-email" id="shareEmail">
                                    <i class="fas fa-envelope"></i> Email
                                </a>
                                <a href="#" class="share-btn share-whatsapp" id="shareWhatsApp">
                                    <i class="fab fa-whatsapp"></i> WhatsApp
                                </a>
                                <a href="#" class="share-btn share-message" id="shareMessage">
                                    <i class="fas fa-comment"></i> Message
                                </a>
                                <a href="#" class="share-btn share-copy" id="shareCopy">
                                    <i class="fas fa-copy"></i> Copy Link
                                </a>
                            </div>
                        </div>

                        <!-- Additional Details Section -->
                        <div class="mt-4">
                            <h6 class="border-bottom pb-2">Additional Information</h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <strong><i class="fas fa-calendar-alt me-2"></i>Last Updated:</strong>
                                    <span id="detailUpdatedAt" class="ms-2"></span>
                                </div>
                                <div class="col-md-6">
                                    <strong><i class="fas fa-clock me-2"></i>Days Remaining:</strong>
                                    <span id="detailDaysRemaining" class="ms-2"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-outline-primary" id="printBtn">
                            <i class="fas fa-print me-2"></i>Print
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Login Modal (copied from index.jsp) -->
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

        <!-- Register Modal (copied from index.jsp) -->
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

        <!-- Footer -->
        <footer class="bg-dark text-white py-4 mt-5 text-center">
            <p class="mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
        </footer>

        <!-- Scripts -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            // Store current opportunity details
            let currentOpportunity = null;

            // Initialize when document is ready
            document.addEventListener('DOMContentLoaded', function() {
                console.log('=== OPPORTUNITIES PAGE LOADED ===');
                
                // Initialize event listeners
                initializeEventListeners();
            });

            function initializeEventListeners() {
                // View details buttons - using event delegation
                document.addEventListener('click', function(e) {
                    if (e.target.classList.contains('view-details-btn') || 
                        e.target.closest('.view-details-btn')) {
                        const button = e.target.classList.contains('view-details-btn') ? 
                            e.target : e.target.closest('.view-details-btn');
                        const opportunityId = button.getAttribute('data-opportunity-id');
                        viewOpportunityDetails(opportunityId);
                    }
                });

                // Modal buttons
                document.getElementById('applyNowBtn')?.addEventListener('click', applyForOpportunity);
                document.getElementById('shareBtn')?.addEventListener('click', showShareOptions);
                document.getElementById('printBtn')?.addEventListener('click', printOpportunity);
                
                // Share buttons
                document.getElementById('shareEmail')?.addEventListener('click', shareViaEmail);
                document.getElementById('shareWhatsApp')?.addEventListener('click', shareViaWhatsApp);
                document.getElementById('shareMessage')?.addEventListener('click', shareViaMessage);
                document.getElementById('shareCopy')?.addEventListener('click', copyShareLink);

                // Auto-submit form when typing stops (for search)
                let searchTimeout;
                const searchInput = document.querySelector('input[name="search"]');
                if (searchInput) {
                    searchInput.addEventListener('input', function() {
                        clearTimeout(searchTimeout);
                        searchTimeout = setTimeout(() => {
                            document.getElementById('filterForm').submit();
                        }, 800);
                    });
                }

                // Cart button
                document.getElementById('cartButton')?.addEventListener('click', function() {
                    alert('Cart functionality would open here');
                });
            }

            // View opportunity details
            function viewOpportunityDetails(opportunityId) {
                console.log('Opening details for opportunity ID:', opportunityId);
                const opportunitiesData = extractAllOpportunitiesData();
                const opportunity = opportunitiesData.find(opp => opp.id == opportunityId);

                if (opportunity) {
                    currentOpportunity = opportunity;
                    displayOpportunityDetails(opportunity);
                } else {
                    console.error('Opportunity not found for ID:', opportunityId);
                    showBasicModal(opportunityId);
                }
            }

            // Extract ALL opportunities data from the rendered page
            function extractAllOpportunitiesData() {
                const opportunities = [];
                const cards = document.querySelectorAll('.opportunity-card');

                cards.forEach(card => {
                    try {
                        const button = card.querySelector('.view-details-btn');
                        if (!button) return;

                        const opportunityId = button.getAttribute('data-opportunity-id');
                        const title = card.querySelector('.card-title')?.textContent?.trim() || 'No Title';
                        const description = card.querySelector('.card-text')?.textContent?.trim() || 'No description';
                        const category = card.querySelector('.badge.bg-light')?.textContent?.trim() || 'General';
                        const type = card.querySelector('.opportunity-type')?.textContent?.trim() || 'Opportunity';

                        // Extract budget
                        let budget = 0;
                        const budgetElement = card.querySelector('.budget-badge');
                        if (budgetElement) {
                            const budgetText = budgetElement.textContent.trim();
                            if (budgetText.includes('M')) {
                                budget = parseFloat(budgetText.replace('M', '').replace(/,/g, '')) || 0;
                            }
                        }

                        // Extract creator
                        let creatorName = 'Unknown';
                        const creatorElement = card.querySelector('.text-muted.d-block');
                        if (creatorElement) {
                            creatorName = creatorElement.textContent.replace('Posted by', '').trim();
                        }

                        // Extract dates
                        let createdAt = 'Recently';
                        const dateElement = card.querySelector('.text-muted small');
                        if (dateElement) {
                            createdAt = dateElement.textContent.trim();
                        }

                        let deadline = 'No deadline';
                        const deadlineElement = card.querySelector('small .text-muted, .deadline-warning');
                        if (deadlineElement) {
                            deadline = deadlineElement.textContent.replace('Deadline:', '').trim();
                        }

                        opportunities.push({
                            id: parseInt(opportunityId),
                            title: title,
                            description: description,
                            category: category,
                            type: type,
                            budget: budget,
                            creatorName: creatorName,
                            createdAt: createdAt,
                            deadline: deadline,
                            status: 'ACTIVE'
                        });

                    } catch (error) {
                        console.error('Error extracting data from card:', error);
                    }
                });

                return opportunities;
            }

            // Display opportunity details in modal
            function displayOpportunityDetails(opportunity) {
                console.log('Displaying modal with:', opportunity);

                // Hide share options initially
                document.getElementById('shareOptions').style.display = 'none';

                // Set all the modal content
                document.getElementById('detailTitle').textContent = opportunity.title;
                document.getElementById('detailDescription').textContent = opportunity.description;
                document.getElementById('detailCategory').textContent = opportunity.category;
                document.getElementById('detailType').textContent = opportunity.type;
                document.getElementById('detailCreator').textContent = opportunity.creatorName;

                // Budget
                if (opportunity.budget > 0) {
                    document.getElementById('detailBudget').textContent = 'M' + opportunity.budget.toLocaleString('en-LS');
                } else {
                    document.getElementById('detailBudget').textContent = 'Not specified';
                }

                // Dates
                document.getElementById('detailCreatedAt').textContent = opportunity.createdAt;
                document.getElementById('detailUpdatedAt').textContent = 'Recently updated';
                document.getElementById('detailDeadline').textContent = opportunity.deadline;
                document.getElementById('detailDaysRemaining').textContent = 'Check deadline above';

                // Status
                document.getElementById('detailStatus').textContent = opportunity.status;
                document.getElementById('detailStatus').className = 'badge bg-success';

                // Show the modal
                const modalElement = document.getElementById('opportunityDetailsModal');
                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            }

            // Show share options
            function showShareOptions() {
                const shareOptions = document.getElementById('shareOptions');
                if (shareOptions.style.display === 'none') {
                    shareOptions.style.display = 'block';
                } else {
                    shareOptions.style.display = 'none';
                }
            }

            // Share via Email - FIXED VERSION
            function shareViaEmail() {
                if (!currentOpportunity) return;
                
                const subject = `Check out this opportunity: ${currentOpportunity.title}`;
                const body = `I found this opportunity on AgriYouth Marketplace that might interest you:\n\n${currentOpportunity.title}\n\n${currentOpportunity.description}\n\nView more details on our platform.`;

                const mailtoLink = "mailto:?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
                window.open(mailtoLink, '_blank');
                showNotification('Email sharing opened!', 'success');
            }

            // Share via WhatsApp
            function shareViaWhatsApp() {
                if (!currentOpportunity) return;
                
                const text = `Check out this opportunity on AgriYouth Marketplace: ${currentOpportunity.title} - ${window.location.href}`;
                const whatsappLink = `https://wa.me/?text=${encodeURIComponent(text)}`;
                
                window.open(whatsappLink, '_blank');
                showNotification('WhatsApp sharing opened!', 'success');
            }

            // Share via Message (SMS)
            function shareViaMessage() {
                if (!currentOpportunity) return;
                
                const text = `Check out this opportunity: ${currentOpportunity.title} - ${window.location.href}`;
                const smsLink = `sms:?body=${encodeURIComponent(text)}`;
                
                window.open(smsLink, '_blank');
                showNotification('Message sharing opened!', 'success');
            }

            // Copy share link
            function copyShareLink() {
                if (!currentOpportunity) return;
                
                const shareText = `Check out this opportunity on AgriYouth Marketplace: ${currentOpportunity.title} - ${window.location.href}`;
                navigator.clipboard.writeText(shareText).then(() => {
                    showNotification('Link copied to clipboard!', 'success');
                }).catch(() => {
                    // Fallback for older browsers
                    const textArea = document.createElement('textarea');
                    textArea.value = shareText;
                    document.body.appendChild(textArea);
                    textArea.select();
                    document.execCommand('copy');
                    document.body.removeChild(textArea);
                    showNotification('Link copied to clipboard!', 'success');
                });
            }

            // Basic modal as ultimate fallback
            function showBasicModal(opportunityId) {
                console.log('Using basic modal for ID:', opportunityId);

                const modalElement = document.getElementById('opportunityDetailsModal');
                if (!modalElement) {
                    alert('Opportunity ID: ' + opportunityId + '\nModal system not available.');
                    return;
                }

                // Set basic content
                document.getElementById('detailTitle').textContent = 'Opportunity #' + opportunityId;
                document.getElementById('detailDescription').textContent = 'Full details for this opportunity are available on the main listing.';
                document.getElementById('detailCategory').textContent = 'General';
                document.getElementById('detailType').textContent = 'Opportunity';
                document.getElementById('detailCreator').textContent = 'System';
                document.getElementById('detailBudget').textContent = 'Check listing';
                document.getElementById('detailCreatedAt').textContent = 'Recently';
                document.getElementById('detailUpdatedAt').textContent = 'Recently';
                document.getElementById('detailDeadline').textContent = 'Check listing';
                document.getElementById('detailDaysRemaining').textContent = 'Check listing';
                document.getElementById('detailStatus').textContent = 'ACTIVE';
                document.getElementById('detailStatus').className = 'badge bg-success';

                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            }

            // Apply for opportunity
            function applyForOpportunity() {
                if (!currentOpportunity) {
                    showNotification('No opportunity selected', 'error');
                    return;
                }

                if (confirm(`Apply for: ${currentOpportunity.title}?`)) {
                    showNotification('Application submitted! You will be contacted soon.', 'success');
                    const modal = bootstrap.Modal.getInstance(document.getElementById('opportunityDetailsModal'));
                    if (modal)
                        modal.hide();
                }
            }

            // Print opportunity details
            function printOpportunity() {
                window.print();
            }

            // Notification function
            function showNotification(message, type) {
                // Remove existing notifications
                document.querySelectorAll('.notification-alert').forEach(n => n.remove());

                const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
                const notification = document.createElement('div');
                notification.className = `alert ${alertClass} alert-dismissible fade show notification-alert`;
                notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
                notification.innerHTML = `
                    <div>${message}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                `;
                document.body.appendChild(notification);

                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.remove();
                    }
                }, 4000);
            }

            // DEBUG: Log all opportunities data on page load
            document.addEventListener('DOMContentLoaded', function () {
                console.log('=== OPPORTUNITIES PAGE LOADED ===');
                const opportunitiesData = extractAllOpportunitiesData();
                console.log('Available opportunities:', opportunitiesData);
            });
        </script>

        <!-- 🌱 AGRIBOT FUNCTIONALITY - FIXED VERSION -->
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
                if (!message)
                    return;

                addMessage(message, 'user');
                input.value = '';

                const typingId = 'typing-' + Date.now();
                addMessage('<i class="fas fa-circle-notch fa-spin"></i> AgriBot is thinking...', 'typing', typingId);

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

                    document.getElementById(typingId)?.remove();
                    addMessage(reply, 'bot');
                    chatHistory.push({role: "model", parts: [{text: reply}]});

                } catch (err) {
                    console.error('Full Gemini Error:', err);
                    document.getElementById(typingId)?.remove();
                    addMessage(`Sorry, I'm having trouble connecting right now. Please try again later.`, 'bot');
                }
            }

            function addMessage(text, type, id = null) {
                const chatWindow = document.getElementById('chat-window');
                const div = document.createElement('div');
                div.className = `chat-message chat-${type}`;
                if (id)
                    div.id = id;

                if (type === 'bot') {
                    div.innerHTML = `<strong>AgriBot:</strong> ${text}`;
                } else if (type === 'typing') {
                    div.innerHTML = text;
                } else {
                    div.innerHTML = `<strong>You:</strong> ${text}`;
                }
                chatWindow.appendChild(div);
                chatWindow.scrollTop = chatWindow.scrollHeight;
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