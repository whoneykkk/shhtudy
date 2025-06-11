package com.shhtudy.backend.domain.message.repository;

import com.shhtudy.backend.domain.message.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MessageRepository extends JpaRepository<Message, Long> {
    long countByReceiverIdAndReadFalseAndDeletedByReceiverFalse(String receiverId);
    Page<Message> findByReceiverIdAndDeletedByReceiverFalse(String receiverId, Pageable pageable);
    Page<Message> findBySenderIdAndDeletedBySenderFalse(String senderId, Pageable pageable);
    @Query("""
        SELECT m FROM Message m
        WHERE
            (m.senderId = :userId AND m.deletedBySender = false)
            OR
            (m.receiverId = :userId AND m.deletedByReceiver = false)
    """)
    Page<Message> findAllVisibleMessages(@Param("userId") String userId, Pageable pageable);
    Page<Message> findByReceiverIdAndReadFalseAndDeletedByReceiverFalseOrderBySentAtDesc(String receiverId, Pageable pageable);

    boolean existsByReceiverIdAndReadFalseAndDeletedByReceiverFalse(String userId);
}
