package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.SignUpRequestDto;
import com.shhtudy.backend.dto.UserProfileResponseDto;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    @Transactional
    public void signUp(SignUpRequestDto request, String firebaseUid) {
        logger.info("회원가입 시작 - firebaseUid: {}, phoneNumber: {}, nickname: {}", 
                firebaseUid, request.getPhoneNumber(), request.getNickname());
        
        try {
            // 1. firebaseUid 중복 확인
            if (userRepository.findByFirebaseUid(firebaseUid).isPresent()) {
                logger.warn("회원가입 실패 - 이미 존재하는 firebaseUid: {}", firebaseUid);
                throw new CustomException(ErrorCode.DUPLICATE_USER);
            }
            
            // 1-2. 전화번호 중복 확인
            if (userRepository.findByPhoneNumber(request.getPhoneNumber()).isPresent()) {
                logger.warn("회원가입 실패 - 이미 존재하는 전화번호: {}", request.getPhoneNumber());
                throw new CustomException(ErrorCode.DUPLICATE_USER);
            }

            if (userRepository.existsByNickname(request.getNickname())) {
                logger.warn("회원가입 실패 - 이미 존재하는 닉네임: {}", request.getNickname());
                throw new CustomException(ErrorCode.DUPLICATE_NICKNAME);
            }

            // 2. 비밀번호 일치 확인
            if (!request.getPassword().equals(request.getConfirmPassword())) {
                logger.warn("회원가입 실패 - 비밀번호 불일치");
                throw new CustomException(ErrorCode.INVALID_PASSWORD);
            }

            // 3. 사용자 등록
            User user = new User();
            user.setFirebaseUid(firebaseUid);
            user.setName(request.getName());
            user.setNickname(request.getNickname());
            user.setPhoneNumber(request.getPhoneNumber());

            // 4. 비밀번호 암호화 후 저장
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            
            logger.debug("사용자 정보 설정 완료: {}", user);

            // 5. 저장
            userRepository.save(user);
            logger.info("회원가입 성공 - firebaseUid: {}", firebaseUid);
        } catch (Exception e) {
            logger.error("회원가입 중 예외 발생: {}", e.getMessage(), e);
            throw e; // 예외를 다시 던져서 GlobalExceptionHandler에서 처리하도록 함
        }
    }
    
    /**
     * 사용자 프로필 조회
     */
    @Transactional(readOnly = true)
    public UserProfileResponseDto getUserProfile(String firebaseUid) {
        // 1. 사용자 조회
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        // 2. 응답 DTO 생성 및 반환
        UserProfileResponseDto dto = new UserProfileResponseDto();
        dto.setUserId(user.getFirebaseUid());
        dto.setName(user.getName());
        dto.setNickname(user.getNickname());
        dto.setGrade(user.getGrade().name());
        dto.setRemainingTime(user.getRemainingTime());
        dto.setAverageDecibel(user.getAverageDecibel());
        dto.setNoiseOccurrence(user.getNoiseOccurrence());
        dto.setMannerScore(user.getMannerScore());
        dto.setPoints(user.getPoints());
        dto.setPhoneNumber(user.getPhoneNumber());
        
        // 3. 현재 좌석 정보 확인
        if (user.getCurrentSeat() != null) {
            dto.setCurrentSeat(user.getCurrentSeat().getLocationCode());
        }
        
        return dto;
    }
    
    /**
     * 로그아웃 처리
     */
    @Transactional
    public void logout(String firebaseUid) {
        // 1. 사용자 조회
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        // 2. 로그아웃 처리 (필요한 로직 추가)
        logger.info("로그아웃 성공 - firebaseUid: {}", firebaseUid);
    }
}
