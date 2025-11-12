package Servlet;

import daos.LearningMaterialDAO;
import models.LearningMaterial;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/MaterialViewServlet")
public class MaterialViewServlet extends HttpServlet {
    private LearningMaterialDAO learningMaterialDAO;
    
    @Override
    public void init() throws ServletException {
        learningMaterialDAO = new LearningMaterialDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));
            LearningMaterial material = learningMaterialDAO.getMaterialById(materialId);
            
            if (material != null && material.isPublished()) {
                // Generate HTML content for the modal
                String htmlContent = generateMaterialHTML(material);
                response.setContentType("text/html");
                response.getWriter().write(htmlContent);
            } else {
                response.getWriter().write("<div class='alert alert-danger'>Material not found or not published</div>");
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.getWriter().write("<div class='alert alert-danger'>Error loading material</div>");
        }
    }
    
    private String generateMaterialHTML(LearningMaterial material) {
        StringBuilder html = new StringBuilder();
        
        html.append("<div class='material-content'>")
            .append("<div class='d-flex justify-content-between align-items-start mb-4'>")
            .append("<div>")
            .append("<h4 class='mb-2'>").append(escapeHtml(material.getTitle())).append("</h4>")
            .append("<div class='d-flex flex-wrap gap-2 mb-3'>")
            .append("<span class='badge bg-secondary'>").append(material.getContentType()).append("</span>")
            .append("<span class='badge ").append(getDifficultyBadgeClass(material.getDifficultyLevel())).append("'>")
            .append(material.getDifficultyLevel())
            .append("</span>")
            .append("<span class='badge bg-primary'>").append(material.getCategory()).append("</span>")
            .append("<span class='badge bg-light text-dark'><i class='fas fa-clock me-1'></i>")
            .append(material.getDurationMinutes()).append(" min</span>")
            .append("</div>")
            .append("</div>")
            .append("<small class='text-muted'>Created: ").append(material.getCreatedAt().toString().split(" ")[0]).append("</small>")
            .append("</div>");

        if (material.getDescription() != null && !material.getDescription().isEmpty()) {
            html.append("<div class='alert alert-info'>")
                .append("<strong>Description:</strong> ").append(escapeHtml(material.getDescription()))
                .append("</div>");
        }

        if ("VIDEO".equals(material.getContentType()) && material.getContentUrl() != null) {
            html.append("<div class='video-container mb-4'>")
                .append("<h5 class='mb-3'><i class='fas fa-play-circle me-2'></i>Video Content</h5>");
            
            String embedUrl = getYouTubeEmbedUrl(material.getContentUrl());
            if (embedUrl != null) {
                // YouTube embed
                html.append("<div class='ratio ratio-16x9'>")
                    .append("<iframe src='").append(embedUrl).append("' ")
                    .append("title='").append(escapeHtml(material.getTitle())).append("' ")
                    .append("frameborder='0' ")
                    .append("allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' ")
                    .append("allowfullscreen></iframe>")
                    .append("</div>");
            } else {
                // Regular video URL - show as link
                html.append("<div class='alert alert-warning'>")
                    .append("<p><strong>Video Content Available</strong></p>")
                    .append("<p>Click the button below to watch this video:</p>")
                    .append("<a href='").append(escapeHtml(material.getContentUrl())).append("' target='_blank' class='btn btn-danger'>")
                    .append("<i class='fab fa-youtube me-2'></i>Watch on YouTube")
                    .append("</a>")
                    .append("</div>");
            }
            html.append("</div>");
        }

        if (material.getContentText() != null && !material.getContentText().isEmpty()) {
            html.append("<div class='content-text mb-4'>")
                .append("<h5><i class='fas fa-file-alt me-2'></i>Content:</h5>")
                .append("<div class='border rounded p-4 bg-light'>")
                .append(formatContentText(material.getContentText()))
                .append("</div>")
                .append("</div>");
        }

        if (material.getContentUrl() != null && !"VIDEO".equals(material.getContentType())) {
            html.append("<div class='external-link mb-4'>")
                .append("<a href='").append(escapeHtml(material.getContentUrl())).append("' target='_blank' class='btn btn-outline-primary'>")
                .append("<i class='fas fa-external-link-alt me-2'></i>View External Content")
                .append("</a>")
                .append("</div>");
        }

        html.append("<div class='material-meta mt-4 pt-4 border-top'>")
            .append("<div class='row'>")
            .append("<div class='col-md-6'>")
            .append("<small class='text-muted'>")
            .append("<i class='fas fa-user me-1'></i>Created by: User ").append(material.getCreatedBy())
            .append("</small>")
            .append("</div>")
            .append("<div class='col-md-6 text-md-end'>")
            .append("<small class='text-muted'>")
            .append("<i class='fas fa-sync-alt me-1'></i>Last updated: ").append(material.getUpdatedAt().toString().split(" ")[0])
            .append("</small>")
            .append("</div>")
            .append("</div>")
            .append("</div>")
            .append("</div>");
        
        return html.toString();
    }
    
    /**
     * Convert YouTube URLs to embed format
     * Supports:
     * - Regular YouTube URLs: https://www.youtube.com/watch?v=VIDEO_ID
     * - Short YouTube URLs: https://youtu.be/VIDEO_ID
     * - Embed URLs: https://www.youtube.com/embed/VIDEO_ID
     */
    private String getYouTubeEmbedUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        
        try {
            // If it's already an embed URL, return as is
            if (url.contains("youtube.com/embed/")) {
                return url + "?rel=0"; // Add rel=0 to disable related videos
            }
            
            // Extract video ID from different YouTube URL formats
            String videoId = null;
            
            // Format: https://www.youtube.com/watch?v=VIDEO_ID
            if (url.contains("youtube.com/watch")) {
                int vIndex = url.indexOf("v=");
                if (vIndex != -1) {
                    videoId = url.substring(vIndex + 2);
                    // Remove any additional parameters
                    int ampIndex = videoId.indexOf("&");
                    if (ampIndex != -1) {
                        videoId = videoId.substring(0, ampIndex);
                    }
                }
            }
            // Format: https://youtu.be/VIDEO_ID
            else if (url.contains("youtu.be/")) {
                int beIndex = url.indexOf("youtu.be/") + 9;
                videoId = url.substring(beIndex);
                // Remove any additional parameters
                int paramIndex = videoId.indexOf("?");
                if (paramIndex != -1) {
                    videoId = videoId.substring(0, paramIndex);
                }
            }
            
            if (videoId != null && !videoId.isEmpty()) {
                return "https://www.youtube.com/embed/" + videoId + "?rel=0";
            }
            
        } catch (Exception e) {
            System.err.println("Error parsing YouTube URL: " + url);
            e.printStackTrace();
        }
        
        return null;
    }
    
    private String formatContentText(String text) {
        if (text == null) return "";
        // Convert line breaks to HTML line breaks
        return text.replace("\n", "<br>")
                  .replace("\r", "");
    }
    
    private String getDifficultyBadgeClass(String difficulty) {
        switch (difficulty) {
            case "BEGINNER": return "bg-success";
            case "INTERMEDIATE": return "bg-warning";
            case "ADVANCED": return "bg-danger";
            default: return "bg-secondary";
        }
    }
    
    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }
}