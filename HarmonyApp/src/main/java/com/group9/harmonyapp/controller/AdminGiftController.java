package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.AdminGiftResultDTO;
import com.group9.harmonyapp.dto.AdminGiftCreateDTO;
import com.group9.harmonyapp.dto.AdminGiftUpdateDTO;
import com.group9.harmonyapp.dto.AdminGiftStockDTO;
import com.group9.harmonyapp.dto.AdminGiftRedeemResultDTO;
import com.group9.harmonyapp.dto.AdminGiftIdResultDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Gift;
import com.group9.harmonyapp.po.UserGift;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.GiftRepository;
import com.group9.harmonyapp.repository.UserGiftRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/gifts")
@RequiredArgsConstructor
public class AdminGiftController {

    private final GiftRepository giftRepository;
    private final UserGiftRepository userGiftRepository;
    private final UserRepository userRepository;
    private final AdminTokenUtil adminTokenUtil;

    // 验证管理员 token
    private void validateToken(String authorization, String tokenHeader) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            throw new HarmonyException("未授权，请登录", 401);
        }
    }

    @GetMapping
    public Response<List<AdminGiftResultDTO>> getGifts(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 查询所有礼品
        List<Gift> gifts = giftRepository.findAll();

        // 按状态和关键字过滤
        if (status != null || keyword != null) {
            gifts = gifts.stream().filter(g -> {
                boolean match = true;
                if (status != null && !status.isEmpty()) {
                    match = match && g.getStatus().equals(status);
                }
                if (keyword != null && !keyword.isEmpty()) {
                    match = match && g.getName().contains(keyword);
                }
                return match;
            }).collect(Collectors.toList());
        }

        // 转换为响应格式
        List<AdminGiftResultDTO> result = gifts.stream().map(g -> {
            AdminGiftResultDTO dto = new AdminGiftResultDTO();
            dto.setGiftId(g.getId());
            dto.setName(g.getName());
            dto.setDescription(g.getDescription());
            dto.setImages(g.getImages());
            dto.setPointsRequired(g.getPointsRequired());
            dto.setStock(g.getStock());
            dto.setStatus(g.getStatus());
            dto.setSupplier(g.getSupplier());
            dto.setValidity(g.getValidity());
            return dto;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }

    @PostMapping
    public Response<AdminGiftIdResultDTO> createGift(
            @RequestBody AdminGiftCreateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 参数验证
        if (dto.getName() == null || dto.getName().isEmpty()) {
            throw new HarmonyException("礼品名称不能为空", 1000);
        }
        if (dto.getDescription() == null || dto.getDescription().isEmpty()) {
            throw new HarmonyException("礼品描述不能为空", 1000);
        }
        if (dto.getPointsRequired() == null) {
            throw new HarmonyException("兑换所需积分不能为空", 1000);
        }
        if (dto.getStock() == null) {
            throw new HarmonyException("库存数量不能为空", 1000);
        }
        if (dto.getStatus() == null || dto.getStatus().isEmpty()) {
            throw new HarmonyException("状态不能为空", 1000);
        }

        // 创建礼品
        Gift gift = new Gift();
        gift.setName(dto.getName());
        gift.setDescription(dto.getDescription());
        gift.setImages(dto.getImages());
        gift.setPointsRequired(dto.getPointsRequired());
        gift.setStock(dto.getStock());
        gift.setStatus(dto.getStatus());
        gift.setSupplier(dto.getSupplier());
        gift.setValidity(dto.getValidity());
        gift.setCreatedAt(LocalDateTime.now());

        Gift savedGift = giftRepository.save(gift);

        AdminGiftIdResultDTO result = new AdminGiftIdResultDTO();
        result.setGiftId(savedGift.getId());

        return Response.buildSuccess(result, "新增成功");
    }

    @PutMapping("/{giftId}")
    public Response<Void> updateGift(
            @PathVariable Long giftId,
            @RequestBody AdminGiftUpdateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 查找礼品
        Gift gift = giftRepository.findById(giftId).orElse(null);
        if (gift == null) {
            throw new HarmonyException("礼品不存在", 404);
        }

        // 更新字段（仅更新非 null 字段）
        if (dto.getName() != null) {
            gift.setName(dto.getName());
        }
        if (dto.getDescription() != null) {
            gift.setDescription(dto.getDescription());
        }
        if (dto.getImages() != null) {
            gift.setImages(dto.getImages());
        }
        if (dto.getPointsRequired() != null) {
            gift.setPointsRequired(dto.getPointsRequired());
        }
        if (dto.getStock() != null) {
            gift.setStock(dto.getStock());
        }
        if (dto.getStatus() != null) {
            gift.setStatus(dto.getStatus());
        }
        if (dto.getSupplier() != null) {
            gift.setSupplier(dto.getSupplier());
        }
        if (dto.getValidity() != null) {
            gift.setValidity(dto.getValidity());
        }

        giftRepository.save(gift);

        return Response.buildSuccess(null, "更新成功");
    }

    @DeleteMapping("/{giftId}")
    public Response<Void> deleteGift(
            @PathVariable Long giftId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 查找礼品
        Gift gift = giftRepository.findById(giftId).orElse(null);
        if (gift == null) {
            throw new HarmonyException("礼品不存在", 404);
        }

        // 删除礼品
        giftRepository.delete(gift);

        return Response.buildSuccess(null, "删除成功");
    }

    @PatchMapping("/{giftId}/stock")
    public Response<Void> updateGiftStock(
            @PathVariable Long giftId,
            @RequestBody AdminGiftStockDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 查找礼品
        Gift gift = giftRepository.findById(giftId).orElse(null);
        if (gift == null) {
            throw new HarmonyException("礼品不存在", 404);
        }

        // 更新库存
        if (dto.getStock() != null) {
            gift.setStock(dto.getStock());
        }

        giftRepository.save(gift);

        return Response.buildSuccess(null, "库存更新成功");
    }

    @GetMapping("/{giftId}/redeems")
    public Response<List<AdminGiftRedeemResultDTO>> getGiftRedeems(
            @PathVariable Long giftId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        // 查找礼品是否存在
        Gift gift = giftRepository.findById(giftId).orElse(null);
        if (gift == null) {
            throw new HarmonyException("礼品不存在", 404);
        }

        // 获取礼品的兑换记录
        List<UserGift> redeems = userGiftRepository.findByGiftIdOrderByRedeemedAtDesc(giftId);

        // 按日期过滤
        if (startDate != null || endDate != null) {
            redeems = redeems.stream().filter(r -> {
                boolean match = true;
                
                if (startDate != null) {
                    LocalDate start = LocalDate.parse(startDate);
                    LocalDateTime startDateTime = start.atStartOfDay();
                    match = match && r.getRedeemedAt().isAfter(startDateTime);
                }
                
                if (endDate != null) {
                    LocalDate end = LocalDate.parse(endDate);
                    LocalDateTime endDateTime = end.atTime(LocalTime.MAX);
                    match = match && r.getRedeemedAt().isBefore(endDateTime);
                }
                
                return match;
            }).collect(Collectors.toList());
        }

        // 转换为响应格式
        List<AdminGiftRedeemResultDTO> result = redeems.stream().map(r -> {
            AdminGiftRedeemResultDTO dto = new AdminGiftRedeemResultDTO();
            dto.setRedeemId(r.getId());
            dto.setUserId(r.getUserId());
            
            // 获取用户信息
            User user = userRepository.findById(r.getUserId()).orElse(null);
            if (user != null) {
                dto.setUsername(user.getUsername());
            }
            
            dto.setGiftId(r.getGiftId());
            dto.setPointsUsed(r.getPointsUsed());
            dto.setRedeemTime(r.getRedeemedAt());
            dto.setStatus(r.getStatus() != null ? r.getStatus() : "redeemed");
            return dto;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }
}
