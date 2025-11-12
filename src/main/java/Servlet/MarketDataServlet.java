package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/market-data")
public class MarketDataServlet extends HttpServlet {

    private static final String API_KEY = "3d9a370c91d3274063b1b58608f6ece3";
    private static final String BASE_URL = "http://api.marketstack.com/v2/eod";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");
        PrintWriter out = resp.getWriter();

        // Use REAL agri-business stocks
        String symbolsParam = req.getParameter("symbols");
        String symbols = (symbolsParam != null && !symbolsParam.isEmpty()) 
            ? symbolsParam 
            : "DE,ADM,BG,CTVA";  // All valid

        try {
            String url = String.format("%s?access_key=%s&symbols=%s&limit=1&sort=DESC", BASE_URL, API_KEY, symbols);
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();

            HttpClient client = HttpClient.newHttpClient();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            String jsonResponse = response.body();

            JSONObject root = new JSONObject(jsonResponse);
            if (root.has("data") && root.getJSONArray("data").length() > 0) {
                JSONArray dataArray = root.getJSONArray("data");
                JSONArray marketData = new JSONArray();

                for (int i = 0; i < dataArray.length(); i++) {
                    JSONObject item = dataArray.getJSONObject(i);
                    JSONObject stock = new JSONObject();
                    stock.put("symbol", item.optString("symbol"));
                    stock.put("date", item.optString("date"));
                    stock.put("open", item.optDouble("open", 0.0));
                    stock.put("high", item.optDouble("high", 0.0));
                    stock.put("low", item.optDouble("low", 0.0));
                    stock.put("close", item.optDouble("close", 0.0));
                    stock.put("volume", item.optLong("volume", 0L));
                    stock.put("currency", item.optString("currency", "USD"));
                    stock.put("category", getCategory(item.optString("symbol")));
                    marketData.put(stock);
                }

                JSONObject result = new JSONObject();
                result.put("status", "success");
                result.put("source", "marketstack");
                result.put("lastUpdated", LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                JSONObject data = new JSONObject();
                data.put("market", marketData);
                result.put("data", data);
                out.print(result.toString());
                return;
            }

            out.print(getFallbackMarketData());

        } catch (Exception e) {
            System.out.println("Marketstack error: " + e.getMessage());
            out.print(getFallbackMarketData());
        }
    }

    private String getCategory(String symbol) {
        return switch (symbol.toUpperCase()) {
            case "DE" -> "Agri Machinery";
            case "ADM" -> "Grain Processing";
            case "BG" -> "Grain Trading";
            case "CTVA" -> "Seeds & Crop Protection";
            default -> "Agri Business";
        };
    }

    private String getFallbackMarketData() {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        return String.format("""
            {
              "status": "success",
              "source": "fallback",
              "lastUpdated": "%s",
              "data": {
                "market": [
                  {"symbol":"DE","date":"%s","open":385.5,"high":388.2,"low":382.1,"close":386.75,"volume":2450000,"currency":"USD","category":"Agri Machinery"},
                  {"symbol":"ADM","date":"%s","open":58.2,"high":59.1,"low":57.8,"close":58.9,"volume":3200000,"currency":"USD","category":"Grain Processing"},
                  {"symbol":"BG","date":"%s","open":92.5,"high":93.8,"low":91.9,"close":93.2,"volume":1100000,"currency":"USD","category":"Grain Trading"},
                  {"symbol":"CTVA","date":"%s","open":54.1,"high":55.0,"low":53.7,"close":54.6,"volume":2800000,"currency":"USD","category":"Seeds & Crop Protection"}
                ]
              }
            }
            """, date, date, date, date, date);
    }
}