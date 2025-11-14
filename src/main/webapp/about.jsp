<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
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
        <title>About Us - AgriYouth Marketplace</title>
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
                padding: 80px 0;
                margin-bottom: 30px;
            }

            .mission-card {
                background: white;
                border-radius: 15px;
                padding: 30px;
                box-shadow: var(--card-shadow);
                transition: all 0.3s ease;
                height: 100%;
                border-left: 5px solid var(--primary-color);
            }

            .mission-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }

            .feature-icon {
                font-size: 3rem;
                margin-bottom: 20px;
                color: var(--primary-color);
            }

            .team-member {
                text-align: center;
                padding: 20px;
                transition: all 0.3s ease;
            }

            .team-member:hover {
                transform: translateY(-5px);
            }

            .team-photo {
                width: 150px;
                height: 150px;
                border-radius: 50%;
                object-fit: cover;
                margin: 0 auto 15px;
                border: 3px solid var(--primary-color);
            }

            .stats-section {
                background-color: var(--primary-color);
                color: white;
                padding: 60px 0;
            }

            .stat-number {
                font-size: 3rem;
                font-weight: bold;
                margin-bottom: 10px;
            }

            .stat-label {
                font-size: 1.2rem;
                opacity: 0.9;
            }

            .timeline {
                position: relative;
                max-width: 1200px;
                margin: 0 auto;
            }

            .timeline::after {
                content: '';
                position: absolute;
                width: 6px;
                background-color: var(--primary-color);
                top: 0;
                bottom: 0;
                left: 50%;
                margin-left: -3px;
            }

            .timeline-item {
                padding: 10px 40px;
                position: relative;
                width: 50%;
                box-sizing: border-box;
            }

            .timeline-item::after {
                content: '';
                position: absolute;
                width: 20px;
                height: 20px;
                background-color: white;
                border: 4px solid var(--primary-color);
                top: 15px;
                border-radius: 50%;
                z-index: 1;
            }

            .left {
                left: 0;
            }

            .right {
                left: 50%;
            }

            .left::after {
                right: -10px;
            }

            .right::after {
                left: -10px;
            }

            .timeline-content {
                padding: 20px;
                background-color: white;
                border-radius: 10px;
                box-shadow: var(--card-shadow);
            }

            @media (max-width: 768px) {
                .timeline::after {
                    left: 31px;
                }

                .timeline-item {
                    width: 100%;
                    padding-left: 70px;
                    padding-right: 25px;
                }

                .timeline-item::after {
                    left: 21px;
                }

                .right {
                    left: 0%;
                }
            }

            .user-welcome {
                color: white;
                margin-right: 15px;
                display: flex;
                align-items: center;
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
                        <a class="btn btn-outline-light nav-button" href="index.jsp">
                            <i class="fas fa-home"></i> Home
                        </a>
                        <a class="btn btn-outline-light nav-button" href="opportunities.jsp">
                            <i class="fas fa-briefcase"></i> Opportunities  
                        </a>
                        <a class="btn btn-outline-light nav-button" href="learning-materials">
                            <i class="fas fa-graduation-cap"></i> Learning Hub
                        </a>
                        <a class="btn btn-outline-light nav-button" href="Product_lising.jsp">
                            <i class="fas fa-store"></i> All Products
                        </a>
                        <a class="btn btn-outline-light nav-button active" href="about.jsp">
                            <i class="fas fa-info-circle"></i> About
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
                <h1 class="display-4 fw-bold">About AgriYouth Marketplace</h1>
                <p class="lead">Empowering the next generation of agricultural entrepreneurs in Lesotho</p>
            </div>
        </div>

        <!-- Our Mission Section -->
        <div class="container mb-5">
            <div class="row mb-5">
                <div class="col-12 text-center">
                    <h2 class="display-5 fw-bold text-success mb-4">Our Mission</h2>
                    <p class="lead">Transforming youth-led agribusiness in Lesotho through digital innovation</p>
                </div>
            </div>
            
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <h4 class="text-center mb-3">Our Vision</h4>
                        <p class="text-center">To create a sustainable ecosystem where young Basotho agripreneurs can thrive, innovate, and lead the transformation of Lesotho's agricultural sector.</p>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-hand-holding-heart"></i>
                        </div>
                        <h4 class="text-center mb-3">Our Mission</h4>
                        <p class="text-center">To provide an integrated digital platform that addresses fragmentation in youth agribusiness by connecting markets, knowledge, and networks in one accessible hub.</p>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h4 class="text-center mb-3">Our Impact</h4>
                        <p class="text-center">We're bridging the gap between youth potential and agricultural opportunity, creating jobs, improving food security, and building resilient communities.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- The Problem Section -->
        <div class="bg-light py-5 mb-5">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h2 class="fw-bold text-success mb-4">The Challenge We're Solving</h2>
                        <p class="mb-4">Despite high interest in agribusiness among Basotho youth, youth-led ventures face systemic barriers that threaten their sustainability:</p>
                        
                        <ul class="list-unstyled">
                            <li class="mb-3"><i class="fas fa-times-circle text-danger me-2"></i> <strong>Poor Market Access:</strong> Limited buyers, unfair prices, and exploitative middlemen</li>
                            <li class="mb-3"><i class="fas fa-times-circle text-danger me-2"></i> <strong>Skills Gap:</strong> Lack of practical knowledge in modern farming and business management</li>
                            <li class="mb-3"><i class="fas fa-times-circle text-danger me-2"></i> <strong>Resource Limitations:</strong> Disconnected from agricultural insights, funding, and technology</li>
                            <li class="mb-3"><i class="fas fa-times-circle text-danger me-2"></i> <strong>Isolation:</strong> Limited access to mentorship and professional networks</li>
                        </ul>
                    </div>
                    <div class="col-md-6">
                        <img src="https://images.unsplash.com/photo-1586773860418-d37222d8fce3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80" 
                             alt="Agricultural Challenge" class="img-fluid rounded shadow">
                    </div>
                </div>
            </div>
        </div>

        <!-- Our Solution Section -->
        <div class="container mb-5">
            <div class="row mb-5">
                <div class="col-12 text-center">
                    <h2 class="display-5 fw-bold text-success mb-4">Our Integrated Solution</h2>
                    <p class="lead">AgriYouth Empowerment Platform - A holistic digital ecosystem for youth agribusiness</p>
                </div>
            </div>
            
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-store"></i>
                        </div>
                        <h4 class="text-center mb-3">Smart Market & Buyer Linkage</h4>
                        <p>Connect directly with buyers and cooperatives, access real-time market prices, and eliminate exploitative middlemen. Our platform facilitates contract farming and provides branding guidance.</p>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <h4 class="text-center mb-3">Interactive Learning & Support Hub</h4>
                        <p>Access practical guidance through our AgriBot chatbot, curated tutorials, and expert referrals. Learn about climate-smart practices, financial literacy, and business development.</p>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-users"></i>
                        </div>
                        <h4 class="text-center mb-3">Mentorship & Networking</h4>
                        <p>Connect with experienced agripreneurs, join discussion forums, and access professional networks. Break the isolation and learn from peers and mentors in the agricultural community.</p>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mission-card">
                        <div class="feature-icon text-center">
                            <i class="fas fa-chart-bar"></i>
                        </div>
                        <h4 class="text-center mb-3">Market Analytics</h4>
                        <p>Make data-driven decisions with real-time market trends and demand predictions. Our analytics tools help you understand market dynamics and optimize your business strategy.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Technology Section -->
        <div class="bg-success text-white py-5 mb-5">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h2 class="fw-bold mb-4">Built on Robust Technology</h2>
                        <p class="mb-4">Our platform is developed using enterprise-grade technologies to ensure security, scalability, and performance:</p>
                        
                        <ul class="list-unstyled">
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>Java Web MVC Architecture</strong> - Scalable and maintainable</li>
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>Maven Build System</strong> - Standardized dependency management</li>
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>MySQL Database</strong> - Reliable data storage</li>
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>Apache Tomcat Server</strong> - Enterprise-grade deployment</li>
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>Bootstrap & Responsive Design</strong> - Mobile-first approach</li>
                            <li class="mb-2"><i class="fas fa-check-circle me-2"></i> <strong>AES-256 Encryption</strong> - Enterprise-grade security</li>
                        </ul>
                    </div>
                    <div class="col-md-6 text-center">
                        <img src="https://images.unsplash.com/photo-1551650975-87deedd944c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80" 
                             alt="Technology" class="img-fluid rounded shadow" style="max-height: 400px;">
                    </div>
                </div>
            </div>
        </div>

        <!-- Development Journey -->
        <div class="container mb-5">
            <div class="row mb-5">
                <div class="col-12 text-center">
                    <h2 class="display-5 fw-bold text-success mb-4">Our Development Journey</h2>
                    <p class="lead">Following Design Science Research methodology for practical, impactful solutions</p>
                </div>
            </div>
            
            <div class="timeline">
                <div class="timeline-item left">
                    <div class="timeline-content">
                        <h5>Problem Identification</h5>
                        <p>In-depth analysis of youth unemployment and agricultural challenges in Lesotho. Identified fragmentation as the core issue.</p>
                    </div>
                </div>
                <div class="timeline-item right">
                    <div class="timeline-content">
                        <h5>Solution Design</h5>
                        <p>Developed design principles for an integrated platform addressing market access, skills gap, and networking needs.</p>
                    </div>
                </div>
                <div class="timeline-item left">
                    <div class="timeline-content">
                        <h5>Development</h5>
                        <p>Built the AgriYouth Empowerment Platform using Java MVC architecture with security and scalability as priorities.</p>
                    </div>
                </div>
                <div class="timeline-item right">
                    <div class="timeline-content">
                        <h5>Demonstration</h5>
                        <p>Validated functional utility through real-world use cases with young agripreneurs in Lesotho.</p>
                    </div>
                </div>
                <div class="timeline-item left">
                    <div class="timeline-content">
                        <h5>Evaluation</h5>
                        <p>Rigorous assessment of effectiveness, usability, and impact using mixed-methods approach.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Team Section -->
        <div class="container mb-5">
            <div class="row mb-5">
                <div class="col-12 text-center">
                    <h2 class="display-5 fw-bold text-success mb-4">Our Team</h2>
                    <p class="lead">Dedicated to empowering youth through technology and agriculture</p>
                </div>
            </div>
            
            <div class="row g-4 justify-content-center">
                <div class="col-md-4">
                    <div class="team-member">
                        <img src="https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80" 
                             alt="Panta Pii" class="team-photo">
                        <h5>Panta Pii</h5>
                        <p class="text-muted">Developer & Researcher</p>
                        <p>Bachelor of Science Honors in Computing student at Botho University, passionate about using technology to solve real-world challenges in agriculture.</p>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="team-member">
                        <img src="https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80" 
                             alt="Mukai Turugari" class="team-photo">
                        <h5>Mrs. Mukai Turugari</h5>
                        <p class="text-muted">Research Supervisor</p>
                        <p>Providing guidance and direction throughout the research process, ensuring academic rigor and practical relevance.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Section -->
        <div class="stats-section">
            <div class="container">
                <div class="row text-center">
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-number">40%</div>
                        <div class="stat-label">Youth Unemployment in Lesotho</div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-number">70%+</div>
                        <div class="stat-label">Population Dependent on Agriculture</div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-number">1,000+</div>
                        <div class="stat-label">Youth Targeted for Agri-Business</div>
                    </div>
                    <div class="col-md-3 col-6 mb-4">
                        <div class="stat-number">100%</div>
                        <div class="stat-label">Commitment to Sustainable Solutions</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Call to Action -->
        <div class="container my-5">
            <div class="row">
                <div class="col-12 text-center">
                    <h2 class="fw-bold text-success mb-3">Join Our Mission</h2>
                    <p class="lead mb-4">Be part of the movement to transform youth agribusiness in Lesotho</p>
                    <div class="d-flex justify-content-center flex-wrap gap-3">
                        <% if (!isLoggedIn) { %>
                        <button class="btn btn-success btn-lg" data-bs-toggle="modal" data-bs-target="#registerModal">
                            <i class="fas fa-user-plus me-2"></i> Join Now
                        </button>
                        <% } %>
                        <a href="learning-materials" class="btn btn-outline-success btn-lg">
                            <i class="fas fa-graduation-cap me-2"></i> Learn More
                        </a>
                        <a href="Product_lising.jsp" class="btn btn-outline-success btn-lg">
                            <i class="fas fa-store me-2"></i> Browse Products
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <footer class="bg-dark text-white py-4 mt-5 text-center">
            <p class="mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
        </footer>

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

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            // Cart functionality
            $(document).ready(function () {
                // Load initial cart
                $.get("CartServlet", {action: "get"}, function (data) {
                    if (data.success) {
                        updateCartCount(data.cart);
                    }
                }, "json");

                // Cart button
                $("#cartButton").click(function (e) {
                    e.preventDefault();
                    window.location.href = 'Product_lising.jsp';
                });
            });

            function updateCartCount(cart) {
                if (!cart || cart.length === 0) {
                    $("#cartCount").text("0");
                    return;
                }

                const itemCount = cart.reduce((sum, item) => sum + (parseInt(item.qty) || 0), 0);
                $("#cartCount").text(itemCount);
            }
        </script>
    </body>
</html>