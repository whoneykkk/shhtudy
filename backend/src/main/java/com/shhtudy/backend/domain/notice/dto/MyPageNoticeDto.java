package com.shhtudy.backend.domain.notice.dto;

import com.shhtudy.backend.domain.notice.entity.Notice;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
@Schema(description = "마이페이지 공지 단건 DTO")
public class MyPageNoticeDto {
    private final String title;
    private final String createdAt;
    private final boolean isRead;

    public MyPageNoticeDto(Notice notice, boolean isRead) {
        this.title = notice.getTitle();
        this.createdAt = notice.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        this.isRead = isRead;
    }
}
