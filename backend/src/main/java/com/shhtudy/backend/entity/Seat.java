package com.shhtudy.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "seats")
@Getter
@Setter
@NoArgsConstructor

public class Seat {
    @Id
    private int seat_id;

    private String location_code;

    @Enumerated(EnumType.STRING)
    private Status status=Status.빈자리;

    public enum Status {
        빈자리,주의,양호,조용,내좌석
    }



}
