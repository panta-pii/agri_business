<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User, models.LearningMaterial, java.util.List"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("index.jsp?error=access_denied");
        return;
    }
    
    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("learningMaterials");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Learning Materials - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-leaf"></i> AgriYouth Marketplace
            </a>
            <div class="navbar-nav ms-auto">
                <a class="btn btn-outline-light me-2" href="index.jsp">
                    <i class="fas fa-home"></i> Home
                </a>
                <a class="btn btn-outline-light me-2" href="learning-materials">
                    <i class="fas fa-graduation-cap"></i> Learning Hub
                </a>
                <a class="btn btn-light" href="learning-materials?action=admin">
                    <i class="fas fa-cog"></i> Manage Materials
                </a>
            </div>
        </div>
    </nav>

    <div class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1><i class="fas fa-cog me-2"></i>Manage Learning Materials</h1>
            <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#createMaterialModal">
                <i class="fas fa-plus me-2"></i>Add New Material
            </button>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>
            <% switch(success) {
                case "created": %> Learning material created successfully! <% break;
                case "updated": %> Learning material updated successfully! <% break;
                case "deleted": %> Learning material deleted successfully! <% break;
            } %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>
            <% switch(error) {
                case "create_failed": %> Failed to create learning material <% break;
                case "update_failed": %> Failed to update learning material <% break;
                case "delete_failed": %> Failed to delete learning material <% break;
                case "material_not_found": %> Learning material not found <% break;
            } %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="card shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Title</th>
                                <th>Type</th>
                                <th>Category</th>
                                <th>Level</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (materials != null && !materials.isEmpty()) { 
                                for (LearningMaterial material : materials) { 
                            %>
                            <tr>
                                <td><strong><%= material.getTitle() %></strong></td>
                                <td><span class="badge bg-secondary"><%= material.getContentType() %></span></td>
                                <td><%= material.getCategory() %></td>
                                <td>
                                    <span class="badge <%= material.getDifficultyLevel().equals("BEGINNER") ? "bg-success" : 
                                                          material.getDifficultyLevel().equals("INTERMEDIATE") ? "bg-warning" : "bg-danger" %>">
                                        <%= material.getDifficultyLevel() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge <%= material.isPublished() ? "bg-success" : "bg-secondary" %>">
                                        <%= material.isPublished() ? "Published" : "Draft" %>
                                    </span>
                                </td>
                                <td><%= material.getCreatedAt().toString().split(" ")[0] %></td>
                                <td>
                                    <div class="btn-group btn-group-sm">
                                        <button class="btn btn-outline-primary" 
                                                onclick="editMaterial(<%= material.getId() %>)"
                                                data-bs-toggle="modal" data-bs-target="#editMaterialModal">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn btn-outline-danger" 
                                                onclick="confirmDelete(<%= material.getId() %>, '<%= material.getTitle() %>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } 
                            } else { %>
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">
                                    <i class="fas fa-inbox fa-2x mb-3"></i><br>
                                    No learning materials found
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Create Material Modal -->
    <div class="modal fade" id="createMaterialModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title"><i class="fas fa-plus me-2"></i>Create Learning Material</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="learning-materials" method="post">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Title *</label>
                                <input type="text" class="form-control" name="title" required>
                            </div>
                            <div class="col-md-6 mb-3">
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
                            <div class="col-12 mb-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3"></textarea>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Content URL</label>
                                <input type="url" class="form-control" name="contentUrl" 
                                       placeholder="https://example.com/video">
                            </div>
                            <div class="col-md-6 mb-3">
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
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Difficulty Level *</label>
                                <select class="form-select" name="difficultyLevel" required>
                                    <option value="">Select Level</option>
                                    <option value="BEGINNER">Beginner</option>
                                    <option value="INTERMEDIATE">Intermediate</option>
                                    <option value="ADVANCED">Advanced</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Duration (minutes)</label>
                                <input type="number" class="form-control" name="durationMinutes" min="1" value="30">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">Content Text</label>
                                <textarea class="form-control" name="contentText" rows="6" 
                                          placeholder="Enter the main content here..."></textarea>
                            </div>
                            <div class="col-12 mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="isPublished" value="true" checked>
                                    <label class="form-check-label">Publish immediately</label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">Create Material</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Material Modal -->
    <div class="modal fade" id="editMaterialModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Learning Material</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="learning-materials" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editMaterialId">
                    <div class="modal-body" id="editMaterialContent">
                        <!-- Content will be loaded via AJAX -->
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Material</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteConfirmModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="fas fa-exclamation-triangle me-2"></i>Confirm Delete</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete the learning material: <strong id="deleteMaterialTitle"></strong>?</p>
                    <p class="text-danger"><small>This action cannot be undone.</small></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form id="deleteForm" action="learning-materials" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteMaterialId">
                        <button type="submit" class="btn btn-danger">Delete</button>
                    </form>
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
        function editMaterial(materialId) {
            // Load material data for editing via AJAX
            $.get('MaterialEditServlet?id=' + materialId, function(data) {
                $('#editMaterialContent').html(data);
                $('#editMaterialId').val(materialId);
            }).fail(function() {
                alert('Error loading material data');
            });
        }

        function confirmDelete(materialId, materialTitle) {
            $('#deleteMaterialId').val(materialId);
            $('#deleteMaterialTitle').text(materialTitle);
            $('#deleteConfirmModal').modal('show');
        }

        // Initialize modals
        $(document).ready(function() {
            // Any additional initialization
        });
    </script>
</body>
</html>