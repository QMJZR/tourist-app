package com.group9.harmonyapp.repository;


import com.group9.harmonyapp.po.Spot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;


public interface SpotRepository extends JpaRepository<Spot, Long>, JpaSpecificationExecutor<Spot> {
    List<Spot> findByIdIn(List<Long> ids);
}