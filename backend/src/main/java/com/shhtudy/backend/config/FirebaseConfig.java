package com.shhtudy.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import org.springframework.util.ResourceUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Configuration
public class FirebaseConfig {
    
    @PostConstruct
    public void initialize() {
        try {
            FileInputStream serviceAccount = new FileInputStream(
                ResourceUtils.getFile("classpath:firebase-service-account.json")
            );
            
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();
            
            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                log.info("Firebase 초기화 성공");
            }
        } catch (IOException e) {
            log.error("Firebase 초기화 실패: {}", e.getMessage());
            throw new RuntimeException("Firebase 초기화 중 오류 발생", e);
        }
    }
} 