package models;

/**
 * Simple POJO to hold weather data elements.
 */
public class WeatherData {

    private double temperature;
    private String description;
    private int windSpeed;

    public WeatherData(double temperature, String description, int windSpeed) {
        this.temperature = temperature;
        this.description = description;
        this.windSpeed = windSpeed;
    }

    // Standard Getters (JSP uses these via Expression Language)
    public double getTemperature() {
        return temperature;
    }

    public String getDescription() {
        return description;
    }

    public int getWindSpeed() {
        return windSpeed;
    }
}
