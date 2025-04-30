package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.dto.LoginRequestDto;
import com.shhtudy.backend.dto.LoginResponseDto;
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

    @PostMapping
    public ResponseEntity<String> signUp(@RequestBody @Valid SignUpRequestDto request,
                                     @RequestHeader("Authorization") String authorizationHeader) {
        // "Bearer {token}" → 순수 토큰만 추출
        String idToken = authorizationHeader.replace("Bearer ", "");

        // 회원가입 로직 실행
        userService.signUp(request, idToken);

        // 성공 메시지 반환
        return ResponseEntity.ok("회원가입 완료!");
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody @Valid LoginRequestDto request) {
        LoginResponseDto response = userService.login(request);
        return ResponseEntity.ok(response);
    }
}
