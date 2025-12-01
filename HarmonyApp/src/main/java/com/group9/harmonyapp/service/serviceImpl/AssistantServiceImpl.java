package com.group9.harmonyapp.service.serviceImpl;

import com.alibaba.fastjson2.JSON;
import com.group9.harmonyapp.dto.AssistantRequestDTO;
import com.group9.harmonyapp.dto.AssistantResponseDTO;
import com.group9.harmonyapp.dto.LLMResult;
import com.group9.harmonyapp.dto.RecommendationDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Spot;
import com.group9.harmonyapp.repository.SpotRepository;
import com.group9.harmonyapp.service.AssistantService;
import com.group9.harmonyapp.service.SpotService;
import com.group9.harmonyapp.util.GeoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AssistantServiceImpl implements AssistantService {

        private final DeepSeekService deepSeekService;
        private final SpotService spotService;
        private final SpotRepository spotRepository;
        public AssistantResponseDTO handleAsk(AssistantRequestDTO req) {
            try{
            // 参数校验
            if (req.getQuestion() == null || req.getQuestion().isBlank()) {
                throw new RuntimeException("问题不能为空");
            }

            Double lat = req.getContext() != null ? req.getContext().getLatitude() : null;
            Double lng = req.getContext() != null ? req.getContext().getLongitude() : null;

            // ---------------------------------------------------
            // ① 查数据库推荐结果（这里以“附近餐厅”为例，请按你的业务修改）
            // ---------------------------------------------------
            List<Spot> list = new ArrayList<>();

            if (lat != null && lng != null) {
                list = spotService.findNearby(lat, lng, 1000); // 查 1km 内
            }

            // 转为你的 RecommendationDTO
            List<RecommendationDTO> recList = new ArrayList<>();
            for (Spot r : list) {
                RecommendationDTO rec = new RecommendationDTO();
                rec.setType("restaurant");
                rec.setId(r.getId());
                rec.setName(r.getName());
                rec.setLatitude(r.getLatitude());
                rec.setLongitude(r.getLongitude());
                rec.setDistance(GeoUtil.distance(lat,lng,r.getLatitude(),r.getLongitude()));
                recList.add(rec);
            }

            // ---------------------------------------------------
            // ② 把推荐列表 JSON 传给 LLM，让 LLM 用这些数据回答
            // ---------------------------------------------------
            String backendContextJson = JSON.toJSONString(recList);

            LLMResult result = deepSeekService.ask(req.getQuestion(), backendContextJson);

// 从 ids 中查推荐的数据
            List<RecommendationDTO> recs = spotRepository.findByIdIn(result.getIds()).stream().
                    map((e)->{if(lat!=null && lng!=null){
                        return e.toRecommendationDTO(GeoUtil.distance(lat,lng,e.getLatitude(),e.getLongitude()));
                    }else return null;})
                .collect(Collectors.toList());

// 返回
            AssistantResponseDTO response = new AssistantResponseDTO();
            response.setAnswer(result.getAnswer());
            response.setRecommendations(recs);

            return response;}

            catch (Exception e){
                throw new HarmonyException("智能助手暂时无法响应，请稍后再试",3402);
            }
        
    }
}
