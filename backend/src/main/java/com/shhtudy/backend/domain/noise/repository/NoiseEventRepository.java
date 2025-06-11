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

    List<NoiseEvent> findByUserAndMeasuredAtBetween(User user, LocalDateTime start, LocalDateTime end);

    List<NoiseEvent> findBySession(NoiseSession session);

}