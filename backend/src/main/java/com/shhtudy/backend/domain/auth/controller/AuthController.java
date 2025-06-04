package com.shhtudy.backend.domain.auth.controller;

import com.shhtudy.backend.domain.auth.dto.LoginRequestDto;
import com.shhtudy.backend.domain.auth.dto.LoginResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.domain.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "인증 관련 API")

public class AuthController {

    private final AuthService authService;

    @Operation(summary = "로그인")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponseDto>> login(@Valid @RequestBody LoginRequestDto request) {
        LoginResponseDto loginResponse = authService.login(request);

        return ResponseEntity.ok(
                new ApiResponse<>(true, "로그인 성공", loginResponse)
        );
    }
}
