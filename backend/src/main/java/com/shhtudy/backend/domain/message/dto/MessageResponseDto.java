package com.shhtudy.backend.domain.message.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.shhtudy.backend.domain.message.entity.Message;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@Schema(description = "쪽지 상세 응답 DTO")
public class MessageResponseDto {

    @Schema(description = "쪽지 ID", example = "1")
    private Long id;

    @Schema(description = "보낸 사람 닉네임", example = "스터디왕김코딩")
    private String senderDisplayName;

    @Schema(description = "쪽지 내용", example = "오늘 2시에 자리 있어요!")
    private String content;

    @Schema(description = "읽음 여부", example = "false")
    private boolean isRead;

    @Schema(description = "보낸 시간", example = "2025.06.11 17:30")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime sentAt;

    public static MessageResponseDto from(Message message, String senderDisplayName) {
        return new MessageResponseDto(
                message.getId(),
                senderDisplayName,
                message.getContent(),
                message.isRead(),
                message.getSentAt()
        );
    }
}
