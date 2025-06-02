package com.shhtudy.backend.domain.noise.controller;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/noise")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Noise", description = "소음 관련 API")
public class NoiseController {
}
