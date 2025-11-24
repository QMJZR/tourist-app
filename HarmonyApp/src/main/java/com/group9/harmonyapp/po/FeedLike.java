package com.group9.harmonyapp.po;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "feed_likes", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"feedId", "userId"})
})
@Data
public class FeedLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long feedId;

    private Long userId;

    private LocalDateTime createdAt;
}