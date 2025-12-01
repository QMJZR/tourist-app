package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class MerchantVerifyRequestDTO {
    private Long redeemId;
    private String giftCode;
}
