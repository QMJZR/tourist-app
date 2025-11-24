package com.group9.harmonyapp.service.serviceImpl;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.group9.harmonyapp.dto.LLMResult;
import com.group9.harmonyapp.exception.HarmonyException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DeepSeekService {
    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";

    @Value("${deepseek.api-key}")
    private String apiKey;

    private final WebClient webClient = WebClient.builder()
            .baseUrl(API_URL)
            .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
            .build();

    public LLMResult ask(String question, String backendContextJson) {
        if(question == null) throw  new HarmonyException("问题不能为空",3401);

        Map<String, Object> request = new HashMap<>();
        request.put("model", "deepseek-chat");

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of(
                "role", "system",
                "content", "你是一名旅游智能助手，必须根据后端提供的数据回答用户问题," +
                        "你必须严格返回标准JSON，格式如下：" +
                        "{\"answer\":\"你的文字回复\", \"recommendation\":[地点ID列表]}。" +
                        "recommend是你推荐的地点，可为空列表,后端数据如下：" + backendContextJson
        ));
        messages.add(Map.of(
                "role", "user",
                "content", question
        ));
        request.put("messages", messages);

        Map<String, Object> result = webClient.post()
                .header("Authorization", "Bearer " + apiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        List<Map<String, Object>> choices = (List<Map<String, Object>>) result.get("choices");
        Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
        String content = (String) message.get("content");

        return parseLLM(content);  // ← 返回解析好的对象
    }
    public LLMResult parseLLM(String content) {

        JSONObject obj = JSON.parseObject(content);

        LLMResult r = new LLMResult();
        r.setAnswer(obj.getString("answer"));
        r.setIds(obj.getJSONArray("recommendation").toJavaList(Long.class));

        return r;
    }
}
