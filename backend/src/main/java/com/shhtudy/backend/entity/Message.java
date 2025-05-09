package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
@Table(
        name = "messages",
        indexes = {
                @Index(name = "idx_sender_id", columnList = "sender_id"),
                @Index(name = "idx_receiver_id", columnList = "receiver_id")
        }
)
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long messageId;

    @Column(name = "sender_id", nullable = false)
    private String senderId;

    @Column(name = "receiver_id", nullable = false)
    private String receiverId;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;  // 메세지 내용

    @Column(nullable = false)
    private boolean isRead = false;  // 읽음 여부 (기본값 false)

    @Column(nullable = false, updatable = false)
    private LocalDateTime sentAt;

    @PrePersist
    protected void prePersist() {
        this.sentAt = LocalDateTime.now();
    }
}
