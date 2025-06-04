package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Schema(description = "소음 이벤트 요청 DTO (기준 초과 시 전송)")
public class NoiseEventRequestDto {

    // firebaseUid는 파라미터 토큰으로 ㄱㄱ

    @Schema(description = "측정된 데시벨 값", example = "67.3", required = true)
    @DecimalMin("0.0")
    @NotNull
    private Double decibel;

    @Schema(description = "측정 시간 (클라이언트 시간 기준)", example = "2025-06-04T15:30:00", required = true)
    @NotNull
    private LocalDateTime measuredAt;
}
