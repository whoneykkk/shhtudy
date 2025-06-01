package com.shhtudy.backend.domain.notice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

import java.util.List;

@Getter
@Schema(description = "마이페이지 공지 응답 DTO")
public class MyPageNoticesResponse {
    private final int unreadCount;
    private final List<MyPageNoticeDto> notices;

    public MyPageNoticesResponse(int unreadCount, List<MyPageNoticeDto> notices) {
        this.unreadCount = unreadCount;
        this.notices = notices;
    }
}
