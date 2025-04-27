package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "seats")
@Getter
@Setter
@NoArgsConstructor

public class Seat {
    @Id
    private int seatId;

    private String locationCode;

    @Enumerated(EnumType.STRING)
    private Status status = Status.EMPTY;

    public enum Status {
        EMPTY,
        WARNING,
        GOOD,
        SILENT,
        MY_SEAT
    }

    @OneToMany(mappedBy = "currentSeat")
    private List<User> users; // 보통 이건 잘 안 씀

}
