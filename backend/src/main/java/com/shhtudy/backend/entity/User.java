package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor

public class User {
    @Id
    private String firebaseUid;

    private String name;

    @Column(unique = true)
    private String phoneNumber;

    private String password;

    @Column(columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP") // 보통 Column은 표기를 안하는데 제약조건이 있을 시 표기
    private LocalDateTime createdAt = LocalDateTime.now(); // 기본값: 현재 시각

    private int remainingTime = 0;

    private int mannerScore = 0;

    @Enumerated(EnumType.STRING)     // enum 값을 문자열로 저장
    private Grade grade = Grade.GOOD;

    public enum Grade {
        WARNING, GOOD, SILENT
    }

    private int averageDecibel;
    private int noiseOccurrence;
}
