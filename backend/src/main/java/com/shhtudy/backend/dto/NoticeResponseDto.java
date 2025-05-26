package com.shhtudy.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@Schema(description = "단건 공지 응답 DTO")
public class NoticeResponseDto {
    private final String title;
    private final String content;
    private final String createdAt;
}
