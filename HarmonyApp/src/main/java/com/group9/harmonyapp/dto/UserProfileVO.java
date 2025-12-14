package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class UserProfileVO {
    private Long userId;
    private String username;
    private String nickname;
    private String avatar;
    private Integer points;
    private Integer checkinCount;
    private String isMerchant;
    private List<Long> checkinSpotIds;
    private String email;
}
