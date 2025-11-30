package com.group9.harmonyapp.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MerchantVerifyResultDTO {
    private Long redeemId;
    private Long userId;
    private String username;
    private Long giftId;
    private String giftName;
    private Long merchantId;
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss'Z'")
    private LocalDateTime redeemTime;
    private String status;
}
