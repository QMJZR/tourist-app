package com.group9.harmonyapp.po;
import jakarta.persistence.*;
import lombok.Data;
@Data
@Entity
@Table(name = "zones")
public class Zone {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long zoneId;

    private String name;

    private String description;

    @ElementCollection
    private java.util.List<String> banner;
}