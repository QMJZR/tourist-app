package com.group9.harmonyapp.dto;

import lombok.Data;

import java.util.List;
@Data
public class PageResponseDTO<T> {
    private List<T> list;
    private int page;
    private int pageSize;
    private long total;

    public PageResponseDTO(List<T> list, int page, int pageSize, long totalElements) {
        this.list = list;
        this.page = page;
        this.pageSize = pageSize;
        this.total = totalElements;
    }

    public PageResponseDTO() {

    }
}
