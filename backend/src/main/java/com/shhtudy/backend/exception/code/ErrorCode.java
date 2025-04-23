package com.shhtudy.backend.exception.code;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {

    DUPLICATE_USER("이미 가입된 사용자입니다."),
    INVALID_PASSWORD("비밀번호가 일치하지 않습니다."),
    INVALID_FIREBASE_TOKEN("유효하지 않은 Firebase 토큰입니다.");

    private final String message;
}
