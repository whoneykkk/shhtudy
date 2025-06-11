package com.shhtudy.backend.domain.notice.entity;

import com.shhtudy.backend.domain.common.BaseEntity;
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
public class NoticeRead extends BaseEntity {

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
