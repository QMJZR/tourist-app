package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RankingDTO;

public interface RankingsService {
    PageResponseDTO<RankingDTO> list(String period, int page, int pageSize, String sort);
}
