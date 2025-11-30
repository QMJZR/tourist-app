package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class AdminCheckpointCreateDTO {
    private Long spotId;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer radius;
}
