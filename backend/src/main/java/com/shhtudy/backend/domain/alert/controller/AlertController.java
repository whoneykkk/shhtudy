package com.shhtudy.backend.domain.alert.controller;

import com.shhtudy.backend.domain.alert.dto.AlertStatusResponseDto;
import com.shhtudy.backend.domain.alert.service.AlertService;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.global.response.ResponseCustom;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/alerts")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Alert", description = "알림 관련 API")

public class AlertController {
    private final AlertService alertService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "알림 여부 조회", description = "읽지 않은 알림 여부를 조회 합니다.")
    @GetMapping("/unread-status")
    public ResponseCustom<AlertStatusResponseDto> getUnreadAlertStatus(@RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        AlertStatusResponseDto response = alertService.getHasUnreadNotifications(userId);
        return ResponseCustom.OK(response);
    }
}
