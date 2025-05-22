package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, Long> {
    long countByReceiverIdAndReadFalse(String receiverId);
    Page<Message> findByReceiverId(String receiverId, Pageable pageable);
    Page<Message> findBySenderId(String senderId, Pageable pageable);
    Page<Message> findBySenderIdOrReceiverId(String senderId, String receiverId, Pageable pageable);
}
