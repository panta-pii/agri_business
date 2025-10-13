<%-- 
    Document   : index
    Created on : Sep 1, 2025, 8:28:48 AM
    Author     : pantapii36
--%>

<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Database connection parameters
    String url = "jdbc:mysql://localhost:3306/agri_business";
    String username = "root"; // Change as needed
    String password = ""; // Change as needed

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish connection
        conn = DriverManager.getConnection(url, username, password);

        // Create statement
        stmt = conn.createStatement();

        // Execute query to get available products
        String sql = "SELECT * FROM products WHERE is_available = 1";
        rs = stmt.executeQuery(sql);
    } catch (Exception e) {
        out.println("Database connection error: " + e.getMessage());
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AgriYouth Marketplace</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/§§§§§§§§§dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            .product-card {
                transition: transform 0.2s;
                height: 100%;
            }
            .product-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 20px rgba(0,0,0,0.1);
            }
            .cart-sidebar {
                width: 320px;
                transform: translateX(100%);
                transition: transform 0.3s ease-in-out;
            }
            .cart-sidebar.open {
                transform: translateX(0);
            }
            .cart-item-img {
                width: 50px;
                height: 50px;
                object-fit: cover;
            }
            .hero-section {
                background: linear-gradient(rgba(0,0,0,0.4), rgba(0,0,0,0.4)), url('https://placehold.co/1200x400/007bff/white?text=AgriYouth+Marketplace');
                background-size: cover;
                background-position: center;
                color: white;
                padding: 100px 0;
                margin-bottom: 30px;
            }
            .product-image {
                height: 200px;
                object-fit: cover;
                width: 100%;
            }
        </style>
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top">
            <div class="container">
                <a class="navbar-brand" href="#">
                    <i class="fas fa-leaf"></i> AgriYouth Marketplace
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link active" href="index.jsp">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Products</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Suppliers</a>
                        </li>
                    </ul>
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#loginModal">
                                <i class="fas fa-sign-in-alt"></i> Sign In
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#"><i class="fas fa-info-circle"></i> About</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#"><i class="fas fa-phone"></i> Contact</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" id="cartButton">
                                <i class="fas fa-shopping-cart"></i> Cart
                                <span class="badge bg-danger rounded-pill" id="cartCount">0</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold">Connect. Grow. Prosper.</h1>
                <p class="lead">Lesotho's premier marketplace for youth-led agri-businesses</p>
                <form class="d-flex justify-content-center mt-4">
                    <input class="form-control me-2 w-50" type="search" placeholder="Search for products..." aria-label="Search">
                    <button class="btn btn-warning" type="submit"><i class="fas fa-search"></i> Search</button>
                </form>
            </div>
        </div>

        <!-- Main Content Container -->
        <div class="container mb-5">
            <div class="row">
                <!-- Filters Sidebar (optional) -->
                <div class="col-md-3">
                    <div class="card mb-4">
                        <div class="card-header bg-light">
                            <h5 class="mb-0"><i class="fas fa-filter"></i> Filters</h5>
                        </div>
                        <div class="card-body">
                            <h6>Category</h6>
                            <%
                                try {
                                    // Get distinct categories from database
                                    Statement catStmt = conn.createStatement();
                                    ResultSet catRs = catStmt.executeQuery("SELECT DISTINCT category FROM products WHERE is_available = 1");

                                    while (catRs.next()) {
                                        String category = catRs.getString("category");
                            %>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="<%= category%>" value="<%= category%>">
                                <label class="form-check-label" for="<%= category%>"><%= category%></label>
                            </div>
                            <%
                                    }
                                    catRs.close();
                                    catStmt.close();
                                } catch (Exception e) {
                                    out.println("Error fetching categories: " + e.getMessage());
                                }
                            %>

                            <hr>

                            <h6>Price Range</h6>
                            <div class="mb-3">
                                <label for="priceRange" class="form-label">M 0 - M 500</label>
                                <input type="range" class="form-range" id="priceRange" min="0" max="500">
                            </div>

                            <button class="btn btn-sm btn-success w-100">Apply Filters</button>
                        </div>
                    </div>
                </div>

                <!-- Product Listing -->
                <div class="col-md-9">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3>Featured Products</h3>
                        <div>
                            <select class="form-select form-select-sm" id="sortSelect">
                                <option value="newest">Sort by: Newest</option>
                                <option value="price_low">Sort by: Price Low to High</option>
                                <option value="price_high">Sort by: Price High to Low</option>
                            </select>
                        </div>
                    </div>

                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-3 g-4" id="productList">
                        <%
                            try {
                                // Check if result set is available
                                if (rs != null) {
                                    // Loop through products from database
                                    while (rs.next()) {
                                        int id = rs.getInt("ID");
                                        String name = rs.getString("name");
                                        String description = rs.getString("description");
                                        String category = rs.getString("category");
                                        double price = rs.getDouble("price");
                                        double quantity = rs.getDouble("quantity");
                                        String unit = rs.getString("unit");
                                        Blob imageBlob = rs.getBlob("image");
                                        String imageUrl = "https://placehold.co/300x200/28a745/white?text=" + name.replace(" ", "+");

                                        // If image blob exists, we'd need to create a servlet to serve it
                                        // For now, using placeholder
%>
                        <!-- Product Card -->
                        <div class="col">
                            <div class="card product-card h-100">
                                <img src="<%= imageUrl%>" class="card-img-top product-image" alt="<%= name%>">
                                <div class="card-body">
                                    <h5 class="card-title"><%= name%></h5>
                                    <p class="card-text"><%= description%></p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="h5 text-success mb-0">M <%= price%></span>
                                        <span class="badge bg-warning text-dark"><i class="fas fa-star"></i> 4.8</span>
                                    </div>
                                    <p class="text-muted">Min. order: <%= quantity%> <%= unit%></p>
                                </div>
                                <div class="card-footer bg-white">
                                    <button class="btn btn-outline-success btn-sm" onclick="addToCart(<%= id%>, '<%= name%>', <%= price%>, '<%= imageUrl%>')">
                                        <i class="fas fa-cart-plus"></i> Add to Cart
                                    </button>
                                </div>
                            </div>
                        </div>
                        <%
                                    }
                                }
                            } catch (Exception e) {
                                out.println("Error displaying products: " + e.getMessage());
                            } finally {
                                // Close database resources
                                try {
                                    if (rs != null) {
                                        rs.close();
                                    }
                                } catch (Exception e) {
                                }
                                try {
                                    if (stmt != null) {
                                        stmt.close();
                                    }
                                } catch (Exception e) {
                                }
                                try {
                                    if (conn != null) {
                                        conn.close();
                                    }
                                } catch (Exception e) {
                                }
                            }
                        %>
                    </div>

                    <!-- Pagination -->
                    <nav class="mt-5">
                        <ul class="pagination justify-content-center">
                            <li class="page-item disabled">
                                <a class="page-link" href="#">Previous</a>
                            </li>
                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                            <li class="page-item">
                                <a class="page-link" href="#">Next</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>

        <!-- Cart Sidebar -->
        <div class="cart-sidebar position-fixed top-0 end-0 h-100 bg-light p-3 overflow-auto" id="cartSidebar">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4><i class="fas fa-shopping-cart"></i> Your Cart</h4>
                <button class="btn btn-sm btn-outline-secondary" onclick="closeCart()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <div id="cartItems">
                <!-- Cart items will be added here dynamically -->
                <p class="text-muted text-center" id="emptyCartMessage">Your cart is empty</p>
            </div>

            <div class="mt-3 d-none" id="cartSummary">
                <hr>
                <div class="d-flex justify-content-between">
                    <strong>Total:</strong>
                    <strong id="cartTotal">M 0.00</strong>
                </div>
                <button class="btn btn-success w-100 mt-3">Proceed to Checkout</button>
            </div>
        </div>

        <!-- Login Modal -->
        <div class="modal fade" id="loginModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Sign In to Your Account</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form>
                            <div class="mb-3">
                                <label for="email" class="form-label">Email address</label>
                                <input type="email" class="form-control" id="email" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" required>
                            </div>
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="remember">
                                <label class="form-check-label" for="remember">Remember me</label>
                            </div>
                            <button type="submit" class="btn btn-success w-100">Sign In</button>
                        </form>
                        <div class="text-center mt-3">
                            <p>Don't have an account? 
                                <a href="#" 
                                   data-bs-toggle="modal" 
                                   data-bs-target="#registerModal" 
                                   data-bs-dismiss="modal"
                                   class="text-success fw-bold">
                                    Register here
                                </a>
                            </p>

                            <p><a href="#">Forgot your password?</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Register Modal -->
        <div class="modal fade" id="registerModal" tabindex="-1" aria-labelledby="registerModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="registerModalLabel">Create Your Account</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="registerForm" action="RegisterServlet" method="post">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="registerFirstName" class="form-label">First Name *</label>
                                    <input type="text" class="form-control" id="registerFirstName" name="firstName" required 
                                           placeholder="Enter your first name">
                                    <div class="invalid-feedback">Please enter your first name</div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="registerLastName" class="form-label">Last Name *</label>
                                    <input type="text" class="form-control" id="registerLastName" name="lastName" required 
                                           placeholder="Enter your last name">
                                    <div class="invalid-feedback">Please enter your last name</div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="registerEmail" class="form-label">Email Address *</label>
                                <input type="email" class="form-control" id="registerEmail" name="email" required 
                                       placeholder="your.email@example.com">
                                <div class="invalid-feedback">Please enter a valid email address</div>
                            </div>

                            <div class="mb-3">
                                <label for="registerPhone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="registerPhone" name="phoneNumber" 
                                       placeholder="+266 123 4567">
                            </div>

                            <div class="mb-3">
                                <label for="registerRole" class="form-label">I am a *</label>
                                <select class="form-select" id="registerRole" name="role" required>
                                    <option value="">Select your role</option>
                                    <option value="FARMER">Farmer</option>
                                    <option value="BUYER">Buyer</option>
                                </select>
                                <div class="invalid-feedback">Please select your role</div>
                            </div>

                            <div class="mb-3">
                                <label for="registerLocation" class="form-label">Location</label>
                                <input type="text" class="form-control" id="registerLocation" name="location" 
                                       placeholder="Maseru, Lesotho">
                            </div>

                            <div class="mb-3">
                                <label for="registerPassword" class="form-label">Password *</label>
                                <input type="password" class="form-control" id="registerPassword" name="password" required 
                                       placeholder="At least 6 characters">
                                <div class="form-text">Password must be at least 6 characters long</div>
                                <div class="invalid-feedback">Please enter a password (min. 6 characters)</div>
                            </div>

                            <div class="mb-3">
                                <label for="registerConfirmPassword" class="form-label">Confirm Password *</label>
                                <input type="password" class="form-control" id="registerConfirmPassword" name="confirmPassword" required 
                                       placeholder="Re-enter your password">
                                <div class="invalid-feedback">Passwords do not match</div>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-success" id="registerSubmitBtn">
                                    <span class="spinner-border spinner-border-sm me-2 d-none" id="registerSpinner"></span>
                                    Create Account
                                </button>
                            </div>
                        </form>

                        <div class="text-center mt-3">
                            <p class="text-muted">Already have an account? 
                                <a href="#" class="text-success fw-bold" data-bs-toggle="modal" data-bs-target="#loginModal" data-bs-dismiss="modal">
                                    Sign in here
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container">
                <div class="row">
                    <div class="col-md-4">
                        <h5>AgriYouth Marketplace</h5>
                        <p>Empowering youth-led agri-businesses in Lesotho through technology and innovation.</p>
                    </div>
                    <div class="col-md-2">
                        <h5>Quick Links</h5>
                        <ul class="list-unstyled">
                            <li><a href="#" class="text-white">Home</a></li>
                            <li><a href="#" class="text-white">Products</a></li>
                            <li><a href="#" class="text-white">Suppliers</a></li>
                        </ul>
                    </div>
                    <div class="col-md-3">
                        <h5>Contact Us</h5>
                        <ul class="list-unstyled">
                            <li><i class="fas fa-phone"></i> +266 1234 5678</li>
                            <li><i class="fas fa-envelope"></i> info@agriyouth.ls</li>
                            <li><i class="fas fa-map-marker-alt"></i> Maseru, Lesotho</li>
                        </ul>
                    </div>
                    <div class="col-md-3">
                        <h5>Follow Us</h5>
                        <div>
                            <a href="#" class="text-white me-2"><i class="fab fa-facebook-f fa-lg"></i></a>
                            <a href="#" class="text-white me-2"><i class="fab fa-twitter fa-lg"></i></a>
                            <a href="#" class="text-white me-2"><i class="fab fa-instagram fa-lg"></i></a>
                            <a href="#" class="text-white"><i class="fab fa-linkedin-in fa-lg"></i></a>
                        </div>
                    </div>
                </div>
                <hr>
                <p class="text-center mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
            </div>
        </footer>

        <!-- Bootstrap & jQuery JS -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                    // Cart functionality
                    let cart = [];
                    let cartCount = 0;
                    let cartTotal = 0;

                    // Function to add product to cart
                    function addToCart(id, name, price, image) {
                        // Check if product already in cart
                        const existingItem = cart.find(item => item.id === id);

                        if (existingItem) {
                            existingItem.quantity += 1;
                        } else {
                            cart.push({
                                id: id,
                                name: name,
                                price: price,
                                image: image,
                                quantity: 1
                            });
                        }

                        updateCart();
                        openCart();

                        // Show notification
                        alert(`Added ${name} to cart!`);
                    }

                    // Function to remove item from cart
                    function removeFromCart(id) {
                        cart = cart.filter(item => item.id !== id);
                        updateCart();
                    }

                    // Function to update cart UI
                    function updateCart() {
                        const cartItems = document.getElementById('cartItems');
                        const cartCountElement = document.getElementById('cartCount');
                        const cartTotalElement = document.getElementById('cartTotal');
                        const cartSummary = document.getElementById('cartSummary');
                        const emptyCartMessage = document.getElementById('emptyCartMessage');

                        // Update cart count
                        cartCount = cart.reduce((total, item) => total + item.quantity, 0);
                        cartCountElement.textContent = cartCount;

                        // Update cart items
                        cartItems.innerHTML = '';
                        cartTotal = 0;

                        if (cart.length === 0) {
                            emptyCartMessage.classList.remove('d-none');
                            cartSummary.classList.add('d-none');
                        } else {
                            emptyCartMessage.classList.add('d-none');
                            cartSummary.classList.remove('d-none');

                            cart.forEach(item => {
                                const itemTotal = item.price * item.quantity;
                                cartTotal += itemTotal;

                                const cartItem = document.createElement('div');
                                cartItem.className = 'card mb-2';
                                cartItem.innerHTML = `
                            <div class="card-body py-2">
                                <div class="d-flex justify-content-between">
                                    <div class="d-flex">
                                        <img src="${item.image}" class="cart-item-img me-2" alt="${item.name}">
                                        <div>
                                            <h6 class="mb-0">${item.name}</h6>
                                            <small>M ${item.price.toFixed(2)} × ${item.quantity}</small>
                                        </div>
                                    </div>
                                    <div>
                                        <span class="fw-bold">M ${itemTotal.toFixed(2)}</span>
                                        <button class="btn btn-sm btn-outline-danger ms-2" onclick="removeFromCart(${item.id})">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;

                                cartItems.appendChild(cartItem);
                            });

                            cartTotalElement.textContent = `M ${cartTotal.toFixed(2)}`;
                        }
                    }

                    // Function to open cart
                    function openCart() {
                        document.getElementById('cartSidebar').classList.add('open');
                    }

                    // Function to close cart
                    function closeCart() {
                        document.getElementById('cartSidebar').classList.remove('open');
                    }

                    // Event listeners
                    document.getElementById('cartButton').addEventListener('click', function (e) {
                        e.preventDefault();
                        openCart();
                    });

                    // Close cart when clicking outside
                    document.addEventListener('click', function (e) {
                        const cartSidebar = document.getElementById('cartSidebar');
                        if (!cartSidebar.contains(e.target) && !e.target.closest('#cartButton')) {
                            closeCart();
                        }
                    });
        </script>
    </body>
</html>