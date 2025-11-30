package com.group9.harmonyapp.repository;

import com.group9.harmonyapp.po.Feed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FeedRepository extends JpaRepository<Feed, Long>, JpaSpecificationExecutor<Feed> {

	@Query("select coalesce(sum(f.likes),0) from Feed f where f.userId = :userId")
	Integer sumLikesByUserId(@Param("userId") Long userId);

}