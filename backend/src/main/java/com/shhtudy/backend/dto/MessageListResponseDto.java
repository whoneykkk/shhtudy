package com.shhtudy.backend.dto;

import com.shhtudy.backend.entity.Message;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Getter
@AllArgsConstructor
@Builder
public class MessageListResponseDto {
    private Long id;
    private String counterpartDisplayName; // 예: "A-3번 (123)" or "퇴실한 사용자 (123)"
    private String contentPreview;  // 앞 30자 미리보기
    private boolean isRead;
    private String sentAt;
    private boolean isSentByMe;

    public static MessageListResponseDto from(Message msg, String counterpartDisplayName, boolean isSentByMe) {
        return new MessageListResponseDto(
                msg.getMessageId(),
                counterpartDisplayName,
                preview(msg.getContent()),
                msg.isRead(),
                formatDateTime(msg.getSentAt()),
                isSentByMe
        );
    }

    private static String preview(String content) {
        return content.length() > 30 ? content.substring(0, 30) + "..." : content;
    }

    private static String formatDateTime(LocalDateTime dateTime) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
        return dateTime.format(formatter);
    }
}
