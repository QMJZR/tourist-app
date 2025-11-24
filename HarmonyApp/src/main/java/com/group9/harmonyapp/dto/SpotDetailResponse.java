package com.group9.harmonyapp.dto;
import lombok.Data;

import java.util.List;
@Data
public class SpotDetailResponse {
    private Long id;
    private String name;
    private String thumbnail;
    private String summary;
    private Long zoneId;
    private Double latitude;
    private Double longitude;
    private String description;
    private String openTime;
    private String video;
    private List<String> images;
    private String type;
}
