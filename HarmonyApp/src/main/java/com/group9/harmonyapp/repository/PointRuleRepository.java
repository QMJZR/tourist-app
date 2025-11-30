package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.PointRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PointRuleRepository extends JpaRepository<PointRule, Long> {
}
