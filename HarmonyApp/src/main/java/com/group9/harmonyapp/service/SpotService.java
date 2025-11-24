package com.group9.harmonyapp.service;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.SpotDetailResponse;

import org.springframework.stereotype.Service;


@Service
public interface SpotService {
    Response<PageResponseDTO> list(Long zoneId, String type, String keyword, int page, int pageSize);
    Response<SpotDetailResponse> detail(Long id);
}