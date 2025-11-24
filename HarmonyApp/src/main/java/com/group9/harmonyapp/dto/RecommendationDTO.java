package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class RecommendationDTO {
    private String type;
    private Long id;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer distance;
}
