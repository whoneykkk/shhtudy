package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Schema(description = "소음 이벤트 기록 요청 DTO")
public class NoiseEventRequestDto {

    @NotNull
    @Schema(description = "측정된 데시벨 값", example = "55.0")
    private double decibel;

    @NotNull
    @Schema(description = "측정 시각", example = "2024-03-25T14:30:00")
    private LocalDateTime measuredAt;
}
