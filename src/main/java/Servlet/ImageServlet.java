/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Servlet;


import daos.ProductDAO;
import models.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/image")
public class ImageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productId = request.getParameter("id");
        
        if (productId == null || productId.trim().isEmpty()) {
            // Return default image
            response.sendRedirect("https://placehold.co/300x200/28a745/white?text=AgriYouth");
            return;
        }
        
        try {
            int id = Integer.parseInt(productId);
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getProductById(id);
            
            if (product != null && product.getImage() != null && product.getImage().length > 0) {
                response.setContentType("image/jpeg");
                response.setContentLength(product.getImage().length);
                
                try (OutputStream out = response.getOutputStream()) {
                    out.write(product.getImage());
                    out.flush();
                }
            } else {
                // Return placeholder image with product name
                String placeholderUrl = "https://placehold.co/300x200/28a745/white?text=" + 
                    (product != null ? product.getName().replace(" ", "+") : "Product");
                response.sendRedirect(placeholderUrl);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("https://placehold.co/300x200/28a745/white?text=Invalid+ID");
        } catch (Exception e) {
            response.sendRedirect("https://placehold.co/300x200/28a745/white?text=Error");
        }
    }
}