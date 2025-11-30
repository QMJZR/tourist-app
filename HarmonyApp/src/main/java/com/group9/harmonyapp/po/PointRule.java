package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "point_rules")
public class PointRule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String type;  // checkin, redeem, other
    private String description;
    private Integer points;
    
    @Column(columnDefinition = "VARCHAR(20) DEFAULT 'enabled'")
    private String status = "enabled";  // enabled 或 disabled
}
