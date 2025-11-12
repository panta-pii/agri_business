<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="models.LearningMaterial"%>
<%
    LearningMaterial material = (LearningMaterial) request.getAttribute("material");
    if (material == null) {
        out.println("<div class='alert alert-danger'>Material not found</div>");
        return;
    }
%>
<div class="material-content">
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h4 class="mb-2"><%= material.getTitle()%></h4>
            <div class="d-flex flex-wrap gap-2 mb-3">
                <span class="badge bg-secondary"><%= material.getContentType()%></span>
                      <span class="badge <%= material.getDifficultyLevel().equals("BEGINNER") ? "bg-success"
                        : material.getDifficultyLevel().equals("INTERMEDIATE") ? "bg-warning" : "bg-danger"%>">
                    <%= material.getDifficultyLevel()%>
                </span>
                <span class="badge bg-primary"><%= material.getCategory()%></span>
                <span class="badge bg-light text-dark"><i class="fas fa-clock me-1"></i><%= material.getDurationMinutes()%> min</span>
            </div>
        </div>
        <small class="text-muted">Created: <%= material.getCreatedAt().toString().split(" ")[0]%></small>
    </div>

    <% if (material.getDescription() != null && !material.getDescription().isEmpty()) {%>
    <div class="alert alert-info">
        <strong>Description:</strong> <%= material.getDescription()%>
    </div>
    <% } %>

    <% if ("VIDEO".equals(material.getContentType()) && material.getContentUrl() != null) {%>
    <div class="video-container mb-4">
        <div class="ratio ratio-16x9">
            <iframe src="<%= material.getContentUrl()%>" 
                    title="<%= material.getTitle()%>" 
                    allowfullscreen></iframe>
            <!-- Replace VIDEO_ID with the actual ID of the YouTube video -->
            <iframe src="<%= material.getContentUrl()%>" 
                    title="<%= material.getTitle()%>" 
                    height="600" 
                    frameborder="0" 
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                    allowfullscreen>
            </iframe>

        </div>
    </div>
    <% } %>

    <% if (material.getContentText() != null && !material.getContentText().isEmpty()) {%>
    <div class="content-text mb-4">
        <h5>Content:</h5>
        <div class="border rounded p-4 bg-light">
            <%= material.getContentText().replace("\n", "<br>")%>
        </div>
    </div>
    <% } %>

    <% if (material.getContentUrl() != null && !"VIDEO".equals(material.getContentType())) {%>
    <div class="external-link mb-4">
        <a href="<%= material.getContentUrl()%>" target="_blank" class="btn btn-outline-primary">
            <i class="fas fa-external-link-alt me-2"></i>View External Content
        </a>
    </div>
    <% }%>

    <div class="material-meta mt-4 pt-4 border-top">
        <div class="row">
            <div class="col-md-6">
                <small class="text-muted">
                    <i class="fas fa-user me-1"></i>Created by: User <%= material.getCreatedBy()%>
                </small>
            </div>
            <div class="col-md-6 text-md-end">
                <small class="text-muted">
                    <i class="fas fa-sync-alt me-1"></i>Last updated: <%= material.getUpdatedAt().toString().split(" ")[0]%>
                </small>
            </div>
        </div>
    </div>
</div>