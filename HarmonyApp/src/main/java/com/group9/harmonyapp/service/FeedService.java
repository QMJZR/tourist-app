package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.FeedResponseDTO;
import com.group9.harmonyapp.dto.PageResponseDTO;

public interface FeedService {
    PageResponseDTO<FeedResponseDTO> list(Long loginUserId, Long userId,
                                                 String keyword, String sort,
                                                 int page, int pageSize);
}
