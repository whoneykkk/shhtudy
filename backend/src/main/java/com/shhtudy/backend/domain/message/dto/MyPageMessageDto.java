package com.shhtudy.backend.domain.message.dto;

import com.shhtudy.backend.domain.message.entity.Message;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
@Schema(description = "마이페이지 메시지 단건 DTO")
public class MyPageMessageDto {

    private final String counterpartDisplayName;
    private final String contentPreview;
    private final boolean isRead;
    private final String sentAt;
    private final boolean isSentByMe;

    public MyPageMessageDto(Message message, String counterpartDisplayName, boolean isSentByMe) {
        this.counterpartDisplayName = counterpartDisplayName;

        String content = message.getContent();
        this.contentPreview = content != null && content.length() > 50
                ? content.substring(0, 50) + "..."
                : content;

        this.isRead = message.isRead();

        this.sentAt = message.getSentAt() != null
                ? message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
                : "";

        this.isSentByMe = isSentByMe;
    }
}
