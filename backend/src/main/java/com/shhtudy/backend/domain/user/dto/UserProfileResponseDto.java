package com.shhtudy.backend.domain.user.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserProfileResponseDto {
    private String userId;
    private String name;
    private String nickname;
    private String grade;
    private int remainingTime;
    private String currentSeat;
    private double averageDecibel;
    private int noiseOccurrence;
    private int mannerScore;
    private int points;
    private String phoneNumber;
} 