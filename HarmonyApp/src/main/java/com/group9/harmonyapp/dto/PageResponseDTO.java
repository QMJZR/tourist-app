package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;
@Data
public class PageResponseDTO {
    private List<SpotListItemDTO> list;
    private int page;
    private int pageSize;
    private long total;

}
