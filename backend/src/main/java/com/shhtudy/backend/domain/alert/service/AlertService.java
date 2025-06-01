package com.shhtudy.backend.domain.alert.service;

import com.shhtudy.backend.domain.alert.dto.AlertStatusResponseDto;
import com.shhtudy.backend.domain.message.repository.MessageRepository;
import com.shhtudy.backend.domain.notice.repository.NoticeReadRepository;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AlertService {
    private final NoticeReadRepository noticeReadRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public AlertStatusResponseDto getHasUnreadNotifications(String firebaseUid) {
        boolean hasUnreadMessages = messageRepository.existsByReceiverIdAndReadFalseAndDeletedByReceiverFalse(firebaseUid);
        boolean hasUnreadNotices = noticeReadRepository.existsUnreadNotices(firebaseUid);

        boolean hasAlert = hasUnreadMessages || hasUnreadNotices;

        String locationCode = userRepository.findByFirebaseUid(firebaseUid)
                .map(user -> {
                    if (user.getCurrentSeat() != null) {
                        return user.getCurrentSeat().getLocationCode();
                    } else {
                        return "퇴실";
                    }
                })
                .orElse("퇴실");

        return new AlertStatusResponseDto(hasAlert, locationCode);
    }
}
