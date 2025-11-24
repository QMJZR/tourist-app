package com.group9.harmonyapp.service.serviceImpl;
import com.group9.harmonyapp.dto.PageResponseDTO;
import com.group9.harmonyapp.dto.SpotDetailResponse;
import com.group9.harmonyapp.dto.SpotListItemDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.repository.SpotRepository;
import com.group9.harmonyapp.po.Spot;
import com.group9.harmonyapp.service.SpotService;
import com.group9.harmonyapp.util.GeoUtil;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class SpotServiceImpl implements SpotService {


    private final SpotRepository spotRepository;

    public PageResponseDTO<SpotListItemDTO> list(Long zoneId, String type, String keyword, int page, int pageSize) {
        try {
            Pageable pageable = PageRequest.of(page - 1, pageSize);


            Page<Spot> result = spotRepository.findAll((root, query, cb) -> {
                List<Predicate> predicates = new java.util.ArrayList<>();
                if (zoneId != null) predicates.add(cb.equal(root.get("zoneId"), zoneId));
                if (type != null) predicates.add(cb.equal(root.get("type"), type));
                if (keyword != null) predicates.add(cb.like(root.get("name"), "%" + keyword + "%"));
                return cb.and(predicates.toArray(new jakarta.persistence.criteria.Predicate[0]));
            }, pageable);

            PageResponseDTO<SpotListItemDTO> data = new PageResponseDTO<>();
            data.setList(result.getContent().stream().map(Spot::toSpotListItemDTO).collect(Collectors.toList()));
            data.setPage(page);
            data.setPageSize(pageSize);
            data.setTotal(result.getTotalElements());

            return data;
        } catch (Exception e) {
            throw new HarmonyException( "获取景点列表失败",2101);
        }
    }


    public SpotDetailResponse detail(Long id) {
        try {
            Spot spot = spotRepository.findById(id).orElse(null);
            if (spot == null) throw new HarmonyException("景点不存在",2201);
            return spot.toSpotDetailResponse();
        } catch (Exception e) {
            throw  new HarmonyException( "获取景点详情失败",2202);
        }
    }

    @Override
    public List<Spot> findNearby(Double lat, Double lng, Integer radius) {
        return spotRepository.findAll().stream().filter((e)-> GeoUtil.distance(e.getLatitude(),e.getLongitude(),lat,lng)<=radius).collect(Collectors.toList());
    }
}