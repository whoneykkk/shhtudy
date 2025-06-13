package com.shhtudy.backend.domain.noise.dto;

import com.shhtudy.backend.domain.noise.entity.NoiseEvent;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "소음 이벤트 단건 조회 DTO")
public class NoiseEventDto {

    @Schema(description = "데시벨", example = "55.0")
    private double decibel;

    @Schema(description = "측정 시각", example = "2025-06-04T15:30:00")
    private LocalDateTime measuredAt;

    public static NoiseEventDto from(NoiseEvent event) {
        return NoiseEventDto.builder()
                .decibel(event.getDecibel())
                .measuredAt(event.getMeasuredAt())
                .build();
    }
}
