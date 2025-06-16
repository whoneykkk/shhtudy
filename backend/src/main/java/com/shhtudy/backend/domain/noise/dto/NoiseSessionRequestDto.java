package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Schema(description = "소음 세션 종료 요청 DTO")
public class NoiseSessionRequestDto {

    @Schema(description = "평균 데시벨", example = "42.3")
    private double averageDecibel;

    @Schema(description = "조용한 시간 비율 (0.0 ~ 1.0)", example = "0.82")
    private double quietRatio;

    @Schema(description = "최고 데시벨", example = "63.0")
    private double maxDecibel;
}
