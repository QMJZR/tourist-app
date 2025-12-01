package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class AdminUserResultDTO {
    private Long userId;
    private String username;
    private String nickname;
    private String avatar;
    private String email;
    private Integer points;
    private Long checkinCount;
    private List<Long> checkinSpotIds;
    private String isMerchant;
}
