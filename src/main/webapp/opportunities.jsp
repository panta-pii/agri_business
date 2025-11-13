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
        <title>Agricultural Opportunities - Lesotho AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
            }

            .hero-section {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                padding: 60px 0;
                margin-bottom: 40px;
            }

            .opportunity-card {
                border: none;
                border-radius: 15px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.08);
                transition: all 0.3s ease;
                margin-bottom: 25px;
                height: 100%;
            }

            .opportunity-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
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
                background: #f8f9fa;
                border-radius: 10px;
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
        </style>
    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-success">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-seedling me-2"></i>Lesotho AgriYouth
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="index.jsp">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Product_lising.jsp">Products</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="OpportunitiesServlet">Opportunities</a>
                        </li>
                    </ul>
                    <ul class="navbar-nav">
                        <% if (user != null) {%>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user me-1"></i><%= user.getFirstName()%>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="profile.jsp">Profile</a></li>
                                    <% if ("ADMIN".equals(user.getRole())) { %>
                                <li><a class="dropdown-item" href="admin-dashboard.jsp">Admin Dashboard</a></li>
                                    <% } %>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="LogoutServlet">Logout</a></li>
                            </ul>
                        </li>
                        <% } else { %>
                        <li class="nav-item">
                            <a class="nav-link" href="login.jsp">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="register.jsp">Register</a>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 fw-bold mb-3">Agricultural Opportunities in Lesotho</h1>
                        <p class="lead mb-4">Find jobs, internships, training programs, and grants to grow your agricultural career</p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <% if (user != null) { %>
                        <a href="create-opportunity.jsp" class="btn btn-light btn-lg">
                            <i class="fas fa-plus me-2"></i>Post Opportunity
                        </a>
                        <% } else { %>
                        <a href="login.jsp" class="btn btn-light btn-lg">
                            <i class="fas fa-sign-in-alt me-2"></i>Login to Post
                        </a>
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
                                <button class="btn btn-outline-success btn-sm" onclick="viewOpportunityDetails(<%= opportunity.getId()%>)">
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
                    <% if (user != null) { %>
                    <a href="create-opportunity.jsp" class="btn btn-success">
                        <i class="fas fa-plus me-2"></i>Post First Opportunity
                    </a>
                    <% } else { %>
                    <a href="login.jsp" class="btn btn-success">
                        <i class="fas fa-sign-in-alt me-2"></i>Login to Post Opportunity
                    </a>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Opportunity Details Modal -->
        <div class="modal fade" id="opportunityDetailsModal" tabindex="-1" aria-labelledby="opportunityDetailsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="opportunityDetailsModalLabel">Opportunity Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-8">
                                <h4 id="detailTitle" class="text-success mb-3"></h4>
                                <p id="detailDescription" class="mb-4"></p>

                                <div class="row mb-3">
                                    <div class="col-sm-6">
                                        <strong><i class="fas fa-tag me-2"></i>Category:</strong>
                                        <span id="detailCategory" class="badge bg-light text-dark ms-2"></span>
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
                                        <span id="detailBudget" class="fw-bold ms-2"></span>
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
                                            <% if (user != null) { %>
                                            <button class="btn btn-success w-100 mb-2" onclick="applyForOpportunity()">
                                                <i class="fas fa-paper-plane me-2"></i>Apply Now
                                            </button>
                                            <% } else { %>
                                            <a href="login.jsp" class="btn btn-outline-success w-100 mb-2">
                                                <i class="fas fa-sign-in-alt me-2"></i>Login to Apply
                                            </a>
                                            <% }%>
                                            <button class="btn btn-outline-secondary w-100" onclick="shareOpportunity()">
                                                <i class="fas fa-share-alt me-2"></i>Share
                                            </button>
                                        </div>
                                    </div>
                                </div>
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
                        <button type="button" class="btn btn-outline-primary" onclick="printOpportunity()">
                            <i class="fas fa-print me-2"></i>Print
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-light py-4 mt-5">
            <div class="container">
                <div class="row">
                    <div class="col-md-6">
                        <h5>Lesotho AgriYouth Marketplace</h5>
                        <p class="mb-0">Connecting young farmers with agricultural opportunities across Lesotho</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <p class="mb-0">&copy; 2024 Lesotho AgriYouth Marketplace. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                            // Store current opportunity details
                            let currentOpportunity = null;

                            // Auto-submit form when typing stops (for search)
                            let searchTimeout;
                            document.querySelector('input[name="search"]')?.addEventListener('input', function () {
                                clearTimeout(searchTimeout);
                                searchTimeout = setTimeout(() => {
                                    document.getElementById('filterForm').submit();
                                }, 800);
                            });

                            // View opportunity details - CLIENT-SIDE ONLY SOLUTION
                            function viewOpportunityDetails(opportunityId) {
                                console.log('Opening details for opportunity ID:', opportunityId);

                                // Get ALL opportunities data from the server-side rendered page
                                const opportunitiesData = extractAllOpportunitiesData();
                                console.log('All opportunities data:', opportunitiesData);

                                // Find the specific opportunity
                                const opportunity = opportunitiesData.find(opp => opp.id == opportunityId);

                                if (opportunity) {
                                    console.log('Found opportunity:', opportunity);
                                    currentOpportunity = opportunity;
                                    displayOpportunityDetails(opportunity);
                                } else {
                                    console.error('Opportunity not found in page data for ID:', opportunityId);
                                    // Fallback: extract from card directly
                                    extractFromCardDirectly(opportunityId);
                                }
                            }

                            // Extract ALL opportunities data from the rendered page
                            function extractAllOpportunitiesData() {
                                const opportunities = [];
                                const cards = document.querySelectorAll('.opportunity-card');

                                cards.forEach(card => {
                                    try {
                                        // Get the button that has the onclick with the ID
                                        const button = card.querySelector('button[onclick*="viewOpportunityDetails"]');
                                        if (!button)
                                            return;

                                        // Extract ID from onclick attribute
                                        const onclickText = button.getAttribute('onclick');
                                        const idMatch = onclickText.match(/viewOpportunityDetails\((\d+)\)/);
                                        if (!idMatch)
                                            return;

                                        const id = parseInt(idMatch[1]);

                                        // Extract data from card elements
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
                                            id: id,
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

                            // Fallback: Extract data directly from a specific card
                            function extractFromCardDirectly(opportunityId) {
                                console.log('Extracting directly from card for ID:', opportunityId);

                                // Find the card that has a button with this specific ID
                                const buttons = document.querySelectorAll('button[onclick*="viewOpportunityDetails"]');
                                let targetButton = null;

                                for (let button of buttons) {
                                    const onclickText = button.getAttribute('onclick');
                                    if (onclickText && onclickText.includes(`viewOpportunityDetails(${opportunityId})`)) {
                                        targetButton = button;
                                        break;
                                    }
                                }

                                if (!targetButton) {
                                    console.error('No card found for ID:', opportunityId);
                                    showBasicModal(opportunityId);
                                    return;
                                }

                                const card = targetButton.closest('.opportunity-card');
                                if (!card) {
                                    console.error('Card element not found for button');
                                    showBasicModal(opportunityId);
                                    return;
                                }

                                // Extract data from the found card
                                const opportunity = {
                                    id: opportunityId,
                                    title: card.querySelector('.card-title')?.textContent?.trim() || 'Opportunity #' + opportunityId,
                                    description: card.querySelector('.card-text')?.textContent?.trim() || 'No description available',
                                    category: card.querySelector('.badge.bg-light')?.textContent?.trim() || 'General',
                                    type: card.querySelector('.opportunity-type')?.textContent?.trim() || 'Opportunity',
                                    budget: 0,
                                    creatorName: 'Unknown',
                                    createdAt: 'Recently',
                                    deadline: 'No deadline',
                                    status: 'ACTIVE'
                                };

                                // Extract budget
                                const budgetElement = card.querySelector('.budget-badge');
                                if (budgetElement) {
                                    const budgetText = budgetElement.textContent.trim();
                                    if (budgetText.includes('M')) {
                                        opportunity.budget = parseFloat(budgetText.replace('M', '').replace(/,/g, '')) || 0;
                                    }
                                }

                                // Extract creator
                                const creatorElement = card.querySelector('.text-muted.d-block');
                                if (creatorElement) {
                                    opportunity.creatorName = creatorElement.textContent.replace('Posted by', '').trim();
                                }

                                console.log('Extracted opportunity:', opportunity);
                                currentOpportunity = opportunity;
                                displayOpportunityDetails(opportunity);
                            }

                            // Display opportunity details in modal
                            function displayOpportunityDetails(opportunity) {
                                console.log('Displaying modal with:', opportunity);

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

                                console.log('Modal should be visible now with content');
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

                            // Share opportunity
                            function shareOpportunity() {
                                if (!currentOpportunity) {
                                    showNotification('No opportunity selected', 'error');
                                    return;
                                }

                                const shareText = `Check out: ${currentOpportunity.title} - ${window.location.href}`;
                                navigator.clipboard.writeText(shareText).then(() => {
                                    showNotification('Opportunity link copied!', 'success');
                                });
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

                                // Add click listeners to all buttons for debugging
                                const buttons = document.querySelectorAll('button[onclick*="viewOpportunityDetails"]');
                                console.log('Found', buttons.length, 'opportunity buttons');
                            });
        </script>
    </body>
</html>