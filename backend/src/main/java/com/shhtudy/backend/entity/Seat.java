package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.*;

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
}
