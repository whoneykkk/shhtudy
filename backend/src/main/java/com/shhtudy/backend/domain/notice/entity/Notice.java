package com.shhtudy.backend.domain.notice.entity;

import com.shhtudy.backend.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "notices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Notice extends BaseEntity {
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;
}
