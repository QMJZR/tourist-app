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
            @RequestHeader("Authorization") String auth
    )
    {
        if(tokenUtil.verifyToken(auth)){
            return Response.buildSuccess(checkinService.submitCheckin(tokenUtil.getUser(auth).getId(), req));
        }else {
            return Response.buildFailure("未授权的访问，请先登录", 1201);
        }

    }
}
