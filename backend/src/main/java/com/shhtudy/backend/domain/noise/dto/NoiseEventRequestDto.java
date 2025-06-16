package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Schema(description = "소음 이벤트 기록 요청 DTO")
public class NoiseEventRequestDto {

    @NotNull
    @DecimalMin(value = "0.0", message = "데시벨 값은 0 이상이어야 합니다.")
    @Schema(description = "측정된 데시벨 값", example = "55.0")
    private Double decibel;
}
