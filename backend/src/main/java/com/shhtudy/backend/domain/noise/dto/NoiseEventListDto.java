package com.shhtudy.backend.domain.noise.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
@Schema(description = "소음 이벤트 목록 응답 DTO")
public class NoiseEventListDto {

    @Schema(description = "전체 개수", example = "42")
    private int totalCount;

    @Schema(description = "소음 이벤트 리스트")
    private List<NoiseEventDto> events;
}
