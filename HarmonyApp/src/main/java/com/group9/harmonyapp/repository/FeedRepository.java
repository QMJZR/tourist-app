package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.Feed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface FeedRepository extends JpaRepository<Feed, Long>, JpaSpecificationExecutor<Feed> {
}