package com.shhtudy.backend.domain.message.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.shhtudy.backend.domain.message.entity.Message;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@Builder
@Schema(description = "쪽지 목록 조회 응답 DTO")
public class MessageListResponseDto {

    @Schema(description = "쪽지 ID", example = "42")
    private Long id;

    @Schema(description = "대화 상대 표시 이름", example = "A-3번 (123)")
    private String counterpartDisplayName;

    @Schema(description = "쪽지 미리보기 (최대 30자)", example = "안녕하세요, 혹시 지금 시간 괜찮으신가요...")
    private String contentPreview;

    @Schema(description = "읽음 여부", example = "false")
    private boolean isRead;

    @Schema(description = "보낸 시간", example = "2025.06.11 17:30")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime sentAt;

    @Schema(description = "내가 보낸 쪽지 여부", example = "true")
    private boolean isSentByMe;

    public static MessageListResponseDto from(Message message, String counterpartDisplayName, boolean isSentByMe) {
        return new MessageListResponseDto(
                message.getId(),
                counterpartDisplayName,
                preview(message.getContent()),
                message.isRead(),
                message.getSentAt(),
                isSentByMe
        );
    }

    private static String preview(String content) {
        return content.length() > 30 ? content.substring(0, 30) + "..." : content;
    }
}
