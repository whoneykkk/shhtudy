package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.LoginRequestDto;
import com.shhtudy.backend.dto.LoginResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponseDto>> login(@Valid @RequestBody LoginRequestDto request) {
        LoginResponseDto loginResponse = authService.login(request);

        return ResponseEntity.ok(
                new ApiResponse<>(true, "로그인 성공", loginResponse)
        );
    }
}
