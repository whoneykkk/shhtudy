package com.shhtudy.backend.domain.noise.service;

import com.shhtudy.backend.domain.noise.dto.*;
import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import com.shhtudy.backend.domain.noise.entity.NoiseSession;
import com.shhtudy.backend.domain.noise.repository.NoiseEventRepository;
import com.shhtudy.backend.domain.noise.repository.NoiseSessionRepository;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import com.shhtudy.backend.domain.usage.repository.UsageRepository;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoiseService {

    private final NoiseEventRepository noiseEventRepository;
    private final NoiseSessionRepository noiseSessionRepository;
    private final UsageRepository usageRepository;
    private final UserRepository userRepository;

    private static final double QUIET_THRESHOLD_DB = 45.0;

    // 소음 이벤트 저장
    public void saveNoiseEvent(String userId, NoiseEventRequestDto dto) {
        User user = userRepository.findByFirebaseUid(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        validateUserUsageSession(user, startOfToday, endOfToday);

        NoiseEvent event = NoiseEvent.builder()
                .user(user)
                .decibel(dto.getDecibel())
                .measuredAt(LocalDateTime.now())
                .build();
        noiseEventRepository.save(event);
    }

    // 세션 종료
    @Transactional
    public void closeSession(String userId, NoiseSessionRequestDto dto) {
        User user = userRepository.findByFirebaseUid(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 세션 조회
        NoiseSession session = noiseSessionRepository.findTopByUserAndCheckoutTimeIsNullOrderByCheckinTimeDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("진행 중인 세션이 없습니다."));

        //로그 조회
        List<NoiseEvent> events = noiseEventRepository.findTop2ByUserOrderByCreatedAtDesc(user);

        int abruptCount = countAbruptNoises(events);
        int sessionScore = calculateSessionScore(dto.getAverageDecibel(), dto.getQuietRatio(), abruptCount);
        updateUserPointsAndGrade(user, sessionScore);

        session.setCheckoutTime(LocalDateTime.now());
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

        if (newPoints >= 700) {
            user.setGrade(User.Grade.SILENT);
        } else if (newPoints >= 300) {
            user.setGrade(User.Grade.GOOD);
        } else {
            user.setGrade(User.Grade.WARNING);
        }
        userRepository.save(user);
    }
    private void validateUserUsageSession(User user, LocalDateTime startOfToday, LocalDateTime endOfToday){
        // 오늘 체크인 기록 확인 (Usage)
        boolean hasCheckin = usageRepository.existsByUserAndCheckInTimeBetween(user, startOfToday, endOfToday);
        if (!hasCheckin) {
            throw new CustomException(ErrorCode.NO_SESSION_TODAY);
        }

        // 오늘 체크아웃 완료 기록 확인 (Usage)
        boolean hasCheckout = usageRepository.existsByUserAndCheckOutTimeBetweenAndUsageStatus(
                user, startOfToday, endOfToday, UsageStatus.COMPLETED);
        if (!hasCheckout) {
            throw new CustomException(ErrorCode.SESSION_NOT_CHECKED_OUT);
        }
    }

    @Transactional(readOnly = true)
    public NoiseReportResponseDto getNoiseReport(String userId) {
        User user = userRepository.findByFirebaseUid(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        validateUserUsageSession(user, startOfToday, endOfToday);

        // 오늘 소음 이벤트 2건 조회 (NoiseEvent)
        List<NoiseEvent> events = noiseEventRepository.findTop2ByUserAndMeasuredAtBetweenOrderByMeasuredAtDesc(
                user, startOfToday, endOfToday);

        int todayOverCount = noiseEventRepository.countTodayOverEvents(user, QUIET_THRESHOLD_DB, startOfToday, endOfToday);

        List<NoiseEventSummaryDto> summaryDto = events.stream()
                .filter(e -> e.getDecibel() > QUIET_THRESHOLD_DB)
                .sorted(Comparator.comparing(NoiseEvent::getDecibel).reversed())
                .limit(3)
                .map(NoiseEventSummaryDto::from)
                .toList();

        return NoiseReportResponseDto.builder()
                .grade(user.getGrade().name())
                .avgDecibel(user.getAverageDecibel())      // User 엔티티의 누적 통계 사용
                .maxDecibel(0)                             // 최대값이 없으면 0 또는 별도 처리 필요
                .eventCount(todayOverCount)
                .userQuietRatio(0.0)                       // User에 없으면 계산 로직 필요
                .eventSummaries(summaryDto)
                .build();
    }

    @Transactional(readOnly = true)
    public NoiseEventListDto getNoiseEventPage(String userId, Pageable pageable) {
        User user = userRepository.findByFirebaseUid(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Page<NoiseEvent> eventPage = noiseEventRepository.findByUser(user, pageable);

        List<NoiseEventDto> eventDtos = eventPage.getContent().stream()
                .map(event -> NoiseEventDto.builder()
                        .decibel(event.getDecibel())
                        .measuredAt(event.getMeasuredAt())
                        .build())
                .toList();

        return NoiseEventListDto.builder()
                .totalCount((int) eventPage.getTotalElements())
                .events(eventDtos)
                .build();
    }

    @Transactional(readOnly = true)
    public MannerScoreResponseDto getMannerScore(String userId) {
        User user = userRepository.findByFirebaseUid(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        validateUserUsageSession(user, startOfToday, endOfToday);


        List<NoiseSession> sessions = noiseSessionRepository.findByUser(user);

        double averageDb = sessions.stream()
                .mapToDouble(NoiseSession::getAvgDecibel)
                .average()
                .orElse(0.0);

        int todayOverCount = noiseEventRepository.countTodayOverEvents(user, QUIET_THRESHOLD_DB, startOfToday, endOfToday);

        return MannerScoreResponseDto.builder()
                .point(user.getPoints())
                .grade(user.getGrade().name())
                .avgDecibel(averageDb)
                .eventCount(todayOverCount)
                .build();
    }

}