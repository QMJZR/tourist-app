package com.group9.harmonyapp.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class FeedResponseDTO {
    private Long feedId;
    private Long userId;
    private String username; // 从 UserService 获取
    private String avatar;

    private Long spotId;
    private String spotName;

    private String content;
    private List<String> images;

    private Integer likes;
    private boolean liked;
    private LocalDateTime createdAt;
}