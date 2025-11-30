package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RankingDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.CheckinRecordRepository;
import com.group9.harmonyapp.repository.FeedRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.service.RankingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RankingsServiceImpl implements RankingsService {

    private final UserRepository userRepository;
    private final CheckinRecordRepository checkinRecordRepository;
    private final FeedRepository feedRepository;

    @Override
    public PageResponseDTO<RankingDTO> list(String period, int page, int pageSize, String sort) {
        try {
            List<User> users = userRepository.findAll();

            List<RankingDTO> all = users.stream().map(u -> {
                RankingDTO dto = new RankingDTO();
                dto.setUserId(u.getId());
                dto.setUsername(u.getUsername());
                dto.setAvatar(u.getAvatar());
                long totalCheckins = checkinRecordRepository.countByUserId(u.getId());
                Integer totalLikes = feedRepository.sumLikesByUserId(u.getId());
                if (totalLikes == null) totalLikes = 0;

                dto.setTotalCheckins(totalCheckins);
                dto.setTotalLikes(totalLikes);

                // 简单加权计算综合分数：打卡 *100 + 点赞 *10
                int score = (int) (totalCheckins * 100 + totalLikes * 10);
                dto.setScore(score);

                return dto;
            }).collect(Collectors.toList());

            // 排序
            if ("checkins".equals(sort)) {
                all.sort(Comparator.comparing(RankingDTO::getTotalCheckins).reversed());
            } else {
                // 默认按综合分数
                all.sort(Comparator.comparing(RankingDTO::getScore).reversed());
            }

            int total = all.size();
            int from = Math.max(0, (page - 1) * pageSize);
            int to = Math.min(total, from + pageSize);
            List<RankingDTO> pageList = all.subList(from, to);

            // 设置排行序号（在分页中保持全局排名）
            for (int i = 0; i < pageList.size(); i++) {
                pageList.get(i).setRank(from + i + 1);
            }

            return new PageResponseDTO<>(pageList, page, pageSize, total);

        } catch (Exception e) {
            throw new HarmonyException("获取排行榜失败", 3501);
        }
    }
}
