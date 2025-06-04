package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.entity.Noise;
import com.shhtudy.backend.domain.noise.enums.NoiseStatus;
import com.shhtudy.backend.domain.noise.service.NoiseService;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

//필독: 다른 도메인 컨트롤러 참고해서 firebaseUid(userId) 받기.
//@RequestHeader("Authorization") String authorizationHeader -> userId가 이거고, 파라미터에 넣기
//String firebaseUid = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", "")); // 매서드 안에 넣기

@RestController
@RequestMapping("/api/noise")
@RequiredArgsConstructor
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Noise", description = "소음 관련 API")
public class NoiseController {
    private final NoiseService noiseService;
    private final FirebaseAuthService firebaseAuthService;
    private final UserRepository userRepository;

    @Operation(summary = "", description = "")
    @PostMapping("/record")
    public ResponseEntity<Noise> recordNoise(
            @RequestParam Double decibelLevel,
            @RequestParam String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return ResponseEntity.ok(noiseService.recordNoise(decibelLevel, user));
    }

    @Operation(summary = "", description = "")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Noise>> getNoiseByStatus(@PathVariable NoiseStatus status) {
        return ResponseEntity.ok(noiseService.getNoiseByStatus(status));
    }

    @Operation(summary = "", description = "")
    @GetMapping("/history")
    public ResponseEntity<List<Noise>> getNoiseHistory(
            @RequestParam String userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return ResponseEntity.ok(noiseService.getNoiseHistory(user, startTime, endTime));
    }

    @Operation(summary = "", description = "")
    @GetMapping("/average")
    public ResponseEntity<Double> getAverageNoiseLevel(
            @RequestParam String userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return ResponseEntity.ok(noiseService.getAverageNoiseLevel(user, startTime, endTime));
    }
}