<%-- 
    Document   : weather
    Created on : Nov 7, 2025, 8:31:01 PM
    Author     : pantapii36
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>3-Hour Weather Forecast</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 50px;
            }
            .card {
                border: 1px solid #ccc;
                padding: 20px;
                border-radius: 8px;
                max-width: 400px;
            }
        </style>
    </head>
    <body>

        <div class="card">
            <%-- Use Expression Language (EL) to retrieve attributes from the Servlet --%>
            <h1>Weather for ${city}</h1>

            <p><strong>Status:</strong> ${weather.description}</p>
            <p><strong>Temperature:</strong> 
                <span style="font-size: 24px;">${weather.temperature} &deg;F</span>
            </p>
            <p><strong>Wind Speed:</strong> ${weather.windSpeed} mph</p>

            <p><em>(Data retrieved from RapidAPI)</em></p>
        </div>

    </body>
</html>
