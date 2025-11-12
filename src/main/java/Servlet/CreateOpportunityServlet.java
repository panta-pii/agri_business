package Servlet;

import daos.OpportunityDAO;
import models.Opportunity;
import models.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/CreateOpportunityServlet")
public class CreateOpportunityServlet extends HttpServlet {

    private OpportunityDAO opportunityDAO;

    @Override
    public void init() throws ServletException {
        opportunityDAO = new OpportunityDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String type = request.getParameter("type");
            String category = request.getParameter("category");
            double budget = Double.parseDouble(request.getParameter("budget"));
            String deadline = request.getParameter("deadline");

            Opportunity opportunity = new Opportunity();
            opportunity.setTitle(title);
            opportunity.setDescription(description);
            opportunity.setType(type);
            opportunity.setCategory(category);
            opportunity.setBudget(budget);
            opportunity.setDeadline(java.sql.Date.valueOf(deadline));
            opportunity.setStatus("ACTIVE");
            opportunity.setCreatedBy(user.getId());

            boolean success = opportunityDAO.createOpportunity(opportunity);

            if (success) {
                response.sendRedirect("opportunities.jsp?success=created");
            } else {
                response.sendRedirect("create-opportunity.jsp?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("create-opportunity.jsp?error=server");
        }
    }
}
