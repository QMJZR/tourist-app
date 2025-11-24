package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;

import java.util.List;

public interface CheckinService {
    Response<List<SpotCheckinInfoDTO>>  listSpots(Double lat, Double lng, String sort);

    Response<CheckinResultDTO> submitCheckin(Long userId, CheckinSubmitRequest req);
}
