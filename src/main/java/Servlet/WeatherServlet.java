package Servlet;

import models.WeatherData;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@WebServlet("/fetchWeather")
public class WeatherServlet extends HttpServlet {
    
    // NOTE: In a production application, these credentials must be loaded from 
    // a secure configuration file or environment variables, not hardcoded.
    private static final String RAPIDAPI_KEY = "a395c1ab3dmsh7cefc80411f5de0p135f43jsn79e5b188cf86";
    private static final String RAPIDAPI_HOST = "weatherbit-v1-mashape.p.rapidapi.com";
    private static final String API_URL = "https://weatherbit-v1-mashape.p.rapidapi.com/forecast/3hourly?lat=35.5&lon=-78.5&units=imperial&lang=en";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        try {
            // 1. Build the HTTP Request using the JDK 17 HttpClient
            HttpRequest apiRequest = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("x-rapidapi-key", RAPIDAPI_KEY)
                    .header("x-rapidapi-host", RAPIDAPI_HOST)
                    .GET() // Shorthand for method("GET", BodyPublishers.noBody())
                    .build();

            // 2. Execute the synchronous call (the thread waits here)
            HttpResponse<String> apiResponse = HttpClient.newHttpClient()
                    .send(apiRequest, HttpResponse.BodyHandlers.ofString());
            
            String jsonResponse = apiResponse.body();

            // Check for API errors (e.g., non-200 status code)
            if (apiResponse.statusCode() != 200) {
                 throw new IOException("API call failed with status: " + apiResponse.statusCode());
            }

            // 3. Parse the JSON response using org.json
            JSONObject root = new JSONObject(jsonResponse);
            
            // The Weatherbit API nests the forecast data in a "data" array
            // We'll grab the first (current/next) forecast item
            JSONArray dataArray = root.getJSONArray("data");
            JSONObject currentForecast = dataArray.getJSONObject(0);

            // Extract the required values
            double temp = currentForecast.getDouble("temp"); // e.g., 25.5
            int windSpd = currentForecast.getInt("wind_spd"); // e.g., 10

            // The description is nested further inside the "weather" object
            JSONObject weather = currentForecast.getJSONObject("weather");
            String description = weather.getString("description"); // e.g., "Clear skies"

            // 4. Create a clean Data Model object
            WeatherData data = new WeatherData(temp, description, windSpd);

            // 5. Set the clean object in the request scope
            request.setAttribute("weather", data);
            request.setAttribute("city", root.getString("city_name")); // Get the city name for display

            // 6. Forward to the JSP
            request.getRequestDispatcher("/weatherResult.jsp").forward(request, response);

        } catch (Exception e) {
            // Handle all exceptions (IO, JSON parsing, etc.)
            request.setAttribute("error", "Failed to retrieve or parse weather data. Reason: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
}