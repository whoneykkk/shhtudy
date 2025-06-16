package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface NoiseSessionRepository extends JpaRepository<NoiseSession, Long> {

    // 최근 전체 세션 조회 (종료된 것 포함)
    List<NoiseSession> findByUser(User user);

    // 아직 닫히지 않은 가장 최근 세션만 조회
    Optional<NoiseSession> findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(User user);

    List<NoiseSession> findByUserAndCheckinTimeBetween(User user, LocalDateTime startOfToday, LocalDateTime endOfToday);
}