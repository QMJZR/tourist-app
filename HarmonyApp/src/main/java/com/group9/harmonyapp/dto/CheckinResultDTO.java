package com.group9.harmonyapp.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CheckinResultDTO {
    private Long checkinId;
    private Integer points;
    private Long spotId;
    private LocalDateTime checkinTime;
    private String message;
}
