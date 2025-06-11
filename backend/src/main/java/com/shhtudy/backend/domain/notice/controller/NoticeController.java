package com.shhtudy.backend.domain.notice.controller;

import com.shhtudy.backend.domain.notice.dto.MyPageNoticesResponseDto;
import com.shhtudy.backend.domain.notice.dto.NoticeListResponseDto;
import com.shhtudy.backend.domain.notice.dto.NoticeResponseDto;
import com.shhtudy.backend.domain.notice.service.NoticeService;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.global.response.ResponseCustom;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/notices")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Notice", description = "공지 관련 API")
public class NoticeController {

    private final NoticeService noticeService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "공지 목록 조회", description = "공지 목록을 조회합니다. 목록 조회 시 안 읽은 공지는 모두 읽음 처리 합니다.")
    @GetMapping
    public ResponseCustom<Page<NoticeListResponseDto>> getAllNotices(
            @RequestHeader("Authorization") String authorizationHeader,
            @Parameter(hidden = true) @PageableDefault(size = 10) Pageable pageable
    ) {
        String userId = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        Page<NoticeListResponseDto> response = noticeService.getAllNotices(userId, pageable);

        return ResponseCustom.OK(response);
    }

    @Operation(summary = "공지 상세 조회", description = "공지 1개를 상세 조회합니다. 조회한 공지는 읽음 처리 합니다.")
    @GetMapping("/{noticeId}")
    public ResponseCustom<NoticeResponseDto> getNoticeDetail(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long noticeId
    ) {
        String userId = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        NoticeResponseDto response = noticeService.getNoticeDetail(noticeId, userId);

        return ResponseCustom.OK(response);
    }

    @Operation(summary = "마이페이지 공지 요약 조회", description = "읽지 않은 공지를 최신순으로 최대 2건 조회합니다.")
    @GetMapping("/mypage")
    public ResponseCustom<MyPageNoticesResponseDto> getUnreadNoticeForMyPage(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        String userId = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        MyPageNoticesResponseDto response = noticeService.getUnreadNoticeForMyPage(userId);

        if (response.getNotices().isEmpty()) {
            return ResponseCustom.OK("읽지 않은 쪽지가 존재하지 않습니다.");
        }

        return ResponseCustom.OK(response);
    }
}
