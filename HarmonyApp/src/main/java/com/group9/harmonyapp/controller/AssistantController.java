package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.AssistantRequestDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.service.AssistantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/assistant")
@RequiredArgsConstructor
public class AssistantController {

    private final AssistantService assistantService;

    @PostMapping("/ask")
    public Response<?> ask(@RequestBody AssistantRequestDTO req) {
        try {
            return Response.buildSuccess(assistantService.handleAsk(req));
        } catch (Exception e) {
            throw new HarmonyException("智能助手暂时无法响应，请稍后再试",3402);
        }
    }
}