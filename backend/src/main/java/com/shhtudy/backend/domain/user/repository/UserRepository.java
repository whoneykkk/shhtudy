package com.shhtudy.backend.domain.user.repository;

import com.shhtudy.backend.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByFirebaseUid(String firebaseUid);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByNickname(String nickname);
    boolean existsByFirebaseUid(String firebaseUid);
    Optional<User> findByCurrentSeat_SeatId(Integer seatId);
    
    // 좌석을 사용 중인 사용자들 조회 (시간 감소 스케줄러용)
    List<User> findAllByCurrentSeatIsNotNull();
}
