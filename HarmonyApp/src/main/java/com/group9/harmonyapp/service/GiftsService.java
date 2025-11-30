package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.GiftDTO;
import com.group9.harmonyapp.dto.PageResponseDTO;

public interface GiftsService {
    PageResponseDTO<GiftDTO> getUserGifts(Long userId, String status, int page, int pageSize);
}
