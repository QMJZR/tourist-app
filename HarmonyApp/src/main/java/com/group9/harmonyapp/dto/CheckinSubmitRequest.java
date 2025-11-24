package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class CheckinSubmitRequest {
    private Long spotId;
    private Double latitude;
    private Double longitude;
    private String image; // base64，可空
}