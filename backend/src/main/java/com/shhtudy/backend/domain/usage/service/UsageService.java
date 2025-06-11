package com.shhtudy.backend.domain.usage.service;

import com.shhtudy.backend.domain.usage.entity.Usage;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import com.shhtudy.backend.domain.usage.repository.UsageRepository;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UsageService {

    private final UsageRepository usageRepository;
    private final UserRepository userRepository;

    public void checkIn(String firebaseUid) {
        User user = userRepository.findById(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Usage usage = Usage.checkIn(user);
        usageRepository.save(usage);
        //TODO: 남은시간 반환?
    }

    @Transactional
    public void checkOut(String firebaseUid) {
        Usage usage = usageRepository
                .findTopByUser_FirebaseUidAndUsageStatusOrderByCheckInTimeDesc(firebaseUid, UsageStatus.IN_PROGRESS)
                .orElseThrow(() -> new CustomException(ErrorCode.USAGE_NOT_FOUND));

        usage.checkOut();
    }

    @Transactional
    public void expire(String firebaseUid) {
        Usage usage = usageRepository
                .findTopByUser_FirebaseUidAndUsageStatusOrderByCheckInTimeDesc(firebaseUid, UsageStatus.IN_PROGRESS)
                .orElseThrow(() -> new CustomException(ErrorCode.USAGE_NOT_FOUND));

        usage.expire();
    }
}
