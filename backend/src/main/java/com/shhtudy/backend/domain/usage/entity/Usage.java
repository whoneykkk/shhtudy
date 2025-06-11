package com.shhtudy.backend.domain.usage.entity;

import com.shhtudy.backend.domain.common.BaseEntity;
import com.shhtudy.backend.domain.usage.enums.UsageStatus;
import com.shhtudy.backend.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "usages")
public class Usage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    private LocalDateTime checkInTime;
    private LocalDateTime checkOutTime;
    private Integer usedMinutes;

    @Enumerated(EnumType.STRING)
    private UsageStatus usageStatus;

    public static Usage checkIn(User user) {
        Usage usage = new Usage();
        usage.user = user;
        usage.checkInTime = LocalDateTime.now();
        usage.usageStatus = UsageStatus.IN_PROGRESS;
        return usage;
    }

    public void checkOut() {
        this.checkOutTime = LocalDateTime.now();
        this.usageStatus = UsageStatus.COMPLETED;
    }

    public void expire() {
        this.checkOutTime = LocalDateTime.now();
        this.usedMinutes = calculateUsedMinutes();
        this.usageStatus = UsageStatus.EXPIRED;
    }

    private int calculateUsedMinutes() {
        return (int) java.time.Duration.between(this.checkInTime, this.checkOutTime).toMinutes();
    }
}
