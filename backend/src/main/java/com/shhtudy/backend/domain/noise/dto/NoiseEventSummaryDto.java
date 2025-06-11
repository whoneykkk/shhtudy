package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "소음 이벤트 간단 요약 DTO")
public class NoiseEventSummaryDto {

    @Schema(description = "평균 데시벨", example = "55.0")
    private double decibel;

    @Schema(description = "설명 메시지", example = "기준 소음 초과")
    private String description;

    @Schema(description = "발생 시각", example = "2025-04-25T14:32:00")
    private LocalDateTime measuredAt;
}
