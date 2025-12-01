package com.group9.harmonyapp.po;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_gifts")
@Data
public class UserGift {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Long giftId;
    private Integer pointsUsed;
    private LocalDateTime redeemedAt;
    private String status; // pending, redeemed, verified, expired
    private String giftCode; // QR code or redemption code
}
