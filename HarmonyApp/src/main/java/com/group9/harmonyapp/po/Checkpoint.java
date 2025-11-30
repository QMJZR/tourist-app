package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "checkpoints")
public class Checkpoint {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long spotId;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer radius;
    
    @Column(columnDefinition = "VARCHAR(20) DEFAULT 'enabled'")
    private String status = "enabled";  // enabled 或 disabled
}
