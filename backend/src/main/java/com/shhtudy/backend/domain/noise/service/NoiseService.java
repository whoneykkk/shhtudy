package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.dto.*;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.noise.repository.NoiseEventRepository;
import com.shhtudy.backend.domain.noise.repository.NoiseSessionRepository;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
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

    @Operation(
            summary = "소음 이벤트 저장",
            description = "실시간 측정된 소음 이벤트를 서버에 저장합니다."
    )
    public void saveNoiseEvent(User user, NoiseEventRequestDto dto) {
        NoiseEvent event = NoiseEvent.builder()
                .user(user)
                .decibel(dto.getDecibel())
                .measuredAt(dto.getMeasuredAt())
                .build();
        noiseEventRepository.save(event);
    }

    @Operation(
            summary = "소음 세션 종료 및 통계 저장",
            description = "소음 세션을 종료하고 통계를 서버에 저장합니다."
    )
    @Transactional
    public void closeSession(User user, NoiseSessionRequestDto dto) {
        // 세션 조회
        NoiseSession session = noiseSessionRepository.findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("진행 중인 세션이 없습니다."));

        //로그 조회
        List<NoiseEvent> events = noiseEventRepository.findByUserAndMeasuredAtBetween(
                user, dto.getCheckinTime(), dto.getCheckoutTime());
        // 세션 시간 검증
        if (!session.getCheckinTime().equals(dto.getCheckinTime()) ||
                !session.getCheckoutTime().equals(dto.getCheckoutTime())) {
            throw new IllegalArgumentException("제공된 시간이 세션과 일치하지 않습니다.");
        }

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

    private static final double EXCELLENT_QUIET_RATIO = 0.9;
    private static final double GOOD_QUIET_RATIO = 0.7;

    private static final double EXCELLENT_AVG_DB = 40.0;
    private static final double GOOD_AVG_DB = 50.0;

    private static final int EXCELLENT_ABRUPT_COUNT = 0;
    private static final int GOOD_ABRUPT_COUNT = 2;

    private static final int EXCELLENT_SCORE = 5;
    private static final int GOOD_SCORE = 3;

    private int calculateSessionScore(double avgDb, double quietRatio, int abruptCount) {
        int score = 0;
        score += (quietRatio >= EXCELLENT_QUIET_RATIO) ? EXCELLENT_SCORE :
                (quietRatio >= GOOD_QUIET_RATIO) ? GOOD_SCORE : 0;

        score += (avgDb <= EXCELLENT_AVG_DB) ? EXCELLENT_SCORE :
                (avgDb <= GOOD_AVG_DB) ? GOOD_SCORE : 0;

        score += (abruptCount <= EXCELLENT_ABRUPT_COUNT) ? EXCELLENT_SCORE :
                (abruptCount <= GOOD_ABRUPT_COUNT) ? GOOD_SCORE : 0;

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

    @Operation(
            summary = "소음 리포트 조회",
            description = "가장 최근 소음 세션의 통계 리포트를 조회합니다."
    )
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
                .grade(user.getGrade())
                .avgDecibel(avgDecibel)
                .maxDecibel(maxDecibel)
                .eventCount(eventCount)
                .userQuietRatio(userQuietRatio)
                .eventSummaries(summaryDto)
                .build();
    }

    @Operation(
            summary = "매너 점수 조회",
            description = "현재 사용자의 누적 포인트, 등급, 평균 데시벨, 소음 이벤트 횟수를 조회합니다."
    )
    @Transactional(readOnly = true)
    public MannerScoreResponseDto getMannerScore(User user) {
        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);

        double averageDb = sessions.stream().mapToDouble(NoiseSession::getAvgDecibel).average().orElse(0.0);
        int totalOverCount = (int) sessions.stream()
                .mapToLong(s -> noiseEventRepository.findBySession(s).stream()
                        .filter(e -> e.getDecibel() > QUIET_THRESHOLD_DB).count()).sum();

        return MannerScoreResponseDto.builder()
                .point(user.getPoints())
                .grade(user.getGrade())
                .avgDecibel(averageDb)
                .eventCount(totalOverCount)
                .build();
    }

    @Operation(
            summary = "전체 소음 로그 조회",
            description = "가장 최근 세션의 모든 소음 로그(45dB 초과)를 반환합니다."
    )
    @Transactional
    public NoiseEventListDto getAllNoiseLogs(User user) {
        NoiseSession session = noiseSessionRepository
                .findTopByUserAndCheckoutTimeIsNotNullOrderByCheckoutTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("종료된 세션이 없습니다."));

        List<NoiseEvent> events = noiseEventRepository
                .findBySessionAndDecibelGreaterThan(session, QUIET_THRESHOLD_DB);

        return NoiseEventListDto.from(events);
    }
}