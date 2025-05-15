package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByFirebaseUid(String firebaseUid);
    Optional<User> findByPhoneNumber(String phoneNumber);
    Optional<User> findByUserId(String userId);
}
