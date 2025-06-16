package com.shhtudy.backend.domain.seat.service;

import com.shhtudy.backend.domain.seat.entity.Seat;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.seat.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SeatService {
    
    private final SeatRepository seatRepository;
    
    /**
     * 구역별 등급 제한 검증
     * A구역: SILENT만
     * B구역: SILENT, GOOD만  
     * C,F구역: 모든 등급
     */
    public boolean canUserAccessZone(String zone, User.Grade userGrade) {
        switch (zone.toUpperCase()) {
            case "A":
                return userGrade == User.Grade.SILENT; // A등급만
            case "B":
                return userGrade == User.Grade.SILENT || userGrade == User.Grade.GOOD; // A, B등급만
            case "C":
            case "F":
                return true; // 모든 등급 가능
            default:
                return false;
        }
    }
    
    /**
     * 사용자가 접근 가능한 구역 목록 반환
     */
    public List<String> getAccessibleZones(User.Grade userGrade) {
        switch (userGrade) {
            case SILENT: // A등급
                return Arrays.asList("A", "B", "C", "F"); // 모든 구역 접근 가능
            case GOOD: // B등급  
                return Arrays.asList("B", "C", "F"); // B, C, F구역만
            case WARNING: // C등급
                return Arrays.asList("C", "F"); // C, F구역만
            default:
                return Arrays.asList(); // 접근 불가
        }
    }
    
    /**
     * 모든 좌석 현황 조회
     */
    public List<Seat> getAllSeats() {
        return seatRepository.findAll();
    }
    
    /**
     * 특정 구역의 모든 좌석 조회
     */
    public List<Seat> getSeatsByZone(String zone) {
        return seatRepository.findByZone(zone);
    }
    
    /**
     * 등급별 접근 가능 여부 메시지 반환
     */
    public String getAccessibilityMessage(String zone, User.Grade userGrade) {
        if (canUserAccessZone(zone, userGrade)) {
            return "접근 가능";
        }
        
        switch (zone.toUpperCase()) {
            case "A":
                return "A구역은 A등급(조용함) 사용자만 이용 가능합니다.";
            case "B":
                return "B구역은 A등급(조용함), B등급(양호) 사용자만 이용 가능합니다.";
            default:
                return "접근할 수 없는 구역입니다.";
        }
    }
} 