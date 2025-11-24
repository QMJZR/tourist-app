package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.CheckinRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface CheckinRecordRepository extends JpaRepository<CheckinRecord, Long> {
    Optional<CheckinRecord> findByUserIdAndSpotIdAndDate(Long userId, Long spotId, LocalDate date);
}