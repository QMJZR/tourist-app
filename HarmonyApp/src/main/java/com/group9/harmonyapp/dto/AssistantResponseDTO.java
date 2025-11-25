package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class AssistantResponseDTO {
    private String answer;
    private List<RecommendationDTO> recommendations;
}