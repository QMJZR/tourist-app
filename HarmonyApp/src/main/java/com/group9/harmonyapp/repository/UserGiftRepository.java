package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.UserGift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserGiftRepository extends JpaRepository<UserGift, Long> {
    List<UserGift> findByUserIdOrderByRedeemedAtDesc(Long userId);
    List<UserGift> findByUserId(Long userId);
    List<UserGift> findByGiftIdOrderByRedeemedAtDesc(Long giftId);
}
