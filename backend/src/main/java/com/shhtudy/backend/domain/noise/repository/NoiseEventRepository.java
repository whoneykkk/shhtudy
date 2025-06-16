package com.shhtudy.backend.domain.noise.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NoiseEventRepository extends JpaRepository<NoiseEvent, Long> {

    // 사용자와 측정 시간 범위로 소음 이벤트 조회
    List<NoiseEvent> findByUserAndMeasuredAtBetween(User user, LocalDateTime start, LocalDateTime end);

    List<NoiseEvent> findBySession(NoiseSession session);

    // 세션에 대해 기준 데시벨 초과한 소음 이벤트 조회 + 시간 필터링
    Page<NoiseEvent> findBySessionAndDecibelGreaterThan(
            NoiseSession session,
            double decibelThreshold,
            Pageable pageable);

    Page<NoiseEvent> findBySessionAndDecibelGreaterThanAndMeasuredAtBetween(
            NoiseSession session,
            double decibelThreshold,
            LocalDateTime from,
            LocalDateTime to,
            Pageable pageable);
}