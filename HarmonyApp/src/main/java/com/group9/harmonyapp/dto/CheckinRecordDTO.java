package com.group9.harmonyapp.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CheckinRecordDTO {
    private Long checkinId;
    private Long spotId;
    private String spotName;
    private List<String> images;
    private Integer pointsEarned;
    private LocalDateTime createdAt;
}
