package com.shhtudy.backend.domain.noise.dto;

import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
@Schema(description = "소음 이벤트 목록 응답 DTO")
public class NoiseEventListDto {

    @Schema(description = "전체 소음 이벤트 개수", example = "42")
    private int totalCount;

    @Schema(description = "소음 이벤트 리스트")
    private List<NoiseEventDto> events;

    public static NoiseEventListDto from(List<NoiseEvent> noiseEvents) {
        List<NoiseEventDto> dtoList = noiseEvents.stream()
                .map(event -> NoiseEventDto.builder()
                        .decibel(event.getDecibel())
                        .measuredAt(event.getMeasuredAt())
                        .build())
                .toList();
        return NoiseEventListDto.builder()
                .totalCount(dtoList.size())
                .events(dtoList)
                .build();
    }
}
