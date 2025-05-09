package com.shhtudy.backend.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class FirebaseAuthService {

    @Value("${app.firebase.enabled:false}")
    private boolean firebaseEnabled;

    public String verifyIdToken(String idToken) {
        try {
            // 개발 모드에서는 Firebase 검증을 우회
            if (!firebaseEnabled) {
                System.out.println("============================================");
                System.out.println("Firebase 검증이 비활성화되어 있습니다. 개발 환경에서는 토큰 검증을 건너뜁니다.");
                System.out.println("수신된 Authorization 헤더: " + (idToken != null ? (idToken.length() > 20 ? idToken.substring(0, 20) + "..." : idToken) : "null"));
                System.out.println("============================================");
                
                // 토큰이 null이거나 비어있는 경우 예외 발생
                if (idToken == null || idToken.trim().isEmpty()) {
                    System.err.println("개발 모드: Firebase 토큰이 null이거나 비어 있습니다!");
                    throw new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
                }
                
                // 개발 모드에서는 항상 성공 처리하고 테스트용 사용자 ID 반환
                String devUserId = "dev-user-" + System.currentTimeMillis();
                //String devUserId = "dev-user";
                System.out.println("개발 모드: 임시 사용자 ID 생성: " + devUserId);
                return devUserId;
            }

            // 프로덕션 모드에서는 실제 Firebase 검증 진행
            if (idToken == null || idToken.trim().isEmpty()) {
                System.err.println("Firebase 토큰이 null이거나 비어 있습니다.");
                throw new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
            }
            
            System.out.println("Firebase 토큰 검증 시도: " + idToken.substring(0, Math.min(20, idToken.length())) + "...");
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            System.out.println("Firebase 토큰 검증 성공. UID: " + uid);
            return uid;
        } catch (FirebaseAuthException e) {
            System.err.println("Firebase 토큰 검증 오류: " + e.getMessage());
            System.err.println("오류 상세: " + e.getErrorCode() + " - " + e.getCause());
            throw new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
        } catch (Exception e) {
            if (!firebaseEnabled) {
                // 개발 모드에서는 예외 발생 시에도 테스트용 ID 반환하도록 수정
                String devUserId = "dev-user-error-" + System.currentTimeMillis();
                System.err.println("개발 모드 예외 발생: " + e.getMessage());
                System.err.println("개발 모드에서 계속 진행하기 위해 임시 ID 생성: " + devUserId);
                return devUserId;
            }
            
            System.err.println("Firebase 토큰 검증 중 예상치 못한 오류: " + e.getMessage());
            throw new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
        }
    }
}
