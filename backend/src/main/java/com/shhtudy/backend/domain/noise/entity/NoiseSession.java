package com.shhtudy.backend.domain.noise.entity;

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
public class NoiseSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "checkin_time", nullable = false)
    private LocalDateTime checkinTime;

    @Column(name = "checkout_time", nullable = false)
    private LocalDateTime checkoutTime;

    @Column(name = "avg_decibel", nullable = false)
    private double avgDecibel;

    @Column(name = "max_decibel", nullable = false)
    private double maxDecibel;

    @Column(name = "quiet_ratio", nullable = false)
    private double quietRatio;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
