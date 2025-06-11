package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.dto.NoiseEventRequestDto;
import com.shhtudy.backend.domain.noise.dto.NoiseSessionRequestDto;
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

    @PutMapping("/score")
    @Operation(summary = "점수 및 티어 계산", description = "인증된 사용자의 점수 및 등급을 다시 계산합니다.")
    public ResponseCustom<Void> calculateScoreAndTier(@AuthenticationPrincipal User user) {
        noiseService.recalculateUserScoreAndGrade(user);
        return ResponseCustom.OK("점수 및 등급이 재계산되었습니다.");
    }
}