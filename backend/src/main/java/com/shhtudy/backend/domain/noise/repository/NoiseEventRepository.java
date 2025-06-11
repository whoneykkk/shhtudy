package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NoiseEventRepository extends JpaRepository<NoiseEvent, Long> {
}