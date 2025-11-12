package Servlet;

import daos.LearningMaterialDAO;
import models.LearningMaterial;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/MaterialEditServlet")
public class MaterialEditServlet extends HttpServlet {
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
            
            if (material != null) {
                String html = generateEditForm(material);
                response.setContentType("text/html");
                response.getWriter().write(html);
            } else {
                response.getWriter().write("<div class='alert alert-danger'>Material not found</div>");
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.getWriter().write("<div class='alert alert-danger'>Error loading material data</div>");
        }
    }
    
    private String generateEditForm(LearningMaterial material) {
        StringBuilder html = new StringBuilder();
        
        html.append("<div class='row'>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Title *</label>")
            .append("<input type='text' class='form-control' name='title' value='").append(escapeHtml(material.getTitle())).append("' required>")
            .append("</div>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Content Type *</label>")
            .append("<select class='form-select' name='contentType' required>")
            .append("<option value='ARTICLE'").append("ARTICLE".equals(material.getContentType()) ? " selected" : "").append(">Article</option>")
            .append("<option value='VIDEO'").append("VIDEO".equals(material.getContentType()) ? " selected" : "").append(">Video</option>")
            .append("<option value='BLOG'").append("BLOG".equals(material.getContentType()) ? " selected" : "").append(">Blog</option>")
            .append("<option value='DOCUMENT'").append("DOCUMENT".equals(material.getContentType()) ? " selected" : "").append(">Document</option>")
            .append("<option value='TUTORIAL'").append("TUTORIAL".equals(material.getContentType()) ? " selected" : "").append(">Tutorial</option>")
            .append("</select>")
            .append("</div>")
            .append("<div class='col-12 mb-3'>")
            .append("<label class='form-label'>Description</label>")
            .append("<textarea class='form-control' name='description' rows='3'>").append(escapeHtml(material.getDescription())).append("</textarea>")
            .append("</div>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Content URL</label>")
            .append("<input type='url' class='form-control' name='contentUrl' value='").append(escapeHtml(material.getContentUrl() != null ? material.getContentUrl() : "")).append("'>")
            .append("</div>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Category *</label>")
            .append("<select class='form-select' name='category' required>")
            .append("<option value='Crop Production'").append("Crop Production".equals(material.getCategory()) ? " selected" : "").append(">Crop Production</option>")
            .append("<option value='Livestock'").append("Livestock".equals(material.getCategory()) ? " selected" : "").append(">Livestock</option>")
            .append("<option value='Business'").append("Business".equals(material.getCategory()) ? " selected" : "").append(">Business</option>")
            .append("<option value='Technology'").append("Technology".equals(material.getCategory()) ? " selected" : "").append(">Technology</option>")
            .append("<option value='Sustainability'").append("Sustainability".equals(material.getCategory()) ? " selected" : "").append(">Sustainability</option>")
            .append("<option value='Marketing'").append("Marketing".equals(material.getCategory()) ? " selected" : "").append(">Marketing</option>")
            .append("<option value='Finance'").append("Finance".equals(material.getCategory()) ? " selected" : "").append(">Finance</option>")
            .append("</select>")
            .append("</div>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Difficulty Level *</label>")
            .append("<select class='form-select' name='difficultyLevel' required>")
            .append("<option value='BEGINNER'").append("BEGINNER".equals(material.getDifficultyLevel()) ? " selected" : "").append(">Beginner</option>")
            .append("<option value='INTERMEDIATE'").append("INTERMEDIATE".equals(material.getDifficultyLevel()) ? " selected" : "").append(">Intermediate</option>")
            .append("<option value='ADVANCED'").append("ADVANCED".equals(material.getDifficultyLevel()) ? " selected" : "").append(">Advanced</option>")
            .append("</select>")
            .append("</div>")
            .append("<div class='col-md-6 mb-3'>")
            .append("<label class='form-label'>Duration (minutes)</label>")
            .append("<input type='number' class='form-control' name='durationMinutes' value='").append(material.getDurationMinutes()).append("' min='1'>")
            .append("</div>")
            .append("<div class='col-12 mb-3'>")
            .append("<label class='form-label'>Content Text</label>")
            .append("<textarea class='form-control' name='contentText' rows='6'>").append(escapeHtml(material.getContentText() != null ? material.getContentText() : "")).append("</textarea>")
            .append("</div>")
            .append("<div class='col-12 mb-3'>")
            .append("<div class='form-check'>")
            .append("<input class='form-check-input' type='checkbox' name='isPublished' value='true' ").append(material.isPublished() ? "checked" : "").append(">")
            .append("<label class='form-check-label'>Published</label>")
            .append("</div>")
            .append("</div>")
            .append("</div>");
        
        return html.toString();
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