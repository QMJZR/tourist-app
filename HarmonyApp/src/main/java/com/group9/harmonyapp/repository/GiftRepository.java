package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.Gift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GiftRepository extends JpaRepository<Gift, Long> {
    List<Gift> findByStatus(String status);
}
