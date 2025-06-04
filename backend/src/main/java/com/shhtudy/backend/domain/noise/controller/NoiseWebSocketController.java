package com.shhtudy.backend.domain.noise.controller;

import com.shhtudy.backend.domain.noise.dto.NoiseMessage;
import com.shhtudy.backend.domain.noise.entity.Noise;
import com.shhtudy.backend.domain.noise.service.NoiseService;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class NoiseWebSocketController {
    private final NoiseService noiseService;
    private final UserRepository userRepository;

    @MessageMapping("/noise")
    @SendTo("/topic/noise-updates")
    public Noise handleNoiseUpdate(NoiseMessage message) {
        User user = userRepository.findById(message.getUserId())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return noiseService.recordNoise(message.getDecibelLevel(), user);
    }
}