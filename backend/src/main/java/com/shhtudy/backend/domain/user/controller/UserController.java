package com.shhtudy.backend.domain.user.controller;

import com.shhtudy.backend.domain.user.dto.SignUpRequestDto;
import com.shhtudy.backend.domain.user.dto.UserProfileResponseDto;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.domain.user.service.UserService;
import com.shhtudy.backend.global.response.ResponseCustom;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/users")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "User", description = "유저 관련 API")

public class UserController {
    private final UserService userService;
    private final FirebaseAuthService firebaseAuthService;

    private String extractUid(String authorizationHeader) {
        return firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
    }

    //TODO: 아마 지우는 것 같음
    @Operation(summary = "회원가입", description = "신규 가입을 합니다.")
    @PostMapping
    public ResponseCustom<Void> signUp(@RequestBody @Valid SignUpRequestDto request,
                                 @RequestHeader("Authorization") String authorizationHeader) {
        String firebaseUid = extractUid(authorizationHeader);

        userService.signUp(request, firebaseUid);

        return ResponseCustom.OK();
    }
    
    @Operation(summary = "사용자 프로필 조회", description = "현재 로그인한 사용자의 프로필을 조회합니다.")
    @GetMapping("/profile")
    public ResponseCustom<UserProfileResponseDto> getUserProfile(@RequestHeader("Authorization") String authorizationHeader) {
        String firebaseUid = extractUid(authorizationHeader);
        
        UserProfileResponseDto response = userService.getUserProfile(firebaseUid);
        return ResponseCustom.OK(response);
    }
}
