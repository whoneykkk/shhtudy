package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.dto.NoiseEventRequestDto;
import com.shhtudy.backend.domain.noise.dto.NoiseSessionRequestDto;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.noise.repository.NoiseEventRepository;
import com.shhtudy.backend.domain.noise.repository.NoiseSessionRepository;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoiseService {

    private final NoiseEventRepository noiseEventRepository;
    private final NoiseSessionRepository noiseSessionRepository;
    private final UserRepository userRepository;

    public void saveNoiseEvent(NoiseEventRequestDto dto) {
        User user = userRepository.findByFirebaseUid(dto.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        NoiseEvent event = NoiseEvent.builder()
                .user(user)
                .decibel(dto.getDecibel())
                .measuredAt(dto.getMeasuredAt())
                .build();

        noiseEventRepository.save(event);
    }

    @Transactional
    public void closeSession(NoiseSessionRequestDto dto) {
        User user = userRepository.findByFirebaseUid(dto.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        NoiseSession session = noiseSessionRepository.findTopByUserOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("세션을 찾을 수 없습니다."));

        List<NoiseEvent> events = noiseEventRepository.findByUserAndMeasuredAtBetween(
                user, dto.getCheckinTime(), dto.getCheckoutTime());

        double avgDb = 0;
        double maxDb = 0;
        double quietRate = 0;

        if (!events.isEmpty()) {
            avgDb = events.stream().mapToDouble(NoiseEvent::getDecibel).average().orElse(0);
            maxDb = events.stream().mapToDouble(NoiseEvent::getDecibel).max().orElse(0);
            long quietCount = events.stream().filter(e -> e.getDecibel() < 45).count();
            quietRate = (double) quietCount / events.size();
        }

        session.setCheckoutTime(dto.getCheckoutTime());
        session.setAvgDecibel(avgDb);
        session.setMaxDecibel(maxDb);
        session.setQuietRatio(quietRate);
        session.setScore(0);
        session.setSuddenNoiseCount(0);

        noiseSessionRepository.save(session);
    }

    // 조용 비율을 받아서 점수 및 티어 계산
    public NoiseScoreDto calculateScoreAndTier(String userId, double quietRatio) {
        double sessionScore = quietRatio * 100.0;

        List<NoiseSession> sessions = sessionRepository.findByUserId(userId);
        double totalScore = sessions.stream().mapToDouble(NoiseSession::getScore).sum();
        double averageScore = sessions.isEmpty()
                ? sessionScore
                : (totalScore + sessionScore) / (sessions.size() + 1);

        String tier = determineTier(averageScore);

        // 점수를 세션에 저장하고 저장
        NoiseSession newSession = NoiseSession.builder()
                .userId(userId)
                .checkinTime(java.time.LocalDateTime.now())  // 실제 값으로 대체해야 함
                .checkoutTime(java.time.LocalDateTime.now()) // 실제 값으로 대체해야 함
                .score(sessionScore)
                .build();

        sessionRepository.save(newSession);

        return new NoiseScoreDto(sessionScore, averageScore, tier);
    }

    private String determineTier(double score) {
        if (score >= 90.0) return "silent";
        else if (score >= 70.0) return "good";
        else return "warning";
    }
}
