package com.shhtudy.backend.domain.noise.dto;

import com.shhtudy.backend.domain.user.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
@Schema(description = "소음 세션 레포트 응답 DTO")
public class NoiseReportResponseDto {

    @Schema(description = "현재 사용자 등급", example = "SILENT")
    private User.Grade grade;

    @Schema(description = "평균 데시벨", example = "42.3")
    private double avgDecibel;

    @Schema(description = "소음 로그 요약 리스트")
    private List<NoiseEventSummaryDto> eventSummaries;

    @Schema(description = "최고 데시벨", example = "63.0")
    private double maxDecibel;

    @Schema(description = "기준 초과 횟수", example = "5")
    private int eventCount;

    @Schema(description = "내 조용한 비율", example = "0.82")
    private double userQuietRatio;
}
