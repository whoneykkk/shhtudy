package com.shhtudy.backend.domain.notice.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.shhtudy.backend.domain.notice.entity.Notice;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Schema(description = "마이페이지 공지 단건 DTO")
public class MyPageNoticeDto {
    private final String title;
    @Schema(description = "공지 생성 시각", example = "2025.06.12 14:30")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private final LocalDateTime createdAt;
    private final boolean isRead;

    public MyPageNoticeDto(Notice notice, boolean isRead) {
        this.title = notice.getTitle();
        this.createdAt = notice.getCreatedAt();
        this.isRead = isRead;
    }
}
