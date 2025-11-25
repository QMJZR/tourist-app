package com.group9.harmonyapp.util;

import org.springframework.stereotype.Component;

@Component
public class GeoUtil {

    private static final double EARTH_RADIUS = 6378137;

    public static Integer distance(double lat1, double lng1, double lat2, double lng2) {
        double radLat1 = Math.toRadians(lat1);
        double radLat2 = Math.toRadians(lat2);
        double a = radLat1 - radLat2;
        double b = Math.toRadians(lng1) - Math.toRadians(lng2);

        double s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a / 2), 2)
                + Math.cos(radLat1) * Math.cos(radLat2)
                * Math.pow(Math.sin(b / 2), 2)));

        return (int) (s * EARTH_RADIUS);
    }
}
