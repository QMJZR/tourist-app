package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RecommendationDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.service.RecommendService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/recommend")
@RequiredArgsConstructor
public class RecommendController {

    private final RecommendService recommendService;

    @GetMapping("/nearby")
    public Response<PageResponseDTO<RecommendationDTO>> nearby(
            @RequestParam(required = true) Double latitude,
            @RequestParam(required = true) Double longitude,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize
    ) {
        return Response.buildSuccess(recommendService.nearby(latitude, longitude, sort, type, page, pageSize));
    }
}
