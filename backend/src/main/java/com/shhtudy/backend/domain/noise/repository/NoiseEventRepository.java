package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NoiseEventRepository extends JpaRepository<NoiseEvent, Long> {

    List<NoiseEvent> findByUserAndMeasuredAtBetween(User user, LocalDateTime start, LocalDateTime end);
    List<NoiseEvent> findTop2ByUserOrderByCreatedAtDesc(User user);

    @Query("SELECT COUNT(e) FROM NoiseEvent e WHERE e.user = :user AND e.decibel > :threshold AND e.measuredAt BETWEEN :start AND :end")
    int countTodayOverEvents(@Param("user") User user,
                             @Param("threshold") double threshold,
                             @Param("start") LocalDateTime start,
                             @Param("end") LocalDateTime end);

    List<NoiseEvent> findTop2ByUserAndMeasuredAtBetweenOrderByMeasuredAtDesc(User user, LocalDateTime startOfToday, LocalDateTime endOfToday);
    Page<NoiseEvent> findByUser(User user, Pageable pageable);
}