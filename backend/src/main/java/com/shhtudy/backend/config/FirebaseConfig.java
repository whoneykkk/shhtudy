package com.shhtudy.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

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
            // Firebase가 이미 초기화되었는지 확인
            if (FirebaseApp.getApps().isEmpty()) {
                if (firebaseEnabled) {
                    // 프로덕션 모드: 서비스 계정 키 사용
                    try {
                        // 클래스패스에서 파일 로드 시도
                        InputStream serviceAccount = new ClassPathResource(firebaseConfigFile).getInputStream();
                        FirebaseOptions options = FirebaseOptions.builder()
                                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                                .build();

                        FirebaseApp.initializeApp(options);
                        System.out.println("Firebase 초기화 완료 (서비스 계정 사용)");
                    } catch (IOException e) {
                        System.err.println("Firebase 서비스 계정 파일 로드 실패: " + e.getMessage());
                        System.out.println("기본 인증 정보로 대체합니다.");
                        
                        // 서비스 계정 파일이 없으면 기본 인증으로 대체
                        FirebaseOptions options = FirebaseOptions.builder()
                                .setCredentials(GoogleCredentials.getApplicationDefault())
                                .build();
                        
                        FirebaseApp.initializeApp(options);
                        System.out.println("Firebase 초기화 완료 (기본 인증 사용)");
                    }
                } else {
                    // 개발 모드: 로컬 에뮬레이터 또는 개발 모드 설정
                    System.out.println("Firebase가 비활성화되어 있어 초기화를 건너뜁니다. 개발 모드에서는 토큰 검증이 우회됩니다.");
                }
            }
        } catch (Exception e) {
            System.err.println("Firebase 초기화 오류: " + e.getMessage());
            // 개발 모드에서는 실패해도 계속 진행할 수 있도록 예외를 무시
        }
    }
} 