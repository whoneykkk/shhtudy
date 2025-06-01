package com.shhtudy.backend.domain.message.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.util.List;

@Getter
@Schema(description = "마이페이지 메시지 응답 DTO")
public class MyPageMessagesResponseDto {
    private final long unreadCount;
    private final List<MyPageMessageDto> messages;

    public MyPageMessagesResponseDto(long unreadCount, List<MyPageMessageDto> messages) {
        this.unreadCount = unreadCount;
        this.messages = messages;
    }
}
