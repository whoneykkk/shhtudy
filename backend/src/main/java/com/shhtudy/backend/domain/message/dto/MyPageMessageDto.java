package com.shhtudy.backend.domain.message.dto;

import com.shhtudy.backend.domain.message.entity.Message;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
public class MyPageMessageDto {
    final private String counterpartDisplayName;
    final private String contentPreview;
    final private boolean isRead;
    final private String sentAt;
    final private boolean isSentByMe;

    public MyPageMessageDto(Message message, String counterpartDisplayName, boolean isSentByMe) {
        this.counterpartDisplayName = counterpartDisplayName;
        this.contentPreview = message.getContent(); // 또는 줄여서 preview 처리
        this.isRead = message.isRead();
        this.sentAt = message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        this.isSentByMe = isSentByMe;
    }
}
