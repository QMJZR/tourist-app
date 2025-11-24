package com.group9.harmonyapp.controller;


import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.SpotDetailResponse;
import com.group9.harmonyapp.po.Zone;
import com.group9.harmonyapp.service.ZoneService;
import com.group9.harmonyapp.service.SpotService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ZoneSpotController {
    private final ZoneService zoneService;
    private final SpotService spotService;
    @GetMapping("/zones")
    public Response<List<Zone>> getZones() {
        return zoneService.getAllZones();
    }


    @GetMapping("/spots")
    public Response<PageResponseDTO> getSpots(
            @RequestParam(required = false) Long zoneId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize
    ) {
        return spotService.list(zoneId, type, keyword, page, pageSize);
    }


    @GetMapping("/spots/{id}")
    public Response<SpotDetailResponse> getSpotDetail(@PathVariable Long id) {
        return spotService.detail(id);
    }
}