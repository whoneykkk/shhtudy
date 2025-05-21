package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.AlertStatusResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.AlertService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
// import org.springframework.web.bind.annotation.RestController;

// @RestController 임시 주석 처리 (메시지 기능 구현 시 주석 해제 필요)
@Component
@RequiredArgsConstructor
@RequestMapping("/alerts")
@Tag(name = "Alert", description = "알림 관련 API")

public class AlertController {
    private final AlertService alertService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "알림 여부 조회", description = "읽지 않은 알림 여부를 조회 합니다.")
    @GetMapping("/unread-status")
    public ResponseEntity<ApiResponse<AlertStatusResponseDto>> getUnreadAlertStatus(@RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        AlertStatusResponseDto response = alertService.getHasUnreadNotifications(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "읽지 않은 알림 여부 조회 성공"));

    }

}
