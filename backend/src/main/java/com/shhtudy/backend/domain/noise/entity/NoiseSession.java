package com.shhtudy.backend.domain.noise.entity;

import com.shhtudy.backend.domain.common.BaseEntity;
import com.shhtudy.backend.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "noise_sessions")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NoiseSession extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "checkin_time", nullable = false)
    private LocalDateTime checkinTime;

    @Column(name = "checkout_time", nullable = true)
    @Setter
    private LocalDateTime checkoutTime;

    @Column(name = "avg_decibel", nullable = false)
    @Setter
    private double avgDecibel;

    @Column(name = "max_decibel", nullable = false)
    @Setter
    private double maxDecibel;

    @Column(name = "quiet_ratio", nullable = false)
    @Setter
    private double quietRatio;
}
