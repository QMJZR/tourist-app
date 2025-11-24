package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class LLMResult {
    private String answer;
    private List<Long> ids;
}