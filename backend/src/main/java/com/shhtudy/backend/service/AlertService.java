package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.AlertStatusResponseDto;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.NoticeReadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final MessageRepository messageRepository;
    private final NoticeReadRepository noticeReadRepository;

    public AlertStatusResponseDto getHasUnreadNotifications(String userId) {
        boolean hasUnreadMessages = messageRepository.existsUnreadMessages(userId);
        boolean hasUnreadNotices=noticeReadRepository.existsUnreadNotices(userId);

        AlertStatusResponseDto response = new AlertStatusResponseDto();
        response.setHasUnreadMessages(hasUnreadMessages || hasUnreadNotices);

        return response;
    }
}
