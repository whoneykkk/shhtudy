package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;


public interface MessageRepository extends JpaRepository<Message, Long> {
    boolean existsUnreadMessages(String userId);
}
