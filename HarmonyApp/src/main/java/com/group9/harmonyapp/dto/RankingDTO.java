package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class RankingDTO {
    private Integer rank;
    private Long userId;
    private String username;
    private String avatar;
    private Long totalCheckins;
    private Integer totalLikes;
    private Integer score;
}
