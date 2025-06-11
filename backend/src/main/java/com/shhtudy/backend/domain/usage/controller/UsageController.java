package com.shhtudy.backend.domain.usage.controller;

import com.shhtudy.backend.domain.usage.service.UsageService;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.global.response.ResponseCustom;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/usages")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Usage", description = "체크인, 체크아웃 관련 API")
public class UsageController {

    private final UsageService usageService;
    private final FirebaseAuthService firebaseAuthService;

    private String extractUid(String authorizationHeader) {
        return firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
    }

    @Operation(summary = "체크인", description = "사용자가 좌석에 입장할 때 체크인 로그를 남깁니다.")
    @PostMapping("/check-in")
    public ResponseCustom<Void> checkIn(@RequestHeader("Authorization") String authorizationHeader) {
        String firebaseUid = extractUid(authorizationHeader);
        usageService.checkIn(firebaseUid);
        return ResponseCustom.OK();
    }

    @Operation(summary = "체크아웃", description = "사용자가 좌석을 떠날 때 체크아웃 로그를 남깁니다.")
    @PostMapping("/check-out")
    public ResponseCustom<Void> checkOut(@RequestHeader("Authorization") String authorizationHeader) {
        String firebaseUid = extractUid(authorizationHeader);
        usageService.checkOut(firebaseUid);
        return ResponseCustom.OK();
    }

    @Operation(summary = "만료 처리", description = "사용자의 시간이 0이 되었을 때 만료 로그를 남깁니다.")
    @PostMapping("/expire")
    public ResponseCustom<Void> expire(@RequestHeader("Authorization") String authorizationHeader) {
        String firebaseUid = extractUid(authorizationHeader);
        usageService.expire(firebaseUid);
        return ResponseCustom.OK();
    }
}
