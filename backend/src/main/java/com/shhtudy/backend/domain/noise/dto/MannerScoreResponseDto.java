package com.shhtudy.backend.domain.noise.dto;

import com.shhtudy.backend.domain.user.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@Schema(description = "매너 점수 응답 DTO")
public class MannerScoreResponseDto {

    @Schema(description = "사용자 포인트", example = "100")
    private int point;

    @Schema(description = "사용자 등급", example = "SILENT")
    private User.Grade grade;

    @Schema(description = "평균 데시벨", example = "42.3")
    private double avgDecibel;

    @Schema(description = "기준 초과 횟수", example = "3")
    private int eventCount;
}