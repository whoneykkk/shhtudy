package com.shhtudy.backend.domain.usage.repository;

import com.shhtudy.backend.domain.usage.entity.Usage;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UsageRepository extends JpaRepository<Usage, Long> {
    Optional<Usage> findTopByUserAndUsageStatusOrderByCheckInTimeDesc(User user, UsageStatus status);

    List<Usage> findByUsageStatus(UsageStatus usageStatus);

    boolean existsByUserAndCheckInTimeBetween(User user, LocalDateTime startOfToday, LocalDateTime endOfToday);
    boolean existsByUserAndCheckOutTimeBetweenAndUsageStatus(User user, LocalDateTime startOfToday, LocalDateTime endOfToday, UsageStatus usageStatus);
}
