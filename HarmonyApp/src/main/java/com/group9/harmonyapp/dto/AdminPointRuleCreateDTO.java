package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class AdminPointRuleCreateDTO {
    private String type;
    private String description;
    private Integer points;
    private String status;
}
