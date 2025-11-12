package utils;

import java.util.*;

public class DemandPredictor {

    // Simple demand prediction using moving average
    public static double predictNextMonthDemand(List<Integer> pastMonthCounts) {
        if (pastMonthCounts == null || pastMonthCounts.isEmpty()) return 0.0;

        double sum = 0;
        for (int count : pastMonthCounts) sum += count;
        return sum / pastMonthCounts.size(); // Average count
    }

    // Trend direction (increasing/decreasing)
    public static String getTrend(List<Integer> pastMonthCounts) {
        if (pastMonthCounts.size() < 2) return "Stable";

        int last = pastMonthCounts.get(pastMonthCounts.size() - 1);
        int prev = pastMonthCounts.get(pastMonthCounts.size() - 2);

        if (last > prev) return "Increasing";
        if (last < prev) return "Decreasing";
        return "Stable";
    }
}
