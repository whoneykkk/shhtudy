package com.shhtudy.backend.domain.message.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.shhtudy.backend.domain.common.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "messages",
        indexes = {
                @Index(name = "idx_sender_id", columnList = "sender_id"),
                @Index(name = "idx_receiver_id", columnList = "receiver_id")
        })
@Schema(description = "쪽지 메시지 엔티티")
public class Message extends BaseEntity {

    @Schema(description = "보낸 사람 ID", example = "user_123")
    @Column(name = "sender_id", nullable = false)
    private String senderId;

    @Schema(description = "받는 사람 ID", example = "user_456")
    @Column(name = "receiver_id", nullable = false)
    private String receiverId;

    @Schema(description = "쪽지 내용", example = "시끄러워요")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Schema(description = "보낸 시간 (LocalDateTime)", example = "2025-06-11T19:00:00")
    @Column(nullable = false, updatable = false)
    private LocalDateTime sentAt;

    @PrePersist
    protected void prePersist() {
        this.sentAt = LocalDateTime.now();
    }

    @Schema(description = "읽음 여부", example = "false")
    @JsonProperty("isRead")
    @Column(name = "is_read", nullable = false)
    private boolean read = false;

    @Schema(description = "보낸 사람이 삭제했는지 여부", example = "false")
    @JsonProperty("isDeletedBySender")
    @Column(nullable = false)
    private boolean deletedBySender = false;

    @Schema(description = "받은 사람이 삭제했는지 여부", example = "false")
    @JsonProperty("isDeletedByReceiver")
    @Column(nullable = false)
    private boolean deletedByReceiver = false;
}
