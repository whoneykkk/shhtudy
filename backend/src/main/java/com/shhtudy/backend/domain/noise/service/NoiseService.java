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

import java.util.List;

@Service
@RequiredArgsConstructor
public class NoiseService {

    private final NoiseEventRepository noiseEventRepository;
    private final NoiseSessionRepository noiseSessionRepository;
    private final UserRepository userRepository;

    private static final double QUIET_THRESHOLD_DB = 45.0;
    private static final double SILENT_GRADE_THRESHOLD = 0.9;
    private static final double GOOD_GRADE_THRESHOLD = 0.7;
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
        NoiseSession session = noiseSessionRepository.findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("진행 중인 세션이 없습니다."));

        List<NoiseEvent> events = noiseEventRepository.findByUserAndMeasuredAtBetween(
                user, dto.getCheckinTime(), dto.getCheckoutTime());

        double avgDb = 0;
        double maxDb = 0;
        double quietRatio = 0;

        if (!events.isEmpty()) {
            avgDb = events.stream().mapToDouble(NoiseEvent::getDecibel).average().orElse(0);
            maxDb = events.stream().mapToDouble(NoiseEvent::getDecibel).max().orElse(0);
            long quietCount = events.stream()
                    .filter(e -> e.getDecibel() < QUIET_THRESHOLD_DB)
                    .count();
            quietRatio = (double) quietCount / events.size();
        }

        // 점수 및 등급 계산
        calculateScoreAndTier(user, quietRatio);

        // 세션 정보 저장
        session.setCheckoutTime(dto.getCheckoutTime());
        session.setAvgDecibel(avgDb);
        session.setMaxDecibel(maxDb);
        session.setQuietRatio(quietRatio);
        noiseSessionRepository.save(session);
    }

    // 점수 및 등급 계산: User의 points와 grade를 업데이트함
    @Transactional
    public void calculateScoreAndTier(User user, double quietRatio) {
        int sessionPoints = (int) (quietRatio * 100.0);
        user.setPoints(user.getPoints() + sessionPoints);

        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);
        double totalQuietRatio = sessions.stream().mapToDouble(NoiseSession::getQuietRatio).sum();
        double averageQuietRatio = sessions.isEmpty()
                ? quietRatio
                : (totalQuietRatio + quietRatio) / (sessions.size() + 1);

        // 등급 설정
        if (averageQuietRatio >= SILENT_GRADE_THRESHOLD) {
            user.setGrade(User.Grade.SILENT);
        } else if (averageQuietRatio >= GOOD_GRADE_THRESHOLD) {
            user.setGrade(User.Grade.GOOD);
        } else {
            user.setGrade(User.Grade.WARNING);
        }

        // 수정된 사용자 정보 저장
        userRepository.save(user);
    }

    @Transactional
    public void recalculateUserScoreAndGrade(User user) {
        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);

        // 전체 조용 비율 평균 재계산
        double averageQuietRatio = sessions.isEmpty()
                ? 0.0
                : sessions.stream().mapToDouble(NoiseSession::getQuietRatio).average().orElse(0);

        // 등급 다시 지정
        if (averageQuietRatio >= SILENT_GRADE_THRESHOLD) {
            user.setGrade(User.Grade.SILENT);
        } else if (averageQuietRatio >= GOOD_GRADE_THRESHOLD) {
            user.setGrade(User.Grade.GOOD);
        } else {
            user.setGrade(User.Grade.WARNING);
        }

        userRepository.save(user); // 저장해줘야 반영됨
    }

}