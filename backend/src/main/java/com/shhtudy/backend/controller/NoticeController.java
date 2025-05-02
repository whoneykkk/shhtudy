package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.NoticeResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notices")

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
}
