package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.GiftDTO;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Gift;
import com.group9.harmonyapp.po.UserGift;
import com.group9.harmonyapp.repository.GiftRepository;
import com.group9.harmonyapp.repository.UserGiftRepository;
import com.group9.harmonyapp.service.GiftsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GiftsServiceImpl implements GiftsService {

    private final GiftRepository giftRepository;
    private final UserGiftRepository userGiftRepository;

    @Override
    public PageResponseDTO<GiftDTO> getUserGifts(Long userId, String status, int page, int pageSize) {
        try {
            List<UserGift> userRedeemed = userGiftRepository.findByUserId(userId);
            Map<Long, UserGift> redeemedMap = userRedeemed.stream()
                    .collect(Collectors.toMap(UserGift::getGiftId, ug -> ug, (a, b) -> a));

            List<Gift> gifts;
            if (status != null && !status.isEmpty()) {
                if ("redeemed".equalsIgnoreCase(status)) {
                    // only redeemed gifts for user
                    List<UserGift> redeemed = userGiftRepository.findByUserIdOrderByRedeemedAtDesc(userId);
                    gifts = redeemed.stream()
                            .map(ug -> {
                                return giftRepository.findById(ug.getGiftId()).orElse(null);
                            })
                            .filter(Objects::nonNull)
                            .collect(Collectors.toList());
                } else {
                    gifts = giftRepository.findByStatus(status);
                }
            } else {
                gifts = giftRepository.findAll();
            }

            List<GiftDTO> list = gifts.stream().map(g -> {
                GiftDTO dto = new GiftDTO();
                dto.setId(g.getId());
                dto.setName(g.getName());
                dto.setPointsRequired(g.getPointsRequired());
                dto.setStatus(g.getStatus());
                dto.setStock(g.getStock());
                dto.setCreatedAt(g.getCreatedAt());
                if (redeemedMap.containsKey(g.getId())) {
                    dto.setRedeemedAt(redeemedMap.get(g.getId()).getRedeemedAt());
                }
                return dto;
            }).collect(Collectors.toList());

            int total = list.size();
            int from = Math.max(0, (page - 1) * pageSize);
            int to = Math.min(total, from + pageSize);
            List<GiftDTO> pageList = list.subList(from, to);

            return new PageResponseDTO<>(pageList, page, pageSize, total);
        } catch (Exception e) {
            throw new HarmonyException("获取礼品列表失败", 3801);
        }
    }
}
