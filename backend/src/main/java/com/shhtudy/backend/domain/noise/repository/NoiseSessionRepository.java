package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NoiseSessionRepository extends JpaRepository<NoiseSession, Long> {
    List<NoiseSession> findByUserId(String userId);
}
