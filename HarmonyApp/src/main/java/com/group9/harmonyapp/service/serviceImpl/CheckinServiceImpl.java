package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.po.CheckinRecord;
import com.group9.harmonyapp.po.Spot;
import com.group9.harmonyapp.repository.CheckinRecordRepository;
import com.group9.harmonyapp.repository.SpotRepository;
import com.group9.harmonyapp.service.CheckinService;
import com.group9.harmonyapp.util.GeoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
@Service
@RequiredArgsConstructor
public class CheckinServiceImpl implements CheckinService {

    private final SpotRepository spotRepository;
    private final CheckinRecordRepository checkinRecordRepository;

    @Override
    public Response<List<SpotCheckinInfoDTO>> listSpots(Double lat, Double lng, String sort) {

        try {
            List<Spot> spots = spotRepository.findAll();

            List<SpotCheckinInfoDTO> list = spots.stream().map(s -> {
                SpotCheckinInfoDTO dto = new SpotCheckinInfoDTO();
                dto.setSpotId(s.getId());
                dto.setName(s.getName());
                dto.setLatitude(s.getLatitude());
                dto.setLongitude(s.getLongitude());
                dto.setRadius(s.getRadius());
                dto.setThumbnail(s.getThumbnail());

                if (lat != null && lng != null) {
                    dto.setDistance(GeoUtil.distance(lat, lng, s.getLatitude(), s.getLongitude()));
                }

                return dto;
            }).collect(Collectors.toList());

            if ("distance".equals(sort) && lat != null && lng != null) {
                list.sort(Comparator.comparing(SpotCheckinInfoDTO::getDistance));
            }

            return Response.buildSuccess(list);

        } catch (Exception e) {
            return Response.buildFailure("获取打卡点失败", 3001);
        }
    }

    @Override
    public Response<CheckinResultDTO> submitCheckin(Long userId, CheckinSubmitRequest req) {

        Spot spot = spotRepository.findById(req.getSpotId()).orElse(null);
        if (spot == null) {
            return Response.buildFailure("打卡点不存在", 3104);
        }
        LocalDate today = LocalDate.now();
        Optional<CheckinRecord> exists =
                checkinRecordRepository.findByUserIdAndSpotIdAndDate(userId, req.getSpotId(), today);
        if (exists.isPresent()) {
            return Response.buildFailure("今日已打卡，请明天再来", 3102);
        }

        int distance = GeoUtil.distance(req.getLatitude(), req.getLongitude(),
                spot.getLatitude(), spot.getLongitude());
        if (distance > spot.getRadius()) {
            return Response.buildFailure("未在打卡范围内，请靠近后重试", 3101);
        }

        if (req.getImage() != null && !req.getImage().startsWith("data:image")) {
            return Response.buildFailure("图片格式不正确", 3103);
        }

//        String imageUrl = "uploaded_path.jpg";

        CheckinRecord record = new CheckinRecord();
        record.setUserId(userId);
        record.setSpotId(req.getSpotId());
        record.setDate(today);
        record.setCreateTime(LocalDateTime.now());
        record.setImageUrl(req.getImage());
        checkinRecordRepository.save(record);

        CheckinResultDTO dto = new CheckinResultDTO();
        dto.setCheckinId(record.getId());
        dto.setSpotId(req.getSpotId());
        dto.setPoints(100);
        dto.setCheckinTime(record.getCreateTime());
        dto.setMessage("恭喜完成打卡！获得 100 积分");

        return Response.buildSuccess(dto);
    }
}
