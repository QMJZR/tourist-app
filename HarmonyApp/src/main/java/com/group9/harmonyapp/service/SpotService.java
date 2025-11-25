package com.group9.harmonyapp.service;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.SpotDetailResponse;

import com.group9.harmonyapp.dto.SpotListItemDTO;
import com.group9.harmonyapp.po.Spot;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
public interface SpotService {
    PageResponseDTO<SpotListItemDTO> list(Long zoneId, String type, String keyword, int page, int pageSize);
    SpotDetailResponse detail(Long id);
    List<Spot> findNearby(Double lat, Double lng, Integer radius);
}