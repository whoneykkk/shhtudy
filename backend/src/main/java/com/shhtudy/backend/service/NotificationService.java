package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.NotificationStatusResponseDto;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.NoticeReadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final MessageRepository messageRepository;
    private final NoticeReadRepository noticeReadRepository;

    public NotificationStatusResponseDto getHasUnreadNotifications(String userId) {
        boolean hasUnreadMessages = messageRepository.existsUnreadMessages(userId);
        boolean hasUnreadNotices=noticeReadRepository.existsUnreadNotices(userId);

        NotificationStatusResponseDto response = new NotificationStatusResponseDto();
        response.setHasUnreadMessages(hasUnreadMessages || hasUnreadNotices);

        return response;
    }
}
