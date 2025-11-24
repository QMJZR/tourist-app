package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.FeedLikeDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Feed;
import com.group9.harmonyapp.po.FeedLike;
import com.group9.harmonyapp.repository.FeedLikeRepository;
import com.group9.harmonyapp.repository.FeedRepository;
import com.group9.harmonyapp.service.FeedLikeService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class FeedLikeServiceImpl implements FeedLikeService {
        private final FeedRepository feedRepository;
        private final FeedLikeRepository likeRepository;
        @Transactional
        @Override
        public FeedLikeDTO like(Long feedId, Long userId) {
            Feed feed = feedRepository.findById(feedId)
                    .orElseThrow(() -> new HarmonyException("动态不存在",3301));

            if (likeRepository.existsByFeedIdAndUserId(feedId, userId)) {
                throw new HarmonyException("已点赞过该动态",3302);
            }

            FeedLike like = new FeedLike();
            like.setFeedId(feedId);
            like.setUserId(userId);
            like.setCreatedAt(LocalDateTime.now());
            likeRepository.save(like);

            feed.setLikes(feed.getLikes() + 1);
            feedRepository.save(feed);

            return new FeedLikeDTO(feedId,feed.getLikes(),true);
        }
        @Transactional
        @Override
        public FeedLikeDTO unlike(Long feedId, Long userId) {

            Feed feed = feedRepository.findById(feedId)
                    .orElseThrow(() -> new HarmonyException("动态不存在",3301));

            if (!likeRepository.existsByFeedIdAndUserId(feedId, userId)) {
                throw new HarmonyException("该动态未点赞，无需取消",3303);
            }

            likeRepository.deleteByFeedIdAndUserId(feedId, userId);

            feed.setLikes(feed.getLikes() - 1);
            feedRepository.save(feed);

            return new FeedLikeDTO(feedId,feed.getLikes(),false);
        }
}
