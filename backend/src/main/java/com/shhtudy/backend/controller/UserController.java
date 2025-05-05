package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.SignUpRequestDto;
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
    public ResponseEntity<String> signUp(@RequestBody @Valid SignUpRequestDto request,
                                         @RequestHeader("Authorization") String authorizationHeader) {
        // FirebaseAuthService에서 토큰 검증
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        // 회원가입 로직 실행
        userService.signUp(request, firebaseUid);

        return ResponseEntity.ok("회원가입 완료!");

    }
}
