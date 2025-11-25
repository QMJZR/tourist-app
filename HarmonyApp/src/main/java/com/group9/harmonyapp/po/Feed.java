package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "feeds")
@Data
public class Feed {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;

    private Long spotId;

    private String spotName;

    @Column(length = 1000)
    private String content;

    @ElementCollection
    @CollectionTable(name = "feed_images", joinColumns = @JoinColumn(name = "feed_id"))
    @Column(name = "image_url")
    private List<String> images;

    private Integer likes;

    private LocalDateTime createdAt;
}