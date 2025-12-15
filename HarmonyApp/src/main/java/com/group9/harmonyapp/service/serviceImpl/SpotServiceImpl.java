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
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class SpotServiceImpl implements SpotService {


    private final SpotRepository spotRepository;
    @Cacheable(
            value = "spot:list",
            key = "T(String).format('%s_%s_%s_%s_%s', #zoneId, #type, #keyword, #page, #pageSize)"
    )
    public PageResponseDTO<SpotListItemDTO> list(Long zoneId, String type, String keyword, int page, int pageSize) {
        try {
            // 不使用分页直接查询所有符合条件的数据（便于排序和分页）
            List<Spot> allSpots = spotRepository.findAll((root, query, cb) -> {
                List<Predicate> predicates = new ArrayList<>();
                if (zoneId != null) predicates.add(cb.equal(root.get("zoneId"), zoneId));
                if (type != null) predicates.add(cb.equal(root.get("type"), type));
                if (keyword != null) predicates.add(cb.like(root.get("name"), "%" + keyword + "%"));
                return cb.and(predicates.toArray(new Predicate[0]));
            });

            // 转 DTO
            List<SpotListItemDTO> dtoList = allSpots.stream()
                    .map(Spot::toSpotListItemDTO)
                    .collect(Collectors.toList());

            // 分页
            int total = dtoList.size();
            int from = Math.max(0, (page - 1) * pageSize);
            int to = Math.min(total, from + pageSize);
            //List<SpotListItemDTO> pageList = dtoList.subList(from, to);
            List<SpotListItemDTO> pageList = new ArrayList<>(dtoList.subList(from, to));

            PageResponseDTO<SpotListItemDTO> data = new PageResponseDTO<>();
            data.setList(pageList);
            data.setPage(page);
            data.setPageSize(pageSize);
            data.setTotal(total);

            return data;

        } catch (Exception e) {
            throw new HarmonyException("获取景点列表失败", 2101);
        }
    }

    /**
     * 景点详情缓存
     */
    @Cacheable(value = "spot:detail", key = "#id")
    public SpotDetailResponse detail(Long id) {
        try {
            Spot spot = spotRepository.findById(id).orElse(null);
            if (spot == null) throw new HarmonyException("景点不存在", 2201);
            return spot.toSpotDetailResponse();
        } catch (Exception e) {
            throw new HarmonyException("获取景点详情失败", 2202);
        }
    }

    /**
     * 查找附近景点缓存
     */
    @Cacheable(
            value = "spot:nearby",
            key = "T(String).format('%s_%s_%s', #lat, #lng, #radius)"
    )
    @Override
    public List<Spot> findNearby(Double lat, Double lng, Integer radius) {
        return spotRepository.findAll().stream()
                .filter(e -> GeoUtil.distance(e.getLatitude(), e.getLongitude(), lat, lng) <= radius)
                .collect(Collectors.toList());
    }
}