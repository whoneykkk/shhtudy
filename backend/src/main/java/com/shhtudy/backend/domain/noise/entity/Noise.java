package com.shhtudy.backend.domain.noise.entity;

import com.shhtudy.backend.domain.noise.enums.NoiseStatus;
import com.shhtudy.backend.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

//TODO: Noise 엔티티는 필요없으니 지우기.

@Entity
@Table(name = "noises")
@Getter
@Setter
@NoArgsConstructor
public class Noise {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Double decibelLevel;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "noise_status")
    @Enumerated(EnumType.STRING)
    private NoiseStatus status; // QUIET, MODERATE, LOUD

    @Column(nullable = false)
    private LocalDateTime measurementTime;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public Noise(Double decibelLevel, User user) {
        this.decibelLevel = decibelLevel;
        this.user = user;
        this.measurementTime = LocalDateTime.now();
        this.status = calculateNoiseStatus(decibelLevel);
    }

    private NoiseStatus calculateNoiseStatus(Double decibelLevel) {
        if (decibelLevel <= 35) {
            return NoiseStatus.QUIET;
        } else if (decibelLevel <= 45) {
            return NoiseStatus.MODERATE;
        } else {
            return NoiseStatus.LOUD;
        }
    }
}