package com.shhtudy.backend.domain.seat.repository;

import com.shhtudy.backend.domain.seat.entity.Seat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SeatRepository extends JpaRepository<Seat, Integer> {
    
    // 좌석 코드로 좌석 조회
    Optional<Seat> findByLocationCode(String locationCode);
    
    // 구역별 좌석 조회 (A, B, C, D 구역)
    @Query("SELECT s FROM Seat s WHERE s.locationCode LIKE :zone% ORDER BY s.seatId")
    List<Seat> findByZone(@Param("zone") String zone);
    
    // 상태별 좌석 조회
    List<Seat> findByStatus(Seat.Status status);
    
    // 빈 좌석만 조회
    @Query("SELECT s FROM Seat s WHERE s.status = 'EMPTY' ORDER BY s.seatId")
    List<Seat> findEmptySeats();
    
    // 특정 구역의 빈 좌석 조회
    @Query("SELECT s FROM Seat s WHERE s.status = 'EMPTY' AND s.locationCode LIKE :zone% ORDER BY s.seatId")
    List<Seat> findEmptySeatsByZone(@Param("zone") String zone);
}
