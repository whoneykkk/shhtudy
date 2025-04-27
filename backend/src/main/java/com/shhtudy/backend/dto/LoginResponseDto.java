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
    private int averageDecibel;
    private int noiseOccurrence;
}
