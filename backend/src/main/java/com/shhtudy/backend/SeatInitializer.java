//테스트 좌석 생성용,,

package com.shhtudy.backend;

import com.shhtudy.backend.domain.seat.entity.Seat;
import com.shhtudy.backend.domain.seat.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class SeatInitializer implements CommandLineRunner {

    private final SeatRepository seatRepository;

    @Override
    public void run(String... args) throws Exception {
        if (seatRepository.count() == 0) {
            // 좌석이 없을 경우에만 생성
            System.out.println("좌석 데이터가 없습니다. 새로운 좌석을 생성합니다.");
            createInitialSeats();
        } else {
            System.out.println("좌석 데이터가 이미 존재합니다. 좌석 생성을 건너뜝니다.");
        }
    }

    private void createInitialSeats() {
        List<Seat> seatsToSave = new ArrayList<>();
        int seatIdCounter = 1;

        // A 구역: 16개 (A-1 ~ A-16)
        for (int i = 1; i <= 16; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatIdCounter++);
            seat.setLocationCode("A-" + i);
            seatsToSave.add(seat);
        }

        // B 구역: 21개 (B-1 ~ B-21)
        for (int i = 1; i <= 21; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatIdCounter++);
            seat.setLocationCode("B-" + i);
            seatsToSave.add(seat);
        }

        // C 구역: 16개 (C-1 ~ C-16)
        for (int i = 1; i <= 16; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatIdCounter++);
            seat.setLocationCode("C-" + i);
            seatsToSave.add(seat);
        }

        // F 구역: 11개 (F-1 ~ F-11)
        for (int i = 1; i <= 11; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatIdCounter++);
            seat.setLocationCode("F-" + i);
            seatsToSave.add(seat);
        }

        seatRepository.saveAll(seatsToSave);
        System.out.println("총 " + seatsToSave.size() + "개의 좌석이 생성되어 저장되었습니다.");
    }
} 