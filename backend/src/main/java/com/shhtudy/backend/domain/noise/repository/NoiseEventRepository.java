package com.shhtudy.backend.domain.noise.repository;

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

    // 세션에 대한 모든 소음 이벤트 조회
    List<NoiseEvent> findBySession(NoiseSession session);

    // 세션에 대해 기준 데시벨 초과한 소음 이벤트 조회
    List<NoiseEvent> findBySessionAndDecibelGreaterThan(NoiseSession session, double decibelThreshold);
}
