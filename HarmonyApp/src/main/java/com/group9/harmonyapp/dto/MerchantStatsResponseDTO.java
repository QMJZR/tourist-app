package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class MerchantStatsResponseDTO {
    private Long totalVerified;
    private List<DailyStatDTO> dailyStats;
    private List<MerchantRedeemDetailDTO> details;
}
