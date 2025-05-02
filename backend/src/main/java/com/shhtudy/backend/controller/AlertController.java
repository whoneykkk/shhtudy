package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.AlertStatusResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/alerts")

public class AlertController {
    private final AlertService alertService;
    private final FirebaseAuthService firebaseAuthService;

    @GetMapping("/unread-status")
    public ResponseEntity<ApiResponse<AlertStatusResponseDto>> getUnreadAlertStatus(@RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        AlertStatusResponseDto response = alertService.getHasUnreadNotifications(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "읽지 않은 알림 여부 조회 성공"));

    }

}
