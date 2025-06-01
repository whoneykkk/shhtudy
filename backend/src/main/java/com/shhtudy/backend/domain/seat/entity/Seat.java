package com.shhtudy.backend.domain.seat.entity;

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

    @Column(name = "location_code", nullable = false, columnDefinition = "VARCHAR(255) DEFAULT '-'")
    private String locationCode = "-";

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
