package com.shhtudy.backend.domain.notice.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notice_reads")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NoticeRead {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notice_id")
    private Notice notice;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    private LocalDateTime readAt;

    @PrePersist
    protected void prePersist() {
        this.readAt = LocalDateTime.now();
    }
}
