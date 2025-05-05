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
    
    private int points = 0; // 사용자 포인트 (기본값 0)

    @Enumerated(EnumType.STRING)     // enum 값을 문자열로 저장
    @Column(columnDefinition = "VARCHAR(10)")  // 명시적으로 컬럼 타입과 길이 지정
    private Grade grade = Grade.GOOD;

    public enum Grade {
        WARNING, GOOD, SILENT
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_seat_id") // users 테이블에 foreign key 생성
    private Seat currentSeat;

    private int averageDecibel = 0; //TODO: noise 엔티티 생성 시 추가
    private int noiseOccurrence = 0;//TODO: noise 엔티티 생성 시 추가
}
