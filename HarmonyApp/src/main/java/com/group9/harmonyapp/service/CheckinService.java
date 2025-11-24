package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;

import java.util.List;

public interface CheckinService {
    List<SpotCheckinInfoDTO>  listSpots(Double lat, Double lng, String sort);

    CheckinResultDTO submitCheckin(Long userId, CheckinSubmitRequest req);
}
