package com.group9.harmonyapp.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class GiftDTO {
    private Long id;
    private String name;
    private Integer pointsRequired;
    private String status;
    private Integer stock;
    private LocalDateTime createdAt;
    private LocalDateTime redeemedAt; // if user has redeemed
}
