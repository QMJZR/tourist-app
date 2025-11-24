package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class SpotCheckinInfoDTO {
    private Long spotId;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer radius;
    private String thumbnail;
    private Integer distance; // 可能为 null
}