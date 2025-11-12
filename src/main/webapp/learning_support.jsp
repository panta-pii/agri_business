<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User, models.LearningMaterial, java.util.List"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    if (user == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }

    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("learningMaterials");
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("category");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Learning & Support Hub - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --secondary-color: #ffc107;
                --accent-color: #17a2b8;
            }

            .learning-hero {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                padding: 60px 0;
                text-align: center;
            }

            .material-card {
                border: none;
                border-radius: 15px;
                box-shadow: 0 5px 25px rgba(0,0,0,0.1);
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                margin-bottom: 25px;
                height: 100%;
            }

            .material-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 35px rgba(0,0,0,0.15);
            }

            .material-icon {
                font-size: 2rem;
                margin-bottom: 1rem;
            }

            .content-article {
                border-left: 4px solid #28a745;
            }
            .content-video {
                border-left: 4px solid #dc3545;
            }
            .content-blog {
                border-left: 4px solid #ffc107;
            }
            .content-document {
                border-left: 4px solid #17a2b8;
            }
            .content-tutorial {
                border-left: 4px solid #6f42c1;
            }

            .badge-beginner {
                background: #28a745;
            }
            .badge-intermediate {
                background: #ffc107;
                color: #000;
            }
            .badge-advanced {
                background: #dc3545;
            }

            .search-box {
                border-radius: 25px;
                border: 2px solid var(--primary-color);
                padding: 12px 20px;
            }

            .progress-ring {
                width: 80px;
                height: 80px;
            }

            .progress-ring-circle {
                transform: rotate(-90deg);
                transform-origin: 50% 50%;
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
                    <a class="btn btn-outline-light me-2" href="index.jsp">
                        <i class="fas fa-home"></i> Home
                    </a>
                    <a class="btn btn-outline-light me-2" href="profile.jsp">
                        <i class="fas fa-user"></i> Profile
                    </a>
                    <a class="btn btn-light" href="learning-materials">
                        <i class="fas fa-graduation-cap"></i> Learning Hub
                    </a>
                    <% if ("ADMIN".equals(user.getRole())) { %>
                    <a class="btn btn-outline-warning ms-2" href="learning-materials?action=admin">
                        <i class="fas fa-cog"></i> Manage Materials
                    </a>
                    <% }%>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="learning-hero">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 fw-bold mb-4">Interactive Learning & Support Hub</h1>
                        <p class="lead mb-4">Empowering farmers with knowledge, tools, and expert guidance for sustainable agriculture</p>

                        <!-- Search Bar -->
                        <div class="row justify-content-center">
                            <div class="col-lg-8">
                                <form method="get" action="learning-materials" class="input-group">
                                    <input type="text" name="search" class="form-control search-box" 
                                           placeholder="Search learning materials..." value="<%= searchQuery != null ? searchQuery : ""%>">
                                    <button class="btn btn-warning" type="submit">
                                        <i class="fas fa-search"></i> Search
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Main Content -->
        <div class="container py-5">
            <!-- Quick Stats -->
            <div class="row mb-5">
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fas fa-book fa-2x text-primary mb-3"></i>
                            <h3 class="text-primary"><%= materials != null ? materials.size() : 0%></h3>
                            <p class="text-muted">Learning Materials</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fas fa-video fa-2x text-info mb-3"></i>
                            <h3 class="text-info">
                                <%= materials != null ? materials.stream().filter(m -> "VIDEO".equals(m.getContentType())).count() : 0%>
                            </h3>
                            <p class="text-muted">Video Tutorials</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fas fa-file-alt fa-2x text-warning mb-3"></i>
                            <h3 class="text-warning">
                                <%= materials != null ? materials.stream().filter(m -> "ARTICLE".equals(m.getContentType())).count() : 0%>
                            </h3>
                            <p class="text-muted">Articles</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fas fa-graduation-cap fa-2x text-success mb-3"></i>
                            <h3 class="text-success">
                                <%= materials != null ? materials.stream().filter(m -> "TUTORIAL".equals(m.getContentType())).count() : 0%>
                            </h3>
                            <p class="text-muted">Interactive Tutorials</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Category Filter -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <h5 class="mb-3"><i class="fas fa-filter me-2"></i>Filter by Category</h5>
                            <div class="d-flex flex-wrap gap-2">
                                <a href="learning-materials" class="btn btn-outline-primary btn-sm">All Categories</a>
                                <a href="learning-materials?category=Crop Production" class="btn btn-outline-primary btn-sm">Crop Production</a>
                                <a href="learning-materials?category=Livestock" class="btn btn-outline-primary btn-sm">Livestock</a>
                                <a href="learning-materials?category=Business" class="btn btn-outline-primary btn-sm">Business</a>
                                <a href="learning-materials?category=Technology" class="btn btn-outline-primary btn-sm">Technology</a>
                                <a href="learning-materials?category=Sustainability" class="btn btn-outline-primary btn-sm">Sustainability</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Learning Materials Grid -->
            <div class="row">
                <% if (materials != null && !materials.isEmpty()) {
                        for (LearningMaterial material : materials) {
                %>
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card material-card content-<%= material.getContentType().toLowerCase()%>">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <span class="badge bg-secondary"><%= material.getContentType()%></span>
                                    <span class="badge badge-<%= material.getDifficultyLevel().toLowerCase()%> ms-1">
                                        <%= material.getDifficultyLevel()%>
                                    </span>
                                </div>
                                <small class="text-muted"><%= material.getDurationMinutes()%> min</small>
                            </div>

                            <h5 class="card-title"><%= material.getTitle()%></h5>
                            <p class="card-text text-muted"><%= material.getDescription()%></p>

                            <div class="mb-3">
                                <span class="badge bg-light text-dark"><i class="fas fa-tag me-1"></i><%= material.getCategory()%></span>
                            </div>

                            <div class="d-flex justify-content-between align-items-center">
                                <small class="text-muted">
                                    <i class="fas fa-calendar me-1"></i>
                                    <%= material.getCreatedAt().toString().split(" ")[0]%>
                                </small>
                                <div>
                                    <% if ("VIDEO".equals(material.getContentType()) && material.getContentUrl() != null) {%>
                                    <button class="btn btn-sm btn-danger" onclick="openMaterialModal(<%= material.getId()%>)">
                                        <i class="fas fa-play me-1"></i> Watch
                                    </button>
                                    <% } else if ("ARTICLE".equals(material.getContentType())) {%>
                                    <button class="btn btn-sm btn-success" onclick="openMaterialModal(<%= material.getId()%>)">
                                        <i class="fas fa-book-open me-1"></i> Read
                                    </button>
                                    <% } else {%>
                                    <button class="btn btn-sm btn-primary" onclick="openMaterialModal(<%= material.getId()%>)">
                                        <i class="fas fa-eye me-1"></i> View
                                    </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% }
                } else { %>
                <div class="col-12 text-center py-5">
                    <i class="fas fa-book-open fa-3x text-muted mb-3"></i>
                    <h4 class="text-muted">No learning materials found</h4>
                    <p class="text-muted">Check back later for new content</p>
                </div>
                <% }%>
            </div>
        </div>

        <!-- Material View Modal -->
        <div class="modal fade" id="materialModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="materialModalTitle">Learning Material</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="materialModalContent">
                        <!-- Content will be loaded via AJAX -->
                    </div>
                </div>
            </div>
        </div>

        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container">
                <div class="row">
                    <div class="col-md-6">
                        <h5><i class="fas fa-leaf me-2"></i>AgriYouth Marketplace</h5>
                        <p class="mb-0">Empowering the next generation of farmers</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <p class="mb-0">&copy; 2025 AgriYouth Marketplace. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </footer>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                        function openMaterialModal(materialId) {
                                            // Load material content via AJAX
                                            $.get('MaterialViewServlet?id=' + materialId, function (data) {
                                                $('#materialModalContent').html(data);
                                                $('#materialModal').modal('show');
                                            }).fail(function () {
                                                alert('Error loading material content');
                                            });
                                        }

                                        // Track learning progress
                                        function trackProgress(materialId, progress) {
                                            $.post('LearningProgressServlet', {
                                                action: 'update',
                                                materialId: materialId,
                                                progress: progress
                                            });
                                        }

                                        // Initialize page
                                        $(document).ready(function () {
                                            // Any initialization code
                                        });
        </script>
    </body>
</html>