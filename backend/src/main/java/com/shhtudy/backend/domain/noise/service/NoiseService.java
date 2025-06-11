package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.dto.*;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.noise.repository.NoiseEventRepository;
import com.shhtudy.backend.domain.noise.repository.NoiseSessionRepository;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoiseService {

    private final NoiseEventRepository noiseEventRepository;
    private final NoiseSessionRepository noiseSessionRepository;
    private final UserRepository userRepository;

    private static final double QUIET_THRESHOLD_DB = 45.0;

    // 소음 이벤트 저장
    public void saveNoiseEvent(User user, NoiseEventRequestDto dto) {
        NoiseEvent event = NoiseEvent.builder()
                .user(user)
                .decibel(dto.getDecibel())
                .measuredAt(dto.getMeasuredAt())
                .build();
        noiseEventRepository.save(event);
    }

    // 세션 종료
    @Transactional
    public void closeSession(User user, NoiseSessionRequestDto dto) {
        // 세션 조회
        NoiseSession session = noiseSessionRepository.findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("진행 중인 세션이 없습니다."));

        //로그 조회
        List<NoiseEvent> events = noiseEventRepository.findByUserAndMeasuredAtBetween(
                user, dto.getCheckinTime(), dto.getCheckoutTime());

        int abruptCount = countAbruptNoises(events);
        int sessionScore = calculateSessionScore(dto.getAverageDecibel(), dto.getQuietRatio(), abruptCount);
        updateUserPointsAndGrade(user, sessionScore);

        session.setCheckoutTime(dto.getCheckoutTime());
        session.setAvgDecibel(dto.getAverageDecibel());
        session.setMaxDecibel(dto.getMaxDecibel());
        session.setQuietRatio(dto.getQuietRatio());
        noiseSessionRepository.save(session);
    }

    private int countAbruptNoises(List<NoiseEvent> events) {
        List<NoiseEvent> sorted = events.stream()
                .sorted(Comparator.comparing(NoiseEvent::getMeasuredAt))
                .toList();

        int count = 0;
        long consecutiveSeconds = 0;
        NoiseEvent prev = null;

        for (NoiseEvent event : sorted) {
            if (event.getDecibel() > QUIET_THRESHOLD_DB) {
                if (prev != null) {
                    long diff = Duration.between(prev.getMeasuredAt(), event.getMeasuredAt()).getSeconds();
                    if (diff <= 1) {
                        consecutiveSeconds += diff;
                    } else {
                        consecutiveSeconds = 1;
                    }
                } else {
                    consecutiveSeconds = 1;
                }

                if (consecutiveSeconds >= 3) {
                    count++;
                    consecutiveSeconds = 0;
                    prev = null;
                    continue;
                }
            } else {
                consecutiveSeconds = 0;
            }
            prev = event;
        }
        return count;
    }

    private int calculateSessionScore(double avgDb, double quietRatio, int abruptCount) {
        int score = 0;
        score += (quietRatio >= 0.9) ? 5 : (quietRatio >= 0.7 ? 3 : 0);
        score += (avgDb <= 40) ? 5 : (avgDb <= 50 ? 3 : 0);
        score += (abruptCount == 0) ? 5 : (abruptCount <= 2 ? 3 : 0);
        return Math.max(-15, Math.min(15, score));
    }

    private void updateUserPointsAndGrade(User user, int sessionScore) {
        int currentPoints = user.getPoints();
        int newPoints = Math.max(0, Math.min(300, currentPoints + sessionScore));
        user.setPoints(newPoints);

        if (newPoints >= 240) {
            user.setGrade(User.Grade.SILENT);
        } else if (newPoints >= 160) {
            user.setGrade(User.Grade.GOOD);
        } else {
            user.setGrade(User.Grade.WARNING);
        }
        userRepository.save(user);
    }

    @Transactional(readOnly = true)
    public NoiseReportResponseDto getNoiseReport(User user) {
        // 가장 최근 종료된 세션 조회
        NoiseSession session = noiseSessionRepository
                .findTopByUserAndCheckoutTimeIsNotNullOrderByCheckoutTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("종료된 세션이 없습니다."));

        // 해당 세션의 모든 소음 이벤트 가져오기
        List<NoiseEvent> events = noiseEventRepository.findBySession(session);

        // 통계 계산
        double avgDecibel = session.getAvgDecibel();
        double maxDecibel = session.getMaxDecibel();
        int eventCount = (int) events.stream().filter(e -> e.getDecibel() > QUIET_THRESHOLD_DB).count();
        double userQuietRatio = session.getQuietRatio();

        // 요약 소음 이벤트 3개 추출
        List<NoiseEventSummaryDto> summaryDto = events.stream()
                .filter(e -> e.getDecibel() > QUIET_THRESHOLD_DB)
                .sorted(Comparator.comparing(NoiseEvent::getDecibel).reversed())
                .limit(3)
                .map(NoiseEventSummaryDto::from)
                .toList();

        // 리포트 DTO 생성
        return NoiseReportResponseDto.builder()
                .grade(user.getGrade().name())
                .avgDecibel(avgDecibel)
                .maxDecibel(maxDecibel)
                .eventCount(eventCount)
                .userQuietRatio(userQuietRatio)
                .eventSummaries(summaryDto)
                .build();
    }

    @Transactional(readOnly = true)
    public MannerScoreResponseDto getMannerScore(User user) {
        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);

        double averageDb = sessions.stream().mapToDouble(NoiseSession::getAvgDecibel).average().orElse(0.0);
        int totalOverCount = (int) sessions.stream()
                .mapToLong(s -> noiseEventRepository.findBySession(s).stream()
                        .filter(e -> e.getDecibel() > QUIET_THRESHOLD_DB).count()).sum();

        return MannerScoreResponseDto.builder()
                .point(user.getPoints())
                .grade(user.getGrade().name())
                .avgDecibel(averageDb)
                .eventCount(totalOverCount)
                .build();
    }
}