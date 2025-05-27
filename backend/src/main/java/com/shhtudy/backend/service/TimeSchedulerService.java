package com.shhtudy.backend.service;

import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class TimeSchedulerService {
    
    private final UserRepository userRepository;
    
    /**
     * 매 1분마다 실행되어 좌석을 사용 중인 사용자들의 남은 시간을 1분(60초) 감소시킵니다.
     */
    @Scheduled(fixedRate = 60000) // 1분 = 60,000ms
    @Transactional
    public void decreaseRemainingTime() {
        try {
            // 현재 좌석을 사용 중인 사용자들 조회
            List<User> usersWithSeats = userRepository.findAllByCurrentSeatIsNotNull();
            
            if (usersWithSeats.isEmpty()) {
                log.debug("현재 좌석을 사용 중인 사용자가 없습니다.");
                return;
            }
            
            log.info("좌석 사용 중인 사용자 {}명의 시간을 1분 감소시킵니다.", usersWithSeats.size());
            
            int updatedCount = 0;
            
            for (User user : usersWithSeats) {
                int currentTime = user.getRemainingTime();
                
                if (currentTime > 0) {
                    // 1분(60초) 감소
                    int newTime = Math.max(0, currentTime - 60);
                    user.setRemainingTime(newTime);
                    
                    log.debug("사용자 {}의 남은 시간: {}초 -> {}초", 
                        user.getNickname(), currentTime, newTime);
                    
                    // 시간이 0이 되면 좌석 해제
                    if (newTime == 0) {
                        log.info("사용자 {}의 시간이 만료되어 좌석을 해제합니다.", user.getNickname());
                        if (user.getCurrentSeat() != null) {
                            user.getCurrentSeat().setStatus(
                                com.shhtudy.backend.entity.Seat.Status.EMPTY
                            );
                        }
                        user.setCurrentSeat(null);
                    }
                    
                    updatedCount++;
                }
            }
            
            // 배치로 저장
            userRepository.saveAll(usersWithSeats);
            
            log.info("{}명의 사용자 시간 업데이트 완료", updatedCount);
            
        } catch (Exception e) {
            log.error("시간 감소 스케줄러 실행 중 오류 발생: {}", e.getMessage(), e);
        }
    }
}
