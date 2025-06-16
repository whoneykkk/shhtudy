package com.shhtudy.backend.domain.noise.entity;

import com.shhtudy.backend.domain.common.BaseEntity;
import com.shhtudy.backend.domain.noise.dto.NoiseEventSummaryDto;
import com.shhtudy.backend.domain.user.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "noise_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "소음 초과 이벤트 엔티티")
public class NoiseEvent extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Schema(description = "측정된 데시벨 값", example = "55.0")
    @Column(nullable = false)
    private double decibel;

    @Schema(description = "측정 시각", example = "2024-03-25T14:30:00")
    @Column(name = "measured_at", nullable = false)
    private LocalDateTime measuredAt;
}
