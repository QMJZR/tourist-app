package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.PointRecordDTO;

public interface PointsService {
    PageResponseDTO<PointRecordDTO> getUserPoints(Long userId, int page, int pageSize);
}
