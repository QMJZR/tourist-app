package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.Checkpoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface CheckpointRepository extends JpaRepository<Checkpoint, Long>, JpaSpecificationExecutor<Checkpoint> {
}
