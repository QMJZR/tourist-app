package com.group9.harmonyapp.repository;


import com.group9.harmonyapp.po.Spot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;


public interface SpotRepository extends JpaRepository<Spot, Long>, JpaSpecificationExecutor<Spot> {}