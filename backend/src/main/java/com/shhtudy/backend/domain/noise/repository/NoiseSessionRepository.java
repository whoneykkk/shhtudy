package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NoiseSessionRepository extends JpaRepository<NoiseSession, Long> {

    // 사용자별 전체 세션 조회
    List<NoiseSession> findByUser(User user);

    // 아직 종료되지 않은 가장 최근 세션 조회
    Optional<NoiseSession> findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(User user);

    // 종료된 가장 최근 세션 조회
    Optional<NoiseSession> findTopByUserAndCheckoutTimeIsNotNullOrderByCheckoutTimeDesc(User user);
}
