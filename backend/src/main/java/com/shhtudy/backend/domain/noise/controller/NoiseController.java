package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.dto.*;
import com.shhtudy.backend.domain.noise.service.NoiseService;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.global.response.ResponseCustom;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/noise")
@RequiredArgsConstructor
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Noise", description = "소음 관련 API")
public class NoiseController {

    private final NoiseService noiseService;
    private final FirebaseAuthService firebaseAuthService;

    private String extractUid(String authorizationHeader) {
        return firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
    }

    @PostMapping("/event")
    @Operation(summary = "소음 이벤트 저장", description = "실시간 측정된 소음 이벤트를 서버에 저장합니다.")
    public ResponseCustom<Void> saveNoiseEvent(@RequestHeader("Authorization") String authorizationHeader,
                                               @RequestBody @Valid NoiseEventRequestDto dto) {

        String userId = extractUid(authorizationHeader);
        noiseService.saveNoiseEvent(userId, dto);
        return ResponseCustom.OK();
    }

    @GetMapping("/events")
    @Operation(summary = "소음 이벤트 목록 조회", parameters = {
            @Parameter(name = "page", description = "페이지 번호 (0부터 시작)", example = "0"),
            @Parameter(name = "size", description = "페이지 크기", example = "10"),
            @Parameter(name = "sort", description = "정렬 기준 (measuredAt,DESC)", example = "measuredAt,DESC")
    })
    public ResponseEntity<NoiseEventListDto> getNoiseEventPage(
            @RequestHeader("Authorization") String authorizationHeader, // 인증 필터에서 추출된 UID
            @ParameterObject @PageableDefault(size = 10, sort = "measuredAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        String userId = extractUid(authorizationHeader);
        NoiseEventListDto result = noiseService.getNoiseEventPage(userId, pageable);
        return ResponseEntity.ok(result);
    }

    @PutMapping("/session/close")
    @Operation(summary = "소음 세션 종료 및 통계 저장")
    public ResponseCustom<Void> closeNoiseSession(@RequestHeader("Authorization") String authorizationHeader,
                                                  @RequestBody @Validated NoiseSessionRequestDto requestDto) {
        String userId = extractUid(authorizationHeader);
        noiseService.closeSession(userId, requestDto);
        return ResponseCustom.OK();
    }

    @GetMapping("/report")
    @Operation(summary = "소음 리포트 조회", description = "가장 최근 소음 세션의 통계 리포트를 조회합니다.")
    public ResponseCustom<NoiseReportResponseDto> getReport(@RequestHeader("Authorization") String authorizationHeader) {
        String userId = extractUid(authorizationHeader);
        return ResponseCustom.OK(noiseService.getNoiseReport(userId));
    }

    @GetMapping("/manner")
    @Operation(summary = "매너 점수 조회", description = "현재 사용자의 누적 포인트, 등급, 평균 데시벨, 소음 이벤트 횟수를 조회합니다.")
    public ResponseCustom<MannerScoreResponseDto> getMannerScore(@RequestHeader("Authorization") String authorizationHeader) {
        String userId = extractUid(authorizationHeader);
        return ResponseCustom.OK(noiseService.getMannerScore(userId));
    }
}