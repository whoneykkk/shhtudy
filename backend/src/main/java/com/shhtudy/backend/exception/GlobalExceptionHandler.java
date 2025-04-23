package com.shhtudy.backend.exception;

import com.shhtudy.backend.exception.code.ErrorCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ErrorResponse> handleCustomException(CustomException e) {
        ErrorCode code = e.getErrorCode();
        return ResponseEntity
                .badRequest()
                .body(new ErrorResponse(code.name(), code.getMessage()));
    }
}
