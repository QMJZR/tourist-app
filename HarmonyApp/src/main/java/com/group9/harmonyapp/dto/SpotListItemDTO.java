package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class SpotListItemDTO {
    private Long spotId;
    private String name;
    private String thumbnail;
    private String summary;
    private Long zoneId;
    private Long distance; // 如果没有定位，这里可以为 null
}