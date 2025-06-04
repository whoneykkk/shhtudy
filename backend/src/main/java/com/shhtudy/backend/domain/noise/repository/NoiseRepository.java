package com.shhtudy.backend.domain.noise.repository;

import com.shhtudy.backend.domain.noise.entity.Noise;
import com.shhtudy.backend.domain.noise.enums.NoiseStatus;
import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NoiseRepository extends JpaRepository<Noise, Long> {
    // 특정 사용자의 소음 데이터 조회
    List<Noise> findByUser(User user);

    // 상태별 소음 데이터 조회
    List<Noise> findByStatus(NoiseStatus status);

    // 특정 사용자의 특정 시간 범위 소음 데이터 조회
    @Query("SELECT n FROM Noise n WHERE n.user = :user AND n.measurementTime BETWEEN :startTime AND :endTime")
    List<Noise> findByUserAndTimeRange(
            @Param("user") User user,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    // 특정 사용자의 특정 시간 범위 평균 데시벨 조회
    @Query("SELECT AVG(n.decibelLevel) FROM Noise n WHERE n.user = :user AND n.measurementTime BETWEEN :startTime AND :endTime")
    Double getAverageDecibelLevel(
            @Param("user") User user,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );
}