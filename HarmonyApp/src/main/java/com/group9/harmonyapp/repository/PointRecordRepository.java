package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.PointRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PointRecordRepository extends JpaRepository<PointRecord, Long> {
    List<PointRecord> findByUserIdOrderByCreatedAtDesc(Long userId);
}
