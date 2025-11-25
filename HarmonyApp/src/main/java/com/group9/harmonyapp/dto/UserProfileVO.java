package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class UserProfileVO {
    private Long userId;
    private String username;
    private String avatar;
    private Integer points;
    private Integer checkinCount;
    private String isMerchant;
}
