package com.shhtudy.backend.exception.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ErrorCode {

    // 공통 오류 (-1 ~ -999)
    BAD_REQUEST(-100, "잘못된 요청입니다.", HttpStatus.BAD_REQUEST),

    // 사용자/계정 관련 오류 (-1000 ~ -1999)
    DUPLICATE_USER(-1001, "이미 가입된 사용자입니다.", HttpStatus.CONFLICT),
    DUPLICATE_PHONE_NUMBER(-1002, "이미 사용 중인 전화번호입니다.", HttpStatus.CONFLICT),
    USER_NOT_FOUND(-1003, "존재하지 않는 사용자입니다.", HttpStatus.NOT_FOUND),
    INVALID_PASSWORD(-1004, "비밀번호가 일치하지 않습니다.", HttpStatus.UNAUTHORIZED),
    INVALID_CREDENTIALS(-1005, "전화번호 또는 비밀번호가 올바르지 않습니다.", HttpStatus.UNAUTHORIZED),
    INVALID_FIREBASE_TOKEN(-1006, "유효하지 않은 Firebase 토큰입니다.", HttpStatus.UNAUTHORIZED),

    // 시스템 오류 (-9000 이상)
    INTERNAL_ERROR(-9001, "서버 내부 오류입니다.", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;               // API 응답용 내부 에러 코드 (-1001 등)
    private final String message;         // 사용자 또는 프론트에 전달할 메시지
    private final HttpStatus httpStatus;  // 실제 HTTP 상태 코드
}
