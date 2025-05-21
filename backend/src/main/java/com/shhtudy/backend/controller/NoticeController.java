package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.NoticeResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.NoticeService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notices")
@Tag(name = "Notice", description = "공지 관련 API")

public class NoticeController {
    private final NoticeService noticeService;
    private final FirebaseAuthService firebaseAuthService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<NoticeResponseDto>>> getNotices(@RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        List<NoticeResponseDto> response= noticeService.getNoticeWithRaeadStatus(userId);

        return ResponseEntity.ok(ApiResponse.success(response, "공지사항 조회 성공"));
    }

    @PostMapping("/{noticeId}/read")
    public ResponseEntity<ApiResponse<Void>> readNotice(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long noticeId
    ){
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        noticeService.markAsRead(userId, noticeId);

        return ResponseEntity.ok(ApiResponse.success(null, "읽음 처리 완료"));
    }
}
