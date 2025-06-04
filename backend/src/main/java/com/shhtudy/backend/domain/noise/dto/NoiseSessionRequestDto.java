package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "소음 세션 종료 시(체크아웃 시) 전송되는 요약 통계 DTO")
public class NoiseSessionRequestDto {

    @Schema(description = "사용 시간 동안 평균 데시벨", example = "51.7", required = true)
    @DecimalMin("0.0")
    @NotNull
    private Double avgDecibel;

    @Schema(description = "사용 시간 동안 최대 데시벨", example = "78.1", required = true)
    @DecimalMin("0.0")
    @NotNull
    private Double maxDecibel;

    @Schema(description = "55dB 이하인 시간 비율 (0.0 ~ 1.0)", example = "0.82", required = true)
    @DecimalMin("0.0")
    @DecimalMax("1.0")
    @NotNull
    private Double quietRatio;
}
