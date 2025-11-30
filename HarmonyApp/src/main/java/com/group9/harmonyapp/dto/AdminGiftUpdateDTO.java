package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class AdminGiftUpdateDTO {
    private String name;
    private String description;
    private List<String> images;
    private Integer pointsRequired;
    private Integer stock;
    private String status;
    private String supplier;
    private String validity;
}
