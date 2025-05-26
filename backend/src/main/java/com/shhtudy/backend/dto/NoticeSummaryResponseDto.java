package com.shhtudy.backend.dto;

import com.shhtudy.backend.entity.Notice;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
public class NoticeSummaryResponseDto {
    private final Long noticeId;
    private final String title;
    private final String previewContent;
    private final String createdAt;
    private final boolean isRead;

    public NoticeSummaryResponseDto(Notice notice, boolean isRead) {
        this.noticeId = notice.getId();
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
