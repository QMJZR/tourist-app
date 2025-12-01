package com.group9.harmonyapp.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PointRecordDTO {
    private Long recordId;
    private String type; // earn/spend
    private String source;
    private Integer points;
    private LocalDateTime createdAt;
}
