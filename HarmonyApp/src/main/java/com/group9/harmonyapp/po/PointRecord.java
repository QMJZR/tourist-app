package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
public class PointRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private String type; // earn 或 spend
    private String source;
    private Integer points;
    private LocalDateTime createdAt;
}
