package com.shhtudy.backend.dto;

import com.shhtudy.backend.entity.Message;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Getter
@AllArgsConstructor
public class MessageResponseDto {

    private Long id;
    private String senderDisplayName;
    private String content;
    private boolean isRead;
    private String sentAt;

    public static MessageResponseDto from(Message message, String senderDisplayName) {
        return new MessageResponseDto(
                message.getMessageId(),
                senderDisplayName,
                message.getContent(),
                message.isRead(),
                formatDateTime(message.getSentAt())
        );
    }

    private static String formatDateTime(LocalDateTime dateTime) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
        return dateTime.format(formatter);
    }
}
