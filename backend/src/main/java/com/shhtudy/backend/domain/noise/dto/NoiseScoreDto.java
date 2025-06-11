package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@Schema(description = "점수 및 등급 응답 DTO")
public class NoiseScoreDto {

    @Schema(description = "해당 세션의 점수", example = "92.5")
    private double sessionScore;

    @Schema(description = "누적 평균 점수", example = "88.3")
    private double totalAverageScore;

    @Schema(description = "등급 (silent, good, warning)", example = "good")
    private String tier;
}
