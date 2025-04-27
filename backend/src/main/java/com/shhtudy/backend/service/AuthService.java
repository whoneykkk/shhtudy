package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.LoginRequestDto;
import com.shhtudy.backend.dto.LoginResponseDto;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.UserRepository;
import com.shhtudy.backend.global.jwt.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;              // 토큰 발급용 (선택)
    private final PasswordEncoder passwordEncoder;      // 비밀번호 암호화 비교

    public LoginResponseDto login(LoginRequestDto request){
        // 1. 사용자 조회
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 2. 비밀번호 비교
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        // 3. 토큰 발급
        String token = jwtProvider.createToken(user.getFirebaseUid());

        // 4. 응답 DTO 구성
        LoginResponseDto response = new LoginResponseDto();
        response.setToken(token);
        response.setUserId(user.getFirebaseUid());
        response.setName(user.getName());
        response.setGrade(user.getGrade().name());
        response.setRemainingTime(user.getRemainingTime());
        response.setCurrentSeat(user.getCurrentSeat() != null ? user.getCurrentSeat().getLocationCode() : null);

        return response;

    }

}
