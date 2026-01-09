package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RankingDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.service.RankingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rankings")
@RequiredArgsConstructor
public class RankingsController {

    private final RankingsService rankingsService;

    @GetMapping
    public Response<PageResponseDTO<RankingDTO>> list(
            @RequestParam(defaultValue = "weekly") String period,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String sort
    ) {
        PageResponseDTO<RankingDTO> data = rankingsService.list(period, page, pageSize, sort);
        return Response.buildSuccess(data);
    }
}
