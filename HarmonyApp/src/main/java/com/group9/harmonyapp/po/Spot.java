package com.group9.harmonyapp.po;
import com.group9.harmonyapp.dto.SpotDetailResponse;
import com.group9.harmonyapp.dto.SpotListItemDTO;
import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Data
@Entity
@Table(name = "spots")
public class Spot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String thumbnail;
    private String summary;
    private Long zoneId;
    private Double latitude;
    private Double longitude;
    private Integer radius;
    private String description;
    private String openTime;
    private String video;
    @ElementCollection
    private List<String> images;
    private String type;
    public SpotListItemDTO toSpotListItemDTO() {
        SpotListItemDTO dto = new SpotListItemDTO();
        dto.setSpotId(id);
        dto.setName(name);
        dto.setThumbnail(thumbnail);
        dto.setSummary(summary);
        dto.setZoneId(zoneId);
        //dto.setDistance(todo);
        return dto;
    }
    public SpotDetailResponse toSpotDetailResponse() {
        SpotDetailResponse response = new SpotDetailResponse();
        response.setId(id);
        response.setName(name);
        response.setThumbnail(thumbnail);
        response.setSummary(summary);
        response.setZoneId(zoneId);
        response.setLatitude(latitude);
        response.setLongitude(longitude);
        response.setDescription(description);
        response.setOpenTime(openTime);
        response.setVideo(video);
        response.setImages(images);
        response.setType(type);
        return response;
    }
}