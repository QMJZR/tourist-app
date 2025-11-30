package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.PointRecordDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.PointRecord;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.PointRecordRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.service.PointsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PointsServiceImpl implements PointsService {

    private final PointRecordRepository pointRecordRepository;
    private final UserRepository userRepository;

    @Override
    public PageResponseDTO<PointRecordDTO> getUserPoints(Long userId, int page, int pageSize) {
        try {
            List<PointRecord> records = pointRecordRepository.findByUserIdOrderByCreatedAtDesc(userId);

            List<PointRecordDTO> list = records.stream().map(r -> {
                PointRecordDTO dto = new PointRecordDTO();
                dto.setRecordId(r.getId());
                dto.setType(r.getType());
                dto.setSource(r.getSource());
                dto.setPoints(r.getPoints());
                dto.setCreatedAt(r.getCreatedAt());
                return dto;
            }).collect(Collectors.toList());

            int total = list.size();
            int from = Math.max(0, (page - 1) * pageSize);
            int to = Math.min(total, from + pageSize);
            List<PointRecordDTO> pageList = list.subList(from, to);

            // 获取当前用户总积分
            User user = userRepository.findById(userId).orElse(null);
            long totalPoints = 0;
            if (user != null && user.getPoints() != null) totalPoints = user.getPoints();

            PageResponseDTO<PointRecordDTO> resp = new PageResponseDTO<>(pageList, page, pageSize, total);
            // 将 totalPoints 放在返回对象的某个扩展字段 —— 这里我们不能修改 PageResponseDTO 签名，
            // 所以前端可通过 Auth/profile 获取 totalPoints。仍按文档要求返回 list/total.
            return resp;

        } catch (Exception e) {
            throw new HarmonyException("获取积分记录失败", 3702);
        }
    }
}
