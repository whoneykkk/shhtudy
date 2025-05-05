package com.shhtudy.backend.dto;

import com.shhtudy.backend.entity.Notice;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
public class NoticeResponseDto {
    private final Long noticeId;
    private final String title;
    private final String content;
    private final String createdAt;
    private final boolean isRead;

    public NoticeResponseDto(Notice notice, boolean isRead) {
        this.noticeId = notice.getId();
        this.title = notice.getTitle();
        this.content = notice.getContent();
        this.createdAt = notice.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        this.isRead = isRead;
    }
}
