package com.group9.harmonyapp.dto;

import lombok.Data;

@Data
public class FeedLikeDTO {
    private Integer feedId;
    private Integer likes;
    private Boolean liked;

    public FeedLikeDTO(Long feedId, Integer likes, boolean b) {
        this.feedId = feedId.intValue();
        this.likes = likes;
        this.liked = b;
    }
}
