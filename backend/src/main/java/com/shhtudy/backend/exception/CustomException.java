package com.shhtudy.backend.exception;

import com.shhtudy.backend.exception.code.ErrorCode;
import lombok.Getter;

@Getter
public class CustomException extends RuntimeException {

    private final ErrorCode errorCode;

    public CustomException(ErrorCode errorCode) {
        super(errorCode.getMessage()); // 예외 메시지는 ErrorCode 내부에서 가져옴
        this.errorCode = errorCode;
    }
}
