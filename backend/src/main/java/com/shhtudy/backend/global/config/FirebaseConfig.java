package com.shhtudy.backend.global.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${app.firebase.enabled:false}")
    private boolean firebaseEnabled;

    @Value("${app.firebase.config-file:firebase-service-account.json}")
    private String firebaseConfigFile;

    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                if (firebaseEnabled) {
                    try {
                        // 파일 시스템에서 직접 파일 로드
                        File file = new File(firebaseConfigFile);
                        InputStream serviceAccount = new FileInputStream(file);
                        
                        FirebaseOptions options = FirebaseOptions.builder()
                                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                                .build();

                        FirebaseApp.initializeApp(options);
                        System.out.println("Firebase 초기화 완료 (서비스 계정 사용)");
                    } catch (IOException e) {
                        System.err.println("Firebase 서비스 계정 파일 로드 실패: " + e.getMessage());
                        throw e;  // 실패 시 예외를 던져서 애플리케이션이 시작되지 않도록 함
                    }
                } else {
                    System.out.println("Firebase가 비활성화되어 있어 초기화를 건너뜁니다.");
                }
            }
        } catch (Exception e) {
            System.err.println("Firebase 초기화 오류: " + e.getMessage());
            throw new RuntimeException("Firebase 초기화 실패", e);
        }
    }
} 