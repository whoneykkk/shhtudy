package com.shhtudy.backend.domain.notice.dto;

import com.shhtudy.backend.domain.notice.entity.Notice;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
@Schema(description = "공지 목록 응답 DTO")
public class NoticeListResponseDto {
    private final String title;
    private final String previewContent;
    private final String createdAt;
    private final boolean isRead;

    public NoticeListResponseDto(Notice notice, boolean isRead) {
        this.title = notice.getTitle();
        this.previewContent = generatePreviewContent(notice.getContent());
        this.createdAt = notice.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        this.isRead = isRead;
    }

    private String generatePreviewContent(String content) {
        if (content == null) return "";
        return content.length() > 30 ? content.substring(0, 30) + "..." : content;
    }
}
