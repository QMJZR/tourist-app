package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "gifts")
@Data
public class Gift {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String description;
    
    @ElementCollection
    private java.util.List<String> images;
    
    private Integer pointsRequired;
    private String status; // available, soldOut, disabled
    private Integer stock;
    private String supplier;
    private String validity;
    private Long merchantId;
    private LocalDateTime createdAt;
}
