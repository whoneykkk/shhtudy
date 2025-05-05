package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.AlertStatusResponseDto;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.NoticeReadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
// import org.springframework.stereotype.Service;

// @Service 임시 주석 처리 (메시지 기능 구현 시 주석 해제 필요)
@Component
@RequiredArgsConstructor
public class AlertService {

    private final MessageRepository messageRepository;
    private final NoticeReadRepository noticeReadRepository;

    public AlertStatusResponseDto getHasUnreadNotifications(String userId) {
        // 메시지 기능 구현 전 임시 코드
        boolean hasUnreadMessages = false; // messageRepository.existsByReceiverIdAndIsReadFalse(userId);
        boolean hasUnreadNotices = noticeReadRepository.existsUnreadNotices(userId);

        AlertStatusResponseDto response = new AlertStatusResponseDto();
        response.setHasUnreadMessages(hasUnreadMessages || hasUnreadNotices);

        return response;
    }
}
