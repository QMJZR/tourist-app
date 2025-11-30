package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class AdminCheckpointResultDTO {
    private Long checkpointId;
    private Long spotId;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer radius;
    private String status;
}
