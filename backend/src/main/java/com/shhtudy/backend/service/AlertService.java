package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.AlertStatusResponseDto;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.NoticeReadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AlertService {
    private final NoticeReadRepository noticeReadRepository;
    private final MessageRepository messageRepository;

    public AlertStatusResponseDto getHasUnreadNotifications(String firebaseUid) {
        // 읽지 않은 메시지 확인
        boolean hasUnreadMessages = messageRepository.countByReceiverIdAndReadFalseAndDeletedByReceiverFalse(firebaseUid) > 0;
        boolean hasUnreadNotices = noticeReadRepository.existsUnreadNotices(firebaseUid);

        AlertStatusResponseDto response = new AlertStatusResponseDto();
        response.setHasUnreadMessages(hasUnreadMessages || hasUnreadNotices);

        return response;
    }
}
