package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class AdminSpotUpdateDTO {
    private String name;
    private List<String> images;
    private String video;
    private String description;
    private Long zoneId;
    private Double latitude;
    private Double longitude;
    private String openTime;
}
