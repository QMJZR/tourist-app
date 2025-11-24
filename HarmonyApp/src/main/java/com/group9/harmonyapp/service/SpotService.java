package com.group9.harmonyapp.service;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.SpotDetailResponse;

import com.group9.harmonyapp.dto.SpotListItemDTO;
import org.springframework.stereotype.Service;


@Service
public interface SpotService {
    PageResponseDTO<SpotListItemDTO> list(Long zoneId, String type, String keyword, int page, int pageSize);
    SpotDetailResponse detail(Long id);
}