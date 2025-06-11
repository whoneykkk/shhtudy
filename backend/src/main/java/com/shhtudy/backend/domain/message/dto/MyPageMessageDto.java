package com.shhtudy.backend.domain.message.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.shhtudy.backend.domain.message.entity.Message;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Schema(description = "마이페이지 메시지 단건 DTO")
public class MyPageMessageDto {

    @Schema(description = "대화 상대 표시 이름", example = "A-3번 (123)")
    private final String counterpartDisplayName;

    @Schema(description = "내용 미리보기 (최대 50자)", example = "시끄러워요")
    private final String contentPreview;

    @Schema(description = "읽음 여부", example = "false")
    private final boolean isRead;

    @Schema(description = "보낸 시간", example = "2025-06-11 18:45")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm")
    private final LocalDateTime sentAt;

    @Schema(description = "내가 보낸 쪽지인지 여부", example = "true")
    private final boolean isSentByMe;

    public MyPageMessageDto(Message message, String counterpartDisplayName, boolean isSentByMe) {
        this.counterpartDisplayName = counterpartDisplayName;

        String content = message.getContent();
        this.contentPreview = content != null && content.length() > 50
                ? content.substring(0, 50) + "..."
                : content;

        this.isRead = message.isRead();
        this.sentAt = message.getSentAt();
        this.isSentByMe = isSentByMe;
    }
}
