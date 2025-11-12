package Servlet;

import com.google.gson.Gson;
import daos.ProductDAO;
import utils.DemandPredictor;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/demandForecast")
public class DemandForecastServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private Gson gson = new Gson();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, List<Integer>> data = productDAO.getMonthlyProductCounts(3);
        Map<String, Object> result = new LinkedHashMap<>();

        for (String product : data.keySet()) {
            List<Integer> counts = data.get(product);
            double prediction = DemandPredictor.predictNextMonthDemand(counts);
            String trend = DemandPredictor.getTrend(counts);

            Map<String, Object> info = new HashMap<>();
            info.put("history", counts);
            info.put("predicted", prediction);
            info.put("trend", trend);

            result.put(product, info);
        }

        resp.setContentType("application/json");
        resp.getWriter().print(gson.toJson(result));
    }
}