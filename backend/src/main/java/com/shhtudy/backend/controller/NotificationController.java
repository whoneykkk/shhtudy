package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.NotificationStatusResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notifications")

public class NotificationController {
    private final NotificationService notificationService;
    private final FirebaseAuthService firebaseAuthService;

    @GetMapping("/unread-status")
    public ResponseEntity<ApiResponse<NotificationStatusResponseDto>> getUnreadNotificationStatus(@RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);

        NotificationStatusResponseDto response = notificationService.getHasUnreadNotifications(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "읽지 않은 알림 여부 조회 성공"));

    }

}
