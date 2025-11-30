package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Gift;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.po.UserGift;
import com.group9.harmonyapp.repository.GiftRepository;
import com.group9.harmonyapp.repository.UserGiftRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.util.TokenUtil;
import com.group9.harmonyapp.dto.Response;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("/merchant")
public class MerchantController {

    private final TokenUtil tokenUtil;
    private final UserRepository userRepository;
    private final GiftRepository giftRepository;
    private final UserGiftRepository userGiftRepository;

    // 验证商家 token 并返回商家 User
    private User validateMerchant(String authorization, String tokenHeader) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !tokenUtil.verifyToken(token)) {
            throw new HarmonyException("未授权，请登录", 401);
        }
        User user = tokenUtil.getUser(token);
        if (!"Y".equalsIgnoreCase(user.getIsMerchant())) {
            throw new HarmonyException("未授权，非商家账号", 401);
        }
        return user;
    }

    @PostMapping("/verify")
    public Response<MerchantVerifyResultDTO> verifyRedeem(
            @RequestBody MerchantVerifyRequestDTO req,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        User merchant = validateMerchant(authorization, tokenHeader);

        // 查找兑换记录
        UserGift redeem = userGiftRepository.findById(req.getRedeemId()).orElse(null);
        if (redeem == null) {
            return Response.buildFailure("兑换记录不存在", 404);
        }

        // 校验 giftCode
        if (req.getGiftCode() == null || !req.getGiftCode().equals(redeem.getGiftCode())) {
            return Response.buildFailure("礼品码不匹配", 400);
        }

        // 查找礼品
        Gift gift = giftRepository.findById(redeem.getGiftId()).orElse(null);
        if (gift == null) {
            return Response.buildFailure("礼品不存在", 404);
        }

        // 检查礼品是否属于该商家
        Long merchantId = merchant.getId();
        if (gift.getMerchantId() == null || !merchantId.equals(gift.getMerchantId())) {
            return Response.buildFailure("该礼品不属于当前商家", 403);
        }

        // 检查状态和有效期
        if (redeem.getStatus() == null) redeem.setStatus("pending");
        String st = redeem.getStatus();
        if ("verified".equalsIgnoreCase(st) || "expired".equalsIgnoreCase(st)) {
            return Response.buildFailure("兑换记录状态异常（已核销或已过期）", 400);
        }

        if (gift.getValidity() != null && !gift.getValidity().isEmpty()) {
            LocalDate validityDate = LocalDate.parse(gift.getValidity());
            if (LocalDate.now().isAfter(validityDate)) {
                // mark redeem expired
                redeem.setStatus("expired");
                userGiftRepository.save(redeem);
                return Response.buildFailure("兑换记录状态异常（已核销或已过期）", 400);
            }
        }

        // 执行核销
        redeem.setStatus("verified");
        redeem.setRedeemedAt(LocalDateTime.now());
        userGiftRepository.save(redeem);

        MerchantVerifyResultDTO res = new MerchantVerifyResultDTO();
        res.setRedeemId(redeem.getId());
        res.setUserId(redeem.getUserId());
        User u = userRepository.findById(redeem.getUserId()).orElse(null);
        if (u != null) res.setUsername(u.getUsername());
        res.setGiftId(gift.getId());
        res.setGiftName(gift.getName());
        res.setMerchantId(merchantId);
        res.setRedeemTime(redeem.getRedeemedAt());
        res.setStatus(redeem.getStatus());

        return Response.buildSuccess(res, "核销成功");
    }

    @GetMapping("/stats")
    public Response<MerchantStatsResponseDTO> getStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long giftId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        User merchant = validateMerchant(authorization, tokenHeader);
        Long merchantId = merchant.getId();

        // 收集该商家下的礼品ID
        List<Gift> merchantGifts = giftRepository.findAll().stream()
                .filter(g -> g.getMerchantId() != null && merchantId.equals(g.getMerchantId()))
                .collect(Collectors.toList());
        Set<Long> merchantGiftIds = merchantGifts.stream().map(Gift::getId).collect(Collectors.toSet());

        List<UserGift> redeems = new ArrayList<>();
        if (giftId != null) {
            // ensure gift belongs to merchant
            if (!merchantGiftIds.contains(giftId)) {
                return Response.buildFailure("该礼品不属于当前商家", 403);
            }
            redeems = userGiftRepository.findByGiftIdOrderByRedeemedAtDesc(giftId);
        } else {
            // collect redeems for all merchant gifts
            for (Long gid : merchantGiftIds) {
                redeems.addAll(userGiftRepository.findByGiftIdOrderByRedeemedAtDesc(gid));
            }
            // sort by redeemedAt desc
            redeems.sort((a,b) -> {
                if (a.getRedeemedAt() == null && b.getRedeemedAt() == null) return 0;
                if (a.getRedeemedAt() == null) return 1;
                if (b.getRedeemedAt() == null) return -1;
                return b.getRedeemedAt().compareTo(a.getRedeemedAt());
            });
        }

        // filter by date range
        if ((startDate != null && !startDate.isEmpty()) || (endDate != null && !endDate.isEmpty())) {
            LocalDateTime startDT = startDate != null && !startDate.isEmpty() ? LocalDate.parse(startDate).atStartOfDay() : null;
            LocalDateTime endDT = endDate != null && !endDate.isEmpty() ? LocalDate.parse(endDate).atTime(LocalTime.MAX) : null;
            redeems = redeems.stream().filter(r -> {
                LocalDateTime t = r.getRedeemedAt();
                if (t == null) return false;
                boolean ok = true;
                if (startDT != null) ok = ok && !t.isBefore(startDT);
                if (endDT != null) ok = ok && !t.isAfter(endDT);
                return ok;
            }).collect(Collectors.toList());
        }

        // totalVerified
        long totalVerified = redeems.stream().filter(r -> "verified".equalsIgnoreCase(r.getStatus())).count();

        // dailyStats grouping
        Map<String, Long> dailyMap = redeems.stream()
                .filter(r -> r.getRedeemedAt() != null)
                .collect(Collectors.groupingBy(r -> r.getRedeemedAt().toLocalDate().toString(), Collectors.counting()));

        List<DailyStatDTO> dailyStats = dailyMap.entrySet().stream()
                .map(e -> {
                    DailyStatDTO d = new DailyStatDTO();
                    d.setDate(e.getKey());
                    d.setVerifiedCount(e.getValue());
                    return d;
                }).sorted(Comparator.comparing(DailyStatDTO::getDate)).collect(Collectors.toList());

        // details
        List<MerchantRedeemDetailDTO> details = redeems.stream().map(r -> {
            MerchantRedeemDetailDTO d = new MerchantRedeemDetailDTO();
            d.setRedeemId(r.getId());
            d.setUserId(r.getUserId());
            User u = userRepository.findById(r.getUserId()).orElse(null);
            if (u != null) d.setUsername(u.getUsername());
            d.setGiftId(r.getGiftId());
            Gift g = giftRepository.findById(r.getGiftId()).orElse(null);
            if (g != null) d.setGiftName(g.getName());
            d.setRedeemTime(r.getRedeemedAt());
            d.setStatus(r.getStatus());
            return d;
        }).collect(Collectors.toList());

        MerchantStatsResponseDTO res = new MerchantStatsResponseDTO();
        res.setTotalVerified(totalVerified);
        res.setDailyStats(dailyStats);
        res.setDetails(details);

        return Response.buildSuccess(res);
    }
}
