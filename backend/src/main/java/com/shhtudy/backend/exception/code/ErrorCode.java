package com.shhtudy.backend.exception.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ErrorCode {

    DUPLICATE_USER(-2001, "이미 가입된 사용자입니다.", HttpStatus.CONFLICT),
    INVALID_PASSWORD(-2002, "비밀번호가 일치하지 않습니다.", HttpStatus.UNAUTHORIZED),
    INVALID_FIREBASE_TOKEN(-2003, "유효하지 않은 Firebase 토큰입니다.", HttpStatus.UNAUTHORIZED),
    BAD_REQUEST(-2004, "잘못된 요청입니다.", HttpStatus.BAD_REQUEST),
    INTERNAL_ERROR(-2999, "서버 내부 오류입니다.", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;             // 우리가 정의한 내부 코드 (-2001 등)
    private final String message;       // 사용자에게 보여줄 메시지
    private final HttpStatus httpStatus; // HTTP 상태코드
}
