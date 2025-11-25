package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.FeedLikeDTO;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;


public interface FeedLikeService {
    @Transactional
    FeedLikeDTO like(Long feedId, Long userId);

    @Transactional
    FeedLikeDTO unlike(Long feedId, Long userId);
}
