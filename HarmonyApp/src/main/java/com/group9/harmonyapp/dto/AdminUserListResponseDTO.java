package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class AdminUserListResponseDTO {
    private Long total;
    private List<AdminUserResultDTO> users;
}
