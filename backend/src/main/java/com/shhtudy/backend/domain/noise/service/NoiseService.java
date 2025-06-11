package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.entity.Noise;
import com.shhtudy.backend.domain.noise.enums.NoiseStatus;
import com.shhtudy.backend.domain.noise.repository.NoiseRepository;
import com.shhtudy.backend.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class NoiseService {
    private final NoiseRepository noiseRepository;

    @Transactional
    public Noise recordNoise(Double decibelLevel, User user) {
        Noise noise = new Noise(decibelLevel, user);
        return noiseRepository.save(noise);
    }

    public List<Noise> getNoiseByUser(User user) {
        return noiseRepository.findByUser(user);
    }

    public List<Noise> getNoiseByStatus(NoiseStatus status) {
        return noiseRepository.findByStatus(status);
    }

    public List<Noise> getNoiseHistory(User user, LocalDateTime startTime, LocalDateTime endTime) {
        return noiseRepository.findByUserAndTimeRange(user, startTime, endTime);
    }

    public Double getAverageNoiseLevel(User user, LocalDateTime startTime, LocalDateTime endTime) {
        return noiseRepository.getAverageDecibelLevel(user, startTime, endTime);
    }
}