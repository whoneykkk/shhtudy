package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.dto.UserProfileResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")

public class UserController {
    private final UserService userService;
    private final FirebaseAuthService firebaseAuthService;

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
    
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileResponseDto>> getUserProfile(
            @RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);
        
        UserProfileResponseDto profileDto = userService.getUserProfile(userId);
        
        return ResponseEntity.ok(
                ApiResponse.success(profileDto, "프로필 조회 성공")
        );
    }
    
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader("Authorization") String authorizationHeader) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String userId = firebaseAuthService.verifyIdToken(idToken);
        
        // 로그아웃 처리
        userService.logout(userId);
        
        return ResponseEntity.ok(
                ApiResponse.success(null, "로그아웃 성공")
        );
    }
}
