package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class AssistantRequestDTO {
    private String question;

    private Context context;

    @Data
    public static class Context {
        private Double latitude;
        private Double longitude;
        private List<String> history;
    }
}