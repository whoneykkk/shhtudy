package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.dto.NoiseEventRequestDto;
import com.shhtudy.backend.domain.noise.dto.NoiseReportResponseDto;
import com.shhtudy.backend.domain.noise.dto.NoiseSessionRequestDto;
import com.shhtudy.backend.domain.noise.dto.MannerScoreResponseDto;
import com.shhtudy.backend.domain.noise.service.NoiseService;
import com.shhtudy.backend.global.response.ResponseCustom;
import com.shhtudy.backend.domain.user.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/noise")
@RequiredArgsConstructor
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Noise", description = "소음 관련 API")
public class NoiseController {

    private final NoiseService noiseService;

    @PostMapping("/event")
    @Operation(summary = "소음 이벤트 저장", description = "실시간 측정된 소음 이벤트를 서버에 저장합니다.")
    public ResponseCustom<Void> saveNoiseEvent(@AuthenticationPrincipal User user,
                                               @RequestBody @Valid NoiseEventRequestDto dto) {
        noiseService.saveNoiseEvent(user, dto);
        return ResponseCustom.OK();
    }

    @PutMapping("/session/close")
    @Operation(summary = "소음 세션 종료 및 통계 저장")
    public ResponseCustom<Void> closeNoiseSession(@AuthenticationPrincipal User user,
                                                  @RequestBody @Validated NoiseSessionRequestDto requestDto) {
        noiseService.closeSession(user, requestDto);
        return ResponseCustom.OK("세션 종료 및 통계 저장 완료");
    }

    @GetMapping("/report")
    @Operation(summary = "소음 리포트 조회", description = "가장 최근 소음 세션의 통계 리포트를 조회합니다.")
    public ResponseCustom<NoiseReportResponseDto> getReport(@AuthenticationPrincipal User user) {
        return ResponseCustom.OK(noiseService.getNoiseReport(user));
    }

    @GetMapping("/manner")
    @Operation(summary = "매너 점수 조회", description = "현재 사용자의 누적 포인트, 등급, 평균 데시벨, 소음 이벤트 횟수를 조회합니다.")
    public ResponseCustom<MannerScoreResponseDto> getMannerScore(@AuthenticationPrincipal User user) {
        return ResponseCustom.OK(noiseService.getMannerScore(user));
    }
}