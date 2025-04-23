package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;


@Service
@RequiredArgsConstructor

public class UserService {
    private final UserRepository userRepository;

    public void signUp(SignUpRequestDto request, String idToken) {

        // 1. Firebase ID Token 검증
        FirebaseToken firebaseToken;
        try {
            firebaseToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        } catch (FirebaseAuthException e) {
            throw new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
        }

        String firebaseUid = firebaseToken.getUid();

        // 2. firebaseUid 중복 확인
        if (userRepository.findByFirebaseUid(firebaseUid).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_USER);
        }

        // 3. 비밀번호 일치 확인
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        // 4. 사용자 등록
        User user = new User();
        user.setFirebaseUid(firebaseUid);
        user.setName(request.getName());
        user.setPhoneNumber(request.getPhoneNumber());

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        user.setPassword(encoder.encode(request.getPassword()));
        user.setPassword(request.getPassword());

        userRepository.save(user);
    }

}
