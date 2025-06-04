package com.shhtudy.backend.domain.noise.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NoiseMessage {
    private Double decibelLevel;
    private String userId;
}