package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.CheckinRecordDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.service.CheckinService;
import com.group9.harmonyapp.service.AuthService;
import com.group9.harmonyapp.service.GiftsService;
import com.group9.harmonyapp.util.TokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserCenterController {

    private final CheckinService checkinService;
    private final TokenUtil tokenUtil;
    private final com.group9.harmonyapp.service.PointsService pointsService;
    private final GiftsService giftsService;
    private final AuthService authService;

    @GetMapping("/checkins")
    public Response<PageResponseDTO<CheckinRecordDTO>> getCheckins(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestHeader("token") String auth
    ) {
        if (!tokenUtil.verifyToken(auth)) {
            return Response.buildFailure("未授权的访问，请先登录", 1201);
        }
        Long userId = tokenUtil.getUser(auth).getId();
        PageResponseDTO<CheckinRecordDTO> data = checkinService.getUserCheckins(userId, page, pageSize);
        return Response.buildSuccess(data);
    }

    @GetMapping("/points")
    public Response<PageResponseDTO<com.group9.harmonyapp.dto.PointRecordDTO>> getPoints(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestHeader("token") String auth
    ) {
        if (!tokenUtil.verifyToken(auth)) {
            return Response.buildFailure("未授权的访问，请先登录", 1201);
        }
        Long userId = tokenUtil.getUser(auth).getId();
        PageResponseDTO<com.group9.harmonyapp.dto.PointRecordDTO> data = pointsService.getUserPoints(userId, page, pageSize);
        return Response.buildSuccess(data);
    }

    @GetMapping("/gifts")
    public Response<PageResponseDTO<com.group9.harmonyapp.dto.GiftDTO>> getGifts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String status,
            @RequestHeader("token") String auth
    ) {
        if (!tokenUtil.verifyToken(auth)) {
            return Response.buildFailure("未授权的访问，请先登录", 1201);
        }
        Long userId = tokenUtil.getUser(auth).getId();
        PageResponseDTO<com.group9.harmonyapp.dto.GiftDTO> data = giftsService.getUserGifts(userId, status, page, pageSize);
        return Response.buildSuccess(data);
    }

    @PutMapping("/profile")
    public Response<com.group9.harmonyapp.dto.UserProfileVO> updateProfile(
            @RequestBody com.group9.harmonyapp.dto.UpdateProfileDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !tokenUtil.verifyToken(token)) {
            return Response.buildFailure("Token 已失效，请重新登录", 1202);
        }
        Long userId = tokenUtil.getUser(token).getId();
        com.group9.harmonyapp.dto.UserProfileVO updated = authService.updateProfile(userId, dto);
        return Response.buildSuccess(updated, "修改成功");
    }
}
