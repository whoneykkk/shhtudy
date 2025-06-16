package com.shhtudy.backend.domain.usage.scheduler;

import com.shhtudy.backend.domain.usage.entity.Usage;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import com.shhtudy.backend.domain.usage.repository.UsageRepository;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Component
public class UsageSessionSplitScheduler {

    private final UsageRepository usageRepository;
    private final UserRepository userRepository;

    public UsageSessionSplitScheduler(UsageRepository usageRepository, UserRepository userRepository) {
        this.usageRepository = usageRepository;
        this.userRepository = userRepository;
    }

    @Scheduled(cron = "0 0 0 * * *") // 매일 00:00:00 실행
    @Transactional
    public void splitSessionsAtMidnight() {
        LocalDateTime midnight = LocalDate.now().atStartOfDay();

        // 진행중인 세션 조회
        List<Usage> activeUsages = usageRepository.findByUsageStatus(UsageStatus.IN_PROGRESS);

        for (Usage usage : activeUsages) {
            // 1) 현재 세션 체크아웃 시간 자정으로 설정
            usage.setCheckOutTime(midnight);
            usage.setUsageStatus(UsageStatus.COMPLETED);

            usageRepository.save(usage);

            // 2) 새로운 세션 생성 (같은 유저, 자정 체크인)
            Usage newUsage = new Usage();
            newUsage.setUser(usage.getUser());
            newUsage.setCheckInTime(midnight);
            newUsage.setUsageStatus(UsageStatus.IN_PROGRESS);

            usageRepository.save(newUsage);
        }
    }
}
