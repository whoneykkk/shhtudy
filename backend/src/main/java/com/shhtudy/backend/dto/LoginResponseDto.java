package com.shhtudy.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

public class LoginResponseDto {
    private String token;
    private String userId;
    private String name;
    private String grade;
    private int remainingTime;
    private String currentSeat;
    private int averageDecibel;
    private int noiseOccurrence;
    private int mannerScore;
    private int points;
}
