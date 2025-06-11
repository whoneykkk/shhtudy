package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.dto.NoiseEventRequestDto;
import com.shhtudy.backend.domain.noise.dto.NoiseSessionRequestDto;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.noise.repository.NoiseEventRepository;
import com.shhtudy.backend.domain.noise.repository.NoiseSessionRepository;
import com.shhtudy.backend.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NoiseService {

    private final NoiseEventRepository noiseEventRepository;
    private final NoiseSessionRepository noiseSessionRepository;

    // 소음 이벤트 저장
    public void saveNoiseEvent(User user, NoiseEventRequestDto dto) {
        NoiseEvent event = NoiseEvent.builder()
                .user(user)
                .decibel(dto.getDecibel())
                .measuredAt(dto.getMeasuredAt())
                .build();

        noiseEventRepository.save(event);
    }

    // 세션 종료 및 통계 저장
    @Transactional
    public void closeSession(User user, NoiseSessionRequestDto dto) {
        NoiseSession session = noiseSessionRepository.findTopByUserOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("세션을 찾을 수 없습니다."));

        List<NoiseEvent> events = noiseEventRepository.findByUserAndMeasuredAtBetween(
                user, dto.getCheckinTime(), dto.getCheckoutTime());

        double avgDb = 0;
        double maxDb = 0;
        double quietRatio = 0;

        if (!events.isEmpty()) {
            avgDb = events.stream().mapToDouble(NoiseEvent::getDecibel).average().orElse(0);
            maxDb = events.stream().mapToDouble(NoiseEvent::getDecibel).max().orElse(0);
            long quietCount = events.stream().filter(e -> e.getDecibel() < 45).count();
            quietRatio = (double) quietCount / events.size();
        }

        // 점수 및 티어 계산 (포인트, 등급 업데이트)
        calculateScoreAndTier(user, quietRatio);

        // 세션에 통계 저장
        session.setCheckoutTime(dto.getCheckoutTime());
        session.setAvgDecibel(avgDb);
        session.setMaxDecibel(maxDb);
        session.setQuietRatio(quietRatio);
        noiseSessionRepository.save(session);
    }

    // 점수 및 등급 계산: User의 points와 grade를 업데이트함
    @Transactional
    public void calculateScoreAndTier(User user, double quietRatio) {
        // 세션 점수 계산 = 조용 비율 * 100
        int sessionPoints = (int) (quietRatio * 100.0);
        user.setPoints(user.getPoints() + sessionPoints); // 누적 포인트 반영

        // 누적 세션들의 조용 비율 평균을 기반으로 등급 산정
        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);
        double totalQuietRatio = sessions.stream().mapToDouble(NoiseSession::getQuietRatio).sum();
        double averageQuietRatio = sessions.isEmpty()
                ? quietRatio
                : (totalQuietRatio + quietRatio) / (sessions.size() + 1);

        // 등급 설정
        if (averageQuietRatio >= 0.9) {
            user.setGrade(User.Grade.SILENT);
        } else if (averageQuietRatio >= 0.7) {
            user.setGrade(User.Grade.GOOD);
        } else {
            user.setGrade(User.Grade.WARNING);
        }
    }
}