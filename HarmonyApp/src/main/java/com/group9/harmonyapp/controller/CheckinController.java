package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.CheckinResultDTO;
import com.group9.harmonyapp.dto.CheckinSubmitRequest;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.SpotCheckinInfoDTO;
import com.group9.harmonyapp.service.CheckinService;
import com.group9.harmonyapp.util.TokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/checkin")
@RequiredArgsConstructor
public class CheckinController {

    private final CheckinService checkinService;
    private final TokenUtil tokenUtil;
    @GetMapping("/spots")
    public Response<List<SpotCheckinInfoDTO>> listSpots(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) String sort
    ) {
        return Response.buildSuccess(checkinService.listSpots(lat, lng, sort));
    }

    @PostMapping("/submit")
    public Response<CheckinResultDTO> submit(
            @RequestBody CheckinSubmitRequest req,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (authorization != null) {
            token = authorization;
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }

        if (token == null || !tokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权的访问，请先登录", 1201);
        }

        return Response.buildSuccess(checkinService.submitCheckin(tokenUtil.getUser(token).getId(), req));
    }
}
