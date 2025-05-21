package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, Long> {
    // 사용자가 수신한 읽지 않은 메시지가 존재하는지 확인 (메시지 기능 구현 시 주석 해제 필요)
    /*
    @Query("SELECT COUNT(m) > 0 FROM Message m WHERE m.receiverId = :userId AND m.isRead = false")
    boolean existsByReceiverIdAndIsReadFalse(@Param("userId") String userId);
    */
    Page<Message> findByReceiverId(String receiverId, Pageable pageable);
    Page<Message> findBySenderId(String senderId, Pageable pageable);
    Page<Message> findBySenderIdOrReceiverId(String senderId, String receiverId, Pageable pageable);
}
