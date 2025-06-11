package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NoiseSessionRepository extends JpaRepository<NoiseSession, Long> {

    Optional<NoiseSession> findTopByUserOrderByCheckinTimeDesc(User user);

    List<NoiseSession> findByUser(User user);
}