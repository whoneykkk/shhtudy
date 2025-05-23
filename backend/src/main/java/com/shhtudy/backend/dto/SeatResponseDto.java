package com.shhtudy.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class SeatResponseDto {
    private Integer seatId;
    private String locationCode; // 좌석 코드 (예: "A-1")
    private String status; // 좌석 상태 (EMPTY, GOOD, WARNING, SILENT, MY_SEAT)
    private boolean accessible; // 현재 사용자가 접근 가능한지 여부
    private String accessibilityMessage; // 접근 가능 여부 메시지
} 