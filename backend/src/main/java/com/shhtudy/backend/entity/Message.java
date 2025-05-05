package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "messages")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long messageId;

    @Column(nullable = false)
    private String senderId;  // 보낸 사용자 (firebase_uid)

    @Column(nullable = false)
    private String receiverId; // 받는 사용자 (firebase_uid)

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;  // 메세지 내용

    @Column(nullable = false)
    private boolean isRead = false;  // 읽음 여부 (기본값 false)

    @Column(nullable = false, updatable = false)
    private java.time.LocalDateTime sentAt = java.time.LocalDateTime.now();  // 보낸 시각
}
