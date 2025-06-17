package com.shhtudy.backend.domain.notice.dto;

import com.shhtudy.backend.domain.notice.entity.Notice;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

@Getter
@Schema(description = "공지 목록 응답 DTO")
public class NoticeListResponseDto {
    private final Long id;
    private final String title;
    private final String previewContent;
    private final boolean isRead;

    public NoticeListResponseDto(Notice notice, boolean isRead) {
        this.id = notice.getId();
        this.title = notice.getTitle();
        this.previewContent = generatePreviewContent(notice.getContent());
        this.isRead = isRead;
    }

    private String generatePreviewContent(String content) {
        if (content == null) return "";
        return content.length() > 30 ? content.substring(0, 30) + "..." : content;
    }
}
