package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "User", description = "유저 관련 API")

public class UserController {
    private final UserService userService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "회원가입", description = "신규 가입을 합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<String>> signUp(@RequestBody @Valid SignUpRequestDto request,
                                         @RequestHeader("Authorization") String authorizationHeader) {
        // FirebaseAuthService에서 토큰 검증
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        // 회원가입 로직 실행
        userService.signUp(request, firebaseUid);

        return ResponseEntity.ok(
                new ApiResponse<>(true, "회원가입 완료!", null)
        );
    }
    @Operation(summary = "(임시)사용자 확인", description = "현재 로그인한 사용자를 확인합니다.")
    @GetMapping("/me")
    public ApiResponse<String> getMyUid(@RequestHeader("Authorization") String authorizationHeader) {
        String token = authorizationHeader.replace("Bearer ", "");
        String uid = firebaseAuthService.verifyIdToken(token);
        return ApiResponse.success(uid, "현재 로그인한 UID");
    }

}
