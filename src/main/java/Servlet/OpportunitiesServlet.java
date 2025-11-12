package Servlet;

import daos.OpportunityDAO;
import models.Opportunity;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;


@WebServlet("/OpportunitiesServlet")
public class OpportunitiesServlet extends HttpServlet {

    private OpportunityDAO opportunityDAO;
    private static final Logger logger = Logger.getLogger(OpportunitiesServlet.class.getName());

    @Override
    public void init() throws ServletException {
        try {
            opportunityDAO = new OpportunityDAO();
            logger.info("OpportunitiesServlet initialized successfully");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to initialize OpportunitiesServlet", e);
            throw new ServletException("Failed to initialize OpportunitiesServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
    String category = request.getParameter("category");
    String type = request.getParameter("type");

    logger.info("Processing opportunities request - Search: " + search + 
               ", Category: " + category + ", Type: " + type);

    List<Opportunity> filteredOpportunities = new ArrayList<>();
    String errorMessage = null;

    try {
        if ((search != null && !search.trim().isEmpty()) || 
            (category != null && !category.trim().isEmpty()) || 
            (type != null && !type.trim().isEmpty())) {
            
            filteredOpportunities = opportunityDAO.getFilteredOpportunities(search, category, type);
            logger.info("Filtered: " + filteredOpportunities.size() + " opportunities");
            
        } else {
            List<Opportunity> allOpportunities = opportunityDAO.getAllOpportunities();
            for (Opportunity opp : allOpportunities) {
                if (opp != null && "ACTIVE".equals(opp.getStatus())) {
                    filteredOpportunities.add(opp);
                }
            }
            logger.info("All active: " + filteredOpportunities.size() + " opportunities");
        }

    } catch (Exception e) {
        logger.log(Level.SEVERE, "Error fetching opportunities", e);
        errorMessage = "Unable to load opportunities. Please try again later.";
        filteredOpportunities = new ArrayList<>();
    }

    // Always forward — even on error
    request.setAttribute("opportunities", filteredOpportunities);
    request.setAttribute("searchQuery", search);
    request.setAttribute("categoryFilter", category);
    request.setAttribute("typeFilter", type);
    if (errorMessage != null) {
        request.setAttribute("errorMessage", errorMessage);
    }

    RequestDispatcher dispatcher = request.getRequestDispatcher("/opportunities.jsp");
    dispatcher.forward(request, response);
        }
    
    @Override
    public void destroy() {
        // Clean up resources if needed
        if (opportunityDAO != null) {
            try {
                // Add any cleanup logic for OpportunityDAO if needed
                logger.info("OpportunitiesServlet destroyed");
            } catch (Exception e) {
                logger.log(Level.WARNING, "Error during OpportunitiesServlet destruction", e);
            }
        }
    }
}
