package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.SpotDetailResponse;
import com.group9.harmonyapp.dto.AdminSpotCreateDTO;
import com.group9.harmonyapp.dto.AdminSpotUpdateDTO;
import com.group9.harmonyapp.dto.AdminSpotResultDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Spot;
import com.group9.harmonyapp.repository.SpotRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/spots")
@RequiredArgsConstructor
public class AdminSpotController {

    private final SpotRepository spotRepository;
    private final AdminTokenUtil adminTokenUtil;

    @GetMapping
    public Response<List<Object>> getSpots(
            @RequestParam(required = false) Long zoneId,
            @RequestParam(required = false) String name,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查询景点列表（支持 zoneId 和 name 筛选）
        List<Spot> spots = spotRepository.findAll((root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (zoneId != null) {
                predicates.add(cb.equal(root.get("zoneId"), zoneId));
            }
            if (name != null && !name.isEmpty()) {
                predicates.add(cb.like(root.get("name"), "%" + name + "%"));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        });

        // 转换为响应格式
        List<Object> result = spots.stream().map(s -> {
            SpotDetailResponse response = new SpotDetailResponse();
            response.setId(s.getId());
            response.setName(s.getName());
            response.setImages(s.getImages());
            response.setVideo(s.getVideo());
            response.setDescription(s.getDescription());
            response.setZoneId(s.getZoneId());
            response.setLatitude(s.getLatitude());
            response.setLongitude(s.getLongitude());
            response.setOpenTime(s.getOpenTime());
            return (Object) response;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }

    @PostMapping
    public Response<AdminSpotResultDTO> createSpot(
            @RequestBody AdminSpotCreateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 参数验证
        if (dto.getName() == null || dto.getName().isEmpty()) {
            throw new HarmonyException("名称不能为空", 1000);
        }
        if (dto.getDescription() == null || dto.getDescription().isEmpty()) {
            throw new HarmonyException("景点详细说明不能为空", 1000);
        }
        if (dto.getZoneId() == null) {
            throw new HarmonyException("所属引领区ID不能为空", 1000);
        }
        if (dto.getLatitude() == null) {
            throw new HarmonyException("地理坐标（纬度）不能为空", 1000);
        }
        if (dto.getLongitude() == null) {
            throw new HarmonyException("地理坐标（经度）不能为空", 1000);
        }

        // 创建景点
        Spot spot = new Spot();
        spot.setName(dto.getName());
        spot.setImages(dto.getImages());
        spot.setVideo(dto.getVideo());
        spot.setDescription(dto.getDescription());
        spot.setZoneId(dto.getZoneId());
        spot.setLatitude(dto.getLatitude());
        spot.setLongitude(dto.getLongitude());
        spot.setOpenTime(dto.getOpenTime());
        spot.setType("spot");

        Spot savedSpot = spotRepository.save(spot);

        AdminSpotResultDTO result = new AdminSpotResultDTO();
        result.setSpotId(savedSpot.getId());

        return Response.buildSuccess(result, "新增成功");
    }

    @PutMapping("/{spotId}")
    public Response<Void> updateSpot(
            @PathVariable Long spotId,
            @RequestBody AdminSpotUpdateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查找景点
        Spot spot = spotRepository.findById(spotId).orElse(null);
        if (spot == null) {
            throw new HarmonyException("景点不存在", 404);
        }

        // 更新字段（仅更新非 null 字段）
        if (dto.getName() != null) {
            spot.setName(dto.getName());
        }
        if (dto.getImages() != null) {
            spot.setImages(dto.getImages());
        }
        if (dto.getVideo() != null) {
            spot.setVideo(dto.getVideo());
        }
        if (dto.getDescription() != null) {
            spot.setDescription(dto.getDescription());
        }
        if (dto.getZoneId() != null) {
            spot.setZoneId(dto.getZoneId());
        }
        if (dto.getLatitude() != null) {
            spot.setLatitude(dto.getLatitude());
        }
        if (dto.getLongitude() != null) {
            spot.setLongitude(dto.getLongitude());
        }
        if (dto.getOpenTime() != null) {
            spot.setOpenTime(dto.getOpenTime());
        }

        spotRepository.save(spot);

        return Response.buildSuccess(null, "更新成功");
    }

    @DeleteMapping("/{spotId}")
    public Response<Void> deleteSpot(
            @PathVariable Long spotId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查找景点
        Spot spot = spotRepository.findById(spotId).orElse(null);
        if (spot == null) {
            throw new HarmonyException("景点不存在", 404);
        }

        // 删除景点
        spotRepository.delete(spot);

        return Response.buildSuccess(null, "删除成功");
    }
}

