package com.shhtudy.backend.domain.usage.repository;

import com.shhtudy.backend.domain.usage.entity.Usage;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsageRepository extends JpaRepository<Usage, Long> {
    Optional<Usage> findTopByUser_FirebaseUidAndUsageStatusOrderByCheckInTimeDesc(String firebaseUid, UsageStatus status);
}
