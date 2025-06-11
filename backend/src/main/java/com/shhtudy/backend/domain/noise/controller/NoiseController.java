package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.dto.NoiseEventRequestDto;
import com.shhtudy.backend.domain.noise.dto.NoiseSessionRequestDto;
import com.shhtudy.backend.domain.noise.service.NoiseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
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

    @PostMapping("/event")
    @Operation(summary = "소음 이벤트 저장", description = "실시간 측정된 소음 이벤트를 서버에 저장합니다.")
    public ResponseEntity<Void> saveNoiseEvent(@RequestBody @Valid NoiseEventRequestDto dto) {
        noiseService.saveNoiseEvent(dto);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/session/close")
    @Operation(summary = "소음 세션 종료 및 통계 저장")
    public ResponseEntity<String> closeNoiseSession(@RequestBody @Validated NoiseSessionRequestDto requestDto) {
        noiseService.closeSession(requestDto);
        return ResponseEntity.ok("세션 종료 및 통계 저장 완료");
    }

    @PostMapping("/score")
    public NoiseScoreDto getScoreAndTier(
            @RequestParam String userId,
            @RequestParam double quietRatio
    ) {
        return noiseService.calculateScoreAndTier(userId, quietRatio);
    }
}
