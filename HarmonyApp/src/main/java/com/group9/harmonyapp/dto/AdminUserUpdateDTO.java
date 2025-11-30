package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class AdminUserUpdateDTO {
    private String nickname;
    private String avatar;
    private Integer points;
    private String isMerchant; // Y or N
}
