package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
@RequiredArgsConstructor

public class UserService {
    private final UserRepository userRepository;

    public void signUp(SignUpRequestDto request, String firebaseUid) {

        // 1. firebaseUid 중복 확인
        if (userRepository.findByFirebaseUid(firebaseUid).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_USER);
        }

        // 2. 비밀번호 일치 확인
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        // 3. 사용자 등록
        User user = new User();
        user.setFirebaseUid(firebaseUid);
        user.setName(request.getName());
        user.setPhoneNumber(request.getPhoneNumber());

        // 4. 비밀번호 암호화 후 저장
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        user.setPassword(encoder.encode(request.getPassword()));

        userRepository.save(user);
    }

}
