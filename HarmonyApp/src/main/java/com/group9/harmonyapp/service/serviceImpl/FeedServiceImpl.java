package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.FeedResponseDTO;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Feed;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.FeedLikeRepository;
import com.group9.harmonyapp.repository.FeedRepository;

import com.group9.harmonyapp.service.AuthService;
import com.group9.harmonyapp.service.FeedService;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;


import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FeedServiceImpl implements FeedService {

    private final FeedRepository feedRepository;
    private final FeedLikeRepository feedLikeRepository;
    private final AuthService authService;

    /**
     * 缓存动态列表
     * key 要包含分页、keyword、sort、userId
     */
    @Cacheable(
            cacheNames = "feed:list",
            key = "'feed_' + #userId + '_' + #keyword + '_' + #sort + '_' + #page + '_' + #pageSize"
    )
    @Override
    public PageResponseDTO<FeedResponseDTO> list(Long loginUserId,
                                                 Long userId,
                                                 String keyword,
                                                 String sort,
                                                 int page,
                                                 int pageSize) {
        try {
            Pageable pageable;

            if ("popular".equals(sort)) {
                pageable = PageRequest.of(page - 1, pageSize, Sort.by(Sort.Direction.DESC, "likes"));
            } else {
                pageable = PageRequest.of(page - 1, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
            }
            // 过滤条件
            Page<Feed> result = feedRepository.findAll((root, query, cb) -> {
                List<Predicate> predicates = new ArrayList<>();
                if (userId != null) {
                    predicates.add(cb.equal(root.get("userId"), userId));
                }
                if (keyword != null && !keyword.trim().isEmpty()) {
                    predicates.add(cb.like(root.get("content"), "%" + keyword + "%"));
                }
                return cb.and(predicates.toArray(new Predicate[0]));
            }, pageable);

            List<FeedResponseDTO> list = result.getContent()
                    .stream()
                    .map(feed -> convertFeed(feed, loginUserId))
                    .toList();

            return new PageResponseDTO<>(list, page, pageSize, result.getTotalElements());

        } catch (Exception e) {
            throw new HarmonyException("获取动态列表失败", 3201);
        }
    }

    /**
     * 动态实体转换为 DTO
     */
    private FeedResponseDTO convertFeed(Feed feed, Long loginUserId) {
        FeedResponseDTO dto = new FeedResponseDTO();

        dto.setFeedId(feed.getId());
        dto.setUserId(feed.getUserId());

        // user info 走缓存 ---- 好吧走不了
        User user = authService.getUserById(feed.getUserId());
        dto.setUsername(user.getUsername());
        dto.setAvatar(user.getAvatar());

        dto.setSpotId(feed.getSpotId());
        dto.setSpotName(feed.getSpotName());
        dto.setContent(feed.getContent());
        dto.setImages(feed.getImages());
        dto.setLikes(feed.getLikes());
        dto.setCreatedAt(feed.getCreatedAt());

        // 这个不能缓存，因为每个用户不同
        dto.setLiked(feedLikeRepository.existsByFeedIdAndUserId(feed.getId(), loginUserId));

        return dto;
    }

//    /**
//     * 用户信息缓存
//     * 每个用户的信息基本不变，非常适合缓存
//     */
//    @Cacheable(cacheNames = "user:info", key = "#userId")
//    public User getUserInfoCached(Long userId) {
//        return authService.getUserById(userId);
//    }
}
