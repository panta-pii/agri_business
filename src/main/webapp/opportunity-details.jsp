<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="models.Opportunity, models.User"%>
<%
    Opportunity opportunity = (Opportunity) request.getAttribute("opportunity");
    User user = (User) session.getAttribute("user");
    
    if (opportunity == null) {
        response.sendRedirect("opportunities.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= opportunity.getTitle() %> - AgriYouth Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation (same as opportunities.jsp) -->
    
    <div class="container mt-4">
        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <h1><%= opportunity.getTitle() %></h1>
                        <p class="text-muted">Posted by <%= opportunity.getCreatorName() %> on 
                           <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(opportunity.getCreatedAt()) %></p>
                        
                        <div class="mb-4">
                            <span class="badge bg-primary me-2"><%= opportunity.getType() %></span>
                            <span class="badge bg-secondary"><%= opportunity.getCategory() %></span>
                        </div>
                        
                        <div class="mb-4">
                            <h4>Description</h4>
                            <p><%= opportunity.getDescription() %></p>
                        </div>
                        
                        <% if (opportunity.getBudget() > 0) { %>
                        <div class="mb-4">
                            <h4>Budget</h4>
                            <p class="h5 text-success">$<%= String.format("%,.2f", opportunity.getBudget()) %></p>
                        </div>
                        <% } %>
                        
                        <div class="mb-4">
                            <h4>Deadline</h4>
                            <p class="<%= opportunity.getDeadline().before(new java.util.Date()) ? "text-danger" : "text-success" %>">
                                <i class="fas fa-clock me-2"></i>
                                <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(opportunity.getDeadline()) %>
                                <% if (opportunity.getDeadline().before(new java.util.Date())) { %>
                                    <span class="badge bg-danger ms-2">Expired</span>
                                <% } else { %>
                                    <span class="badge bg-success ms-2">Active</span>
                                <% } %>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-body">
                        <h5>Apply for this Opportunity</h5>
                        <% if (user != null) { %>
                            <% if (opportunity.getDeadline().after(new java.util.Date())) { %>
                                <a href="apply-opportunity.jsp?id=<%= opportunity.getId() %>" class="btn btn-success w-100 mb-2">
                                    Apply Now
                                </a>
                            <% } else { %>
                                <button class="btn btn-secondary w-100 mb-2" disabled>
                                    Opportunity Expired
                                </button>
                            <% } %>
                        <% } else { %>
                            <a href="login.jsp" class="btn btn-primary w-100 mb-2">
                                Login to Apply
                            </a>
                        <% } %>
                        
                        <a href="opportunities.jsp" class="btn btn-outline-secondary w-100">
                            Back to Opportunities
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>