package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RecommendationDTO;

public interface RecommendService {
    PageResponseDTO<RecommendationDTO> nearby(Double latitude, Double longitude, String sort, String type, int page, int pageSize);
}
