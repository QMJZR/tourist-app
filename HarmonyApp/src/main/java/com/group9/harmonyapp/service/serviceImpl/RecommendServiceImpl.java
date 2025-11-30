package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.RecommendationDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Spot;
import com.group9.harmonyapp.repository.CheckinRecordRepository;
import com.group9.harmonyapp.repository.SpotRepository;
import com.group9.harmonyapp.service.RecommendService;
import com.group9.harmonyapp.util.GeoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendServiceImpl implements RecommendService {

    private final SpotRepository spotRepository;
    private final CheckinRecordRepository checkinRecordRepository;

    @Override
    public PageResponseDTO<RecommendationDTO> nearby(Double latitude, Double longitude, String sort, String type, int page, int pageSize) {
        if (latitude == null || longitude == null) {
            throw new HarmonyException("缺少用户坐标信息", 3601);
        }

        try {
            List<Spot> spots = spotRepository.findAll();

            List<RecommendationDTO> list = spots.stream()
                    .filter(s -> {
                        if (type == null || "all".equals(type)) return true;
                        if ("spot".equals(type)) return "spot".equals(s.getType()) || s.getType() == null;
                        if ("merchant".equals(type)) return "merchant".equals(s.getType());
                        return true;
                    })
                    .map(s -> s.toRecommendationDTO(GeoUtil.distance(latitude, longitude, s.getLatitude(), s.getLongitude())))
                    .collect(Collectors.toList());

            if ("distance".equals(sort)) {
                list.sort(Comparator.comparing(RecommendationDTO::getDistance));
            } else if ("popularity".equals(sort)) {
                // popularity by checkin count
                list.sort(Comparator.comparing(r -> -checkinRecordRepository.countBySpotId(r.getId())));
            } else {
                // default by popularity
                list.sort(Comparator.comparing(r -> -checkinRecordRepository.countBySpotId(r.getId())));
            }

            int total = list.size();
            int from = Math.max(0, (page - 1) * pageSize);
            int to = Math.min(total, from + pageSize);
            List<RecommendationDTO> pageList = list.subList(from, to);

            return new PageResponseDTO<>(pageList, page, pageSize, total);
        } catch (HarmonyException he) {
            throw he;
        } catch (Exception e) {
            throw new HarmonyException("服务器异常，请稍后再试", 9999);
        }
    }
}
