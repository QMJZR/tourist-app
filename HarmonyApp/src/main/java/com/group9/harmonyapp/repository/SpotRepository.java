package com.group9.harmonyapp.repository;


import com.group9.harmonyapp.po.Spot;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Set;


public interface SpotRepository extends JpaRepository<Spot, Long>, JpaSpecificationExecutor<Spot> {
    List<Spot> findByIdIn(List<Long> ids);
    @Query("SELECT DISTINCT s FROM Spot s LEFT JOIN FETCH s.images WHERE s.id IN :ids")
    List<Spot> findAllWithImagesByIds(@Param("ids") Set<Long> ids);
}