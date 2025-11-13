package Servlet;

import daos.OpportunityDAO;
import models.Opportunity;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/OpportunitiesServlet")
public class OpportunitiesServlet extends HttpServlet {
    private OpportunityDAO opportunityDAO;

    @Override
    public void init() throws ServletException {
        opportunityDAO = new OpportunityDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== OPPORTUNITIES SERVLET CALLED ===");
        
        try {
            // Get parameters
            String search = request.getParameter("search");
            String category = request.getParameter("category");
            String type = request.getParameter("type");

            System.out.println("Parameters - Search: " + search + ", Category: " + category + ", Type: " + type);

            List<Opportunity> opportunities;

            // Use filtered opportunities if any filter is applied
            if ((search != null && !search.trim().isEmpty()) || 
                (category != null && !category.trim().isEmpty()) || 
                (type != null && !type.trim().isEmpty())) {
                
                opportunities = opportunityDAO.getFilteredOpportunities(search, category, type);
                System.out.println("Using FILTERED opportunities: " + opportunities.size());
                
            } else {
                // Get all active opportunities
                opportunities = opportunityDAO.getAllOpportunities();
                // Filter only active opportunities
                List<Opportunity> activeOpportunities = new ArrayList<>();
                for (Opportunity opp : opportunities) {
                    if (opp != null && "ACTIVE".equals(opp.getStatus())) {
                        activeOpportunities.add(opp);
                    }
                }
                opportunities = activeOpportunities;
                System.out.println("Using ALL ACTIVE opportunities: " + opportunities.size());
            }

            // Set attributes for JSP
            request.setAttribute("opportunities", opportunities);
            request.setAttribute("searchQuery", search);
            request.setAttribute("categoryFilter", category);
            request.setAttribute("typeFilter", type);

            System.out.println("Forwarding to opportunities.jsp with " + opportunities.size() + " opportunities");

            // Forward to JSP
            RequestDispatcher dispatcher = request.getRequestDispatcher("/opportunities.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("ERROR in OpportunitiesServlet: " + e.getMessage());
            
            // On error, still forward but with empty list
            request.setAttribute("opportunities", new ArrayList<Opportunity>());
            request.setAttribute("errorMessage", "Unable to load opportunities. Please try again.");
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/opportunities.jsp");
            dispatcher.forward(request, response);
        }
    }
}