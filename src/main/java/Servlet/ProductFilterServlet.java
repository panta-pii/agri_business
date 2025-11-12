package Servlet;


import daos.ProductDAO;
import models.Product;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Comparator;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/ProductFilterServlet")
public class ProductFilterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String category = request.getParameter("category");
        String search = request.getParameter("search");
        String sort = request.getParameter("sort");

        ProductDAO daos = new ProductDAO();
        List<Product> products;

        // Filtering
        if (search != null && !search.trim().isEmpty()) {
            products = daos.searchProducts(search);
        } else if (category != null && !"all".equalsIgnoreCase(category)) {
            products = daos.getProductsByCategory(category);
        } else {
            products = daos.getAllAvailableProducts();
        }

        // Sorting
        if ("price_low".equals(sort)) {
            products.sort(Comparator.comparing(Product::getPrice));
        } else if ("price_high".equals(sort)) {
            products.sort(Comparator.comparing(Product::getPrice).reversed());
        }

        // Output updated products HTML
        for (Product p : products) {
            out.println("<div class='col-md-4 col-sm-6'>"
                    + "<div class='card product-card'>"
                    + "<img src='ImageServlet?id=" + p.getId() + "' class='card-img-top product-image' alt='" + p.getName() + "'>"
                    + "<div class='card-body'>"
                    + "<h5>" + p.getName() + "</h5>"
                    + "<p class='text-muted small'>" + p.getCategory() + "</p>"
                    + "<p>" + p.getDescription() + "</p>"
                    + "<div class='d-flex justify-content-between align-items-center'>"
                    + "<span class='text-success fw-bold'>M " + p.getPrice() + "</span>"
                    + "<button class='btn btn-outline-success btn-sm' onclick=\"addToCart(" + p.getId() + ",'" + p.getName().replace("'", "\\'") + "'," + p.getPrice() + ",'ImageServlet?id=" + p.getId() + "')\">"
                    + "<i class='fas fa-cart-plus'></i> Add</button>"
                    + "</div></div></div></div>");
        }
    }
}
