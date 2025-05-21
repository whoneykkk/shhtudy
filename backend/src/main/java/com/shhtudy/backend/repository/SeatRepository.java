package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Seat;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SeatRepository extends JpaRepository<Seat, Integer> {
}
