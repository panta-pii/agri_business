package Servlet;

import daos.LearningMaterialDAO;
import models.LearningMaterial;
import models.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/learning-materials")
@MultipartConfig
public class LearningMaterialServlet extends HttpServlet {
    private LearningMaterialDAO learningMaterialDAO;
    
    @Override
    public void init() throws ServletException {
        learningMaterialDAO = new LearningMaterialDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendRedirect("index.jsp?error=login_required");
            return;
        }
        
        String action = request.getParameter("action");
        String searchQuery = request.getParameter("search");
        String category = request.getParameter("category");
        
        try {
            List<LearningMaterial> materials;
            
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                // Search materials
                materials = learningMaterialDAO.searchMaterials(searchQuery);
            } else if (category != null && !category.trim().isEmpty()) {
                // Filter by category
                materials = learningMaterialDAO.getMaterialsByCategory(category);
            } else if ("admin".equals(action) && "ADMIN".equals(user.getRole())) {
                // Admin view - show all materials
                materials = learningMaterialDAO.getAllMaterials();
                request.setAttribute("isAdmin", true);
                request.getRequestDispatcher("/admin_learning_materials.jsp").forward(request, response);
                return;
            } else {
                // Regular user view - show only published materials
                materials = learningMaterialDAO.getAllPublishedMaterials();
            }
            
            request.setAttribute("learningMaterials", materials);
            request.getRequestDispatcher("/learning_support.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Database error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("index.jsp?error=access_denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "create":
                    createLearningMaterial(request, response, user);
                    break;
                case "update":
                    updateLearningMaterial(request, response);
                    break;
                case "delete":
                    deleteLearningMaterial(request, response);
                    break;
                default:
                    response.sendRedirect("learning-materials?action=admin");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Database error: " + e.getMessage());
        }
    }
    
    private void createLearningMaterial(HttpServletRequest request, HttpServletResponse response, User user) 
            throws SQLException, IOException {
        
        LearningMaterial material = new LearningMaterial();
        material.setTitle(request.getParameter("title"));
        material.setDescription(request.getParameter("description"));
        material.setContentType(request.getParameter("contentType"));
        material.setContentUrl(request.getParameter("contentUrl"));
        material.setContentText(request.getParameter("contentText"));
        material.setCategory(request.getParameter("category"));
        material.setDifficultyLevel(request.getParameter("difficultyLevel"));
        
        try {
            material.setDurationMinutes(Integer.parseInt(request.getParameter("durationMinutes")));
        } catch (NumberFormatException e) {
            material.setDurationMinutes(30); // default value
        }
        
        material.setPublished("true".equals(request.getParameter("isPublished")));
        material.setCreatedBy(user.getId());
        
        boolean success = learningMaterialDAO.createLearningMaterial(material);
        
        if (success) {
            response.sendRedirect("learning-materials?action=admin&success=created");
        } else {
            response.sendRedirect("learning-materials?action=admin&error=create_failed");
        }
    }
    
    private void updateLearningMaterial(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        LearningMaterial material = learningMaterialDAO.getMaterialById(id);
        
        if (material != null) {
            material.setTitle(request.getParameter("title"));
            material.setDescription(request.getParameter("description"));
            material.setContentType(request.getParameter("contentType"));
            material.setContentUrl(request.getParameter("contentUrl"));
            material.setContentText(request.getParameter("contentText"));
            material.setCategory(request.getParameter("category"));
            material.setDifficultyLevel(request.getParameter("difficultyLevel"));
            
            try {
                material.setDurationMinutes(Integer.parseInt(request.getParameter("durationMinutes")));
            } catch (NumberFormatException e) {
                material.setDurationMinutes(30);
            }
            
            material.setPublished("true".equals(request.getParameter("isPublished")));
            
            boolean success = learningMaterialDAO.updateLearningMaterial(material);
            
            if (success) {
                response.sendRedirect("learning-materials?action=admin&success=updated");
            } else {
                response.sendRedirect("learning-materials?action=admin&error=update_failed");
            }
        } else {
            response.sendRedirect("learning-materials?action=admin&error=material_not_found");
        }
    }
    
    private void deleteLearningMaterial(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = learningMaterialDAO.deleteLearningMaterial(id);
        
        if (success) {
            response.sendRedirect("learning-materials?action=admin&success=deleted");
        } else {
            response.sendRedirect("learning-materials?action=admin&error=delete_failed");
        }
    }
}